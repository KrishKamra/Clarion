import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/obsidian_canvas.dart';
import '../budget/application/budget_controller.dart';
import '../cart/application/cart_controller.dart';
import '../cart/presentation/smart_cart_screen.dart';
import '../decision/presentation/decision_node_screen.dart';
import '../home/presentation/intent_home_screen.dart';
import '../memory/presentation/spending_memory_screen.dart';
import 'navigation_controller.dart';

/// Persistent shell hosting the four primary tabs under the floating island.
///
/// Tabs are built lazily on first visit and kept alive, so scroll position
/// and in-progress state survive switches. Inactive tabs are faded out,
/// ignore input and have their tickers paused.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(navigationProvider);
    final cartCount = ref.watch(cartCountProvider);
    final overBudget = ref.watch(
      budgetSnapshotProvider.select((b) => b.isOver),
    );

    // The canvas sits outside the Scaffold so the keyboard never resizes it.
    return ObsidianCanvas(
      child: PopScope(
        canPop: tab == AppTab.horizon,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
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
              DecisionNodeScreen.new,
              SmartCartScreen.new,
              SpendingMemoryScreen.new,
            ],
          ),
          bottomNavigationBar: FloatingNavBar(
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
                icon: Icons.hub_outlined,
                activeIcon: Icons.hub_rounded,
                label: 'Decide',
              ),
              NavDestination(
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield_rounded,
                label: 'Guardian',
                badge: cartCount,
                badgeColor: overBudget ? AppColors.rose : AppColors.iris,
              ),
              const NavDestination(
                icon: Icons.donut_large_outlined,
                activeIcon: Icons.donut_large_rounded,
                label: 'Memory',
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
