import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/user_session.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/auth/application/auth_service.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/navigation/main_scaffold.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw edge-to-edge so the canvas and the floating island reach the edges.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeModeController.load();

  runApp(const AuthGate());
}

/// Routes between sign-in and the app.
///
/// Each account runs in its own provider scope, keyed by uid and seeded from
/// its own database, so signing out or switching accounts can never carry one
/// account's cart, holds or budget into another's.
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

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_resolved && user?.uid == _user?.uid) return;
      final previous = _session;
      setState(() {
        _resolved = true;
        _user = user;
        _session = user == null ? null : openUserSession(user.uid);
      });
      // Close the old account's database once its scope has been torn down.
      previous?.then((s) async {
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

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (!_resolved) return ColoredBox(color: AppColors.canvas);
    if (user == null) {
      return const ProviderScope(
        key: ValueKey('signed-out'),
        child: ClarionApp(home: SignInScreen()),
      );
    }
    return FutureBuilder(
      key: ValueKey(user.uid),
      future: _session,
      builder: (context, snapshot) {
        final session = snapshot.data;
        if (session == null) return ColoredBox(color: AppColors.canvas);
        return ProviderScope(
          key: ValueKey(user.uid),
          overrides: [
            currentUserProvider.overrideWithValue(user),
            ...session.overrides,
          ],
          child: const ClarionApp(),
        );
      },
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
      theme: AppTheme.current,
      // Tokens swap in one frame; don't let stock widgets lerp behind them.
      themeAnimationDuration: Duration.zero,
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
