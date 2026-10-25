import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/floating_nav_capsule.dart';
import '../../core/widgets/obsidian_canvas.dart';
import '../auth/application/auth_service.dart';
import '../cart/application/budget_controller.dart';
import '../cart/application/cart_controller.dart';
import '../cart/presentation/smart_cart_screen.dart';
import '../decision/application/cooldown_controller.dart';
import '../decision/presentation/compare_matrix_screen.dart';
import '../home/presentation/intent_home_screen.dart';
import '../profile/application/ceiling_onboarding.dart';
import '../profile/presentation/spending_profile_screen.dart';
import '../profile/presentation/widgets/ceiling_sheet.dart';
import '../tour/app_tour.dart';
import 'navigation_controller.dart';

/// Spatial shell hosting the four primary tabs under the floating capsule.
///
/// Tabs are built lazily on first visit and kept alive, so scroll position
/// and in-progress state survive switches. Inactive tabs are faded out,
/// ignore input and have their tickers paused.
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runOnboarding());
  }

  /// First-run onboarding, once per account: set the monthly ceiling, then
  /// take the app tour. Outside a session (widget tests) there is no account,
  /// so nothing is shown.
  Future<void> _runOnboarding() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (!await CeilingOnboarding.isDone(user.uid)) {
      if (!mounted) return;
      // Mark first: however the sheet is dismissed, it never nags again.
      await CeilingOnboarding.markDone(user.uid);
      if (!mounted) return;
      await showCeilingSheet(context, welcome: true);
    }
    if (!mounted) return;
    if (!await TourOnboarding.isDone(user.uid)) {
      if (!mounted) return;
      await TourOnboarding.markDone(user.uid);
      if (!mounted) return;
      ref.read(appTourProvider.notifier).start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(navigationProvider);
    final cartCount = ref.watch(cartCountProvider);
    final overBudget = ref.watch(
      budgetSnapshotProvider.select((b) => b.isOver),
    );
    final coolingOff = ref.watch(cooldownProvider.select((m) => m.isNotEmpty));
    final touring = ref.watch(appTourProvider.select((i) => i != null));

    // The canvas sits outside the Scaffold so the keyboard never resizes it.
    return ObsidianCanvas(
      child: PopScope(
        canPop: tab == AppTab.horizon && !touring,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          // Back during the tour ends it; otherwise it returns to Horizon.
          if (touring) {
            ref.read(appTourProvider.notifier).finish();
          } else {
            ref.read(navigationProvider.notifier).select(AppTab.horizon);
          }
        },
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: _TabHost(
            index: tab.index,
            builders: const [
              IntentHomeScreen.new,
              CompareMatrixScreen.new,
              SmartCartScreen.new,
              SpendingProfileScreen.new,
            ],
          ),
          bottomNavigationBar: FloatingNavCapsule(
            currentIndex: tab.index,
            onSelected: (i) =>
                ref.read(navigationProvider.notifier).select(AppTab.values[i]),
            destinations: [
              const NavDestination(
                icon: Icons.blur_on_outlined,
                activeIcon: Icons.blur_on_rounded,
                label: 'Horizon',
              ),
              const NavDestination(
                icon: Icons.compare_arrows_outlined,
                activeIcon: Icons.compare_arrows_rounded,
                label: 'Compare',
              ),
              NavDestination(
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield_rounded,
                label: 'Guardian',
                badge: cartCount,
                badgeColor: overBudget ? AppColors.rose : AppColors.iris,
              ),
              NavDestination(
                icon: Icons.donut_large_outlined,
                activeIcon: Icons.donut_large_rounded,
                label: 'Profile',
                dot: coolingOff ? AppColors.rose : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabHost extends StatefulWidget {
  const _TabHost({required this.index, required this.builders});

  final int index;
  final List<Widget Function({Key? key})> builders;

  @override
  State<_TabHost> createState() => _TabHostState();
}

class _TabHostState extends State<_TabHost> {
  final Map<int, Widget> _cache = {};

  @override
  Widget build(BuildContext context) {
    _cache.putIfAbsent(
      widget.index,
      () => widget.builders[widget.index](key: PageStorageKey(widget.index)),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        for (final entry in _cache.entries)
          _TabPage(
            key: ValueKey(entry.key),
            active: entry.key == widget.index,
            child: entry.value,
          ),
      ],
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeFocus(
        excluding: !active,
        child: ExcludeSemantics(
          excluding: !active,
          // The fade runs outside TickerMode so the outgoing tab can still
          // animate out while its own content's tickers are paused.
          child: AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: AppMotion.medium,
            curve: AppMotion.standard,
            child: AnimatedSlide(
              offset: active ? Offset.zero : const Offset(0, 0.008),
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              child: TickerMode(enabled: active, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
