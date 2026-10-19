import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/frosted_bottom_bar.dart';
import '../budget/application/budget_controller.dart';
import '../cart/application/cart_controller.dart';
import '../cart/presentation/smart_cart_screen.dart';
import '../decision/presentation/compare_matrix_screen.dart';
import '../home/presentation/intent_home_screen.dart';
import '../profile/presentation/insights_screen.dart';
import 'navigation_controller.dart';

/// Persistent navigation shell.
///
/// Tabs are built lazily on first visit and then kept alive, so scroll
/// positions and in-progress state survive tab switches. Switching
/// cross-fades with a slight depth scale while inactive tabs have their
/// tickers paused and pointer input blocked.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(navigationProvider);
    final cartCount = ref.watch(cartCountProvider);
    final overBudget = ref.watch(
      budgetSnapshotProvider.select((b) => b.isOver),
    );

    return PopScope(
      canPop: tab == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(navigationProvider.notifier).select(AppTab.home);
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundDeep,
        body: AmbientBackground(
          child: _TabHost(
            index: tab.index,
            builders: const [
              IntentHomeScreen.new,
              CompareMatrixScreen.new,
              SmartCartScreen.new,
              InsightsScreen.new,
            ],
          ),
        ),
        bottomNavigationBar: FrostedBottomBar(
          currentIndex: tab.index,
          onTap: (i) =>
              ref.read(navigationProvider.notifier).select(AppTab.values[i]),
          items: [
            const FrostedBarItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore_rounded,
              label: 'Intent',
            ),
            const FrostedBarItem(
              icon: Icons.balance_outlined,
              activeIcon: Icons.balance_rounded,
              label: 'Compare',
            ),
            FrostedBarItem(
              icon: Icons.shield_outlined,
              activeIcon: Icons.shield_rounded,
              label: 'Guardian',
              badge: cartCount,
              badgeColor: overBudget ? AppColors.fitLow : AppColors.primary,
            ),
            const FrostedBarItem(
              icon: Icons.insights_outlined,
              activeIcon: Icons.insights_rounded,
              label: 'Insights',
            ),
          ],
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
            child: AnimatedScale(
              scale: active ? 1 : 0.985,
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
