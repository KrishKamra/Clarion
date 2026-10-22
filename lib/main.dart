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
import 'core/theme/app_theme.dart';
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
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
class ClarionApp extends StatelessWidget {
  const ClarionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainScaffold(),
    );
  }
}
