import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/app_database.dart';
import 'core/db/budget_repository.dart';
import 'core/db/cart_repository.dart';
import 'core/db/cooldown_repository.dart';
import 'core/db/db_providers.dart';
import 'core/db/price_watch_repository.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'data/mock_catalog.dart';
import 'features/navigation/main_scaffold.dart';

/// Everything loaded from SQLite before the first frame.
typedef _SavedState = ({
  AppDatabase db,
  Map<String, DateTime> holds,
  List<SavedCartLine> cart,
  StoredBudget budget,
  Map<String, double?> watchlist,
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw edge-to-edge so the canvas and the floating island reach the edges.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final themeMode = await ThemeModeController.load();

  // Open the local database and load saved state before the first frame. If
  // anything fails (e.g. running on web), carry on with in-memory defaults.
  _SavedState? saved;
  try {
    final db = await AppDatabase.open();
    // Price Memory: record today's prices (and back-fill the 30-day history
    // on first launch) before the watchlist is read.
    final priceWatch = PriceWatchRepository(db);
    try {
      await priceWatch.recordPrices(MockCatalog.products);
    } catch (error, stack) {
      developer.log(
        'Could not record price memory',
        error: error,
        stackTrace: stack,
      );
    }
    saved = (
      db: db,
      holds: await CooldownRepository(db).loadAll(),
      cart: await CartRepository(db).loadAll(),
      budget: await BudgetRepository(db).load(),
      watchlist: await priceWatch.loadWatchlist(),
    );
  } catch (error, stack) {
    developer.log(
      'Local database unavailable; running without persistence',
      error: error,
      stackTrace: stack,
    );
  }

  final state = saved;
  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(() => ThemeModeController(themeMode)),
        if (state != null) ...[
          appDatabaseProvider.overrideWithValue(state.db),
          initialCooldownsProvider.overrideWithValue(state.holds),
          initialCartProvider.overrideWithValue(state.cart),
          initialBudgetProvider.overrideWithValue(state.budget),
          initialWatchlistProvider.overrideWithValue(state.watchlist),
        ],
      ],
      child: const ClarionApp(),
    ),
  );
}

/// Root widget for the Clarion application.
class ClarionApp extends ConsumerStatefulWidget {
  const ClarionApp({super.key});

  @override
  ConsumerState<ClarionApp> createState() => _ClarionAppState();
}

class _ClarionAppState extends ConsumerState<ClarionApp>
    with WidgetsBindingObserver {
  Brightness? _applied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final brightness = switch (ref.watch(themeModeProvider)) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    if (brightness != _applied) {
      _applied = AppColors.brightness = brightness;
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);
      _refreshAll(context as Element);
    }

    return MaterialApp(
      title: 'Clarion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      // Tokens swap in one frame; don't let stock widgets lerp behind them.
      themeAnimationDuration: Duration.zero,
      home: const MainScaffold(),
    );
  }

  /// Tokens are read at build and paint time, so a palette swap has to reach
  /// const subtrees the framework would skip and painters whose inputs did
  /// not change. Widget and scroll state are kept.
  static void _refreshAll(Element root) {
    void visit(Element e) {
      e.markNeedsBuild();
      if (e is RenderObjectElement) e.renderObject.markNeedsPaint();
      e.visitChildren(visit);
    }

    root.visitChildren(visit);
  }
}
