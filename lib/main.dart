import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/user_session.dart';
import 'core/links/deep_links.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/locale_controller.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/auth/application/auth_service.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/navigation/main_scaffold.dart';
import 'features/splash/clarion_splash.dart';
import 'features/tour/app_tour.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw edge-to-edge so the canvas and the floating island reach the edges.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeModeController.load();
  await LocaleController.load();
  await NotificationService.init();
  DeepLinks.init();

  // The splash paints before ClarionApp exists, so resolve the palette here.
  AppColors.brightness = switch (ThemeModeController.saved) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => PlatformDispatcher.instance.platformBrightness,
  };
  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);

  runApp(const AuthGate());
}

/// Routes between sign-in and the app, behind the launch splash.
///
/// Each account runs in its own provider scope, keyed by uid and seeded from
/// its own database, so signing out or switching accounts can never carry one
/// account's cart, holds or budget into another's.
///
/// The splash covers the cold start only: it reports which step the launch
/// is on, and opens onto the app once the first screen has what it needs.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<User?> _subscription;
  bool _resolved = false;
  User? _user;
  Future<UserSession>? _session;
  UserSession? _opened;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_resolved && user?.uid == _user?.uid) return;
      final previous = _session;
      final session = user == null ? null : openUserSession(user.uid);
      setState(() {
        _resolved = true;
        _user = user;
        _session = session;
        _opened = null;
      });
      session?.then((s) {
        if (mounted && identical(_session, session)) {
          setState(() => _opened = s);
        }
      });
      // Close the old account's database once its scope has faded out and
      // been torn down.
      previous?.then((s) async {
        await Future<void>.delayed(AppMotion.slow);
        await SchedulerBinding.instance.endOfFrame;
        await s.db?.close();
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  BootStage get _stage {
    if (!_resolved) return BootStage.starting;
    if (_user != null && _opened == null) return BootStage.opening;
    return BootStage.ready;
  }

  Widget _app() {
    final user = _user;
    final waiting = ColoredBox(
      key: const ValueKey('waiting'),
      color: AppColors.canvas,
    );
    if (!_resolved) return waiting;
    if (user == null) {
      return const ProviderScope(
        key: ValueKey('signed-out'),
        child: ClarionApp(home: SignInScreen()),
      );
    }
    final session = _opened;
    if (session == null) return waiting;
    return ProviderScope(
      key: ValueKey(user.uid),
      overrides: [
        currentUserProvider.overrideWithValue(user),
        ...session.overrides,
      ],
      child: const ClarionApp(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The app always holds the first slot, so dropping the splash above it
    // never rebuilds it from scratch.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Signing in or out cross-fades between scopes, never a hard cut.
          AnimatedSwitcher(
            duration: AppMotion.slow,
            switchInCurve: AppMotion.standard,
            switchOutCurve: AppMotion.standard,
            child: _app(),
          ),
          if (!_splashDone)
            ClarionSplash(
              stage: _stage,
              onDone: () => setState(() => _splashDone = true),
            ),
        ],
      ),
    );
  }
}

/// Root widget for the Clarion application.
class ClarionApp extends ConsumerStatefulWidget {
  const ClarionApp({super.key, this.home = const MainScaffold()});

  /// The first screen: the app shell, or sign-in outside a session.
  final Widget home;

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
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.current,
      // Tokens swap in one frame; don't let stock widgets lerp behind them.
      themeAnimationDuration: Duration.zero,
      navigatorObservers: [ref.read(tourNavigatorObserverProvider)],
      // The tour sits above every route, so it can follow the user onto the
      // product page and back.
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [child ?? const SizedBox.shrink(), const AppTourOverlay()],
      ),
      home: widget.home,
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
