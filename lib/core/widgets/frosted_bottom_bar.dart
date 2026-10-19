import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// Describes a single destination in [FrostedBottomBar].
@immutable
class FrostedBarItem {
  const FrostedBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Small count bubble, hidden when null or zero.
  final int? badge;
  final Color? badgeColor;
}

/// Floating, true-glass navigation bar.
///
/// A gradient pill glides beneath the active destination; inactive items
/// rest in a muted tone. Sized by [AppSpacing.navBarHeight] so tab bodies
/// can reserve clearance via [AppSpacing.navBarClearance].
class FrostedBottomBar extends StatelessWidget {
  const FrostedBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FrostedBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const radius = AppRadii.xl;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.navBarMargin + bottomInset,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: AppGlass.blur(24),
            child: CustomPaint(
              foregroundPainter: GlassBorderPainter(
                radius: radius,
                gradient: AppGlass.borderGradient(intensity: 1.3),
              ),
              child: Container(
                height: AppSpacing.navBarHeight,
                color: AppColors.surface.withValues(alpha: 0.62),
                padding: const EdgeInsets.all(AppSpacing.sm - 2),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slot = constraints.maxWidth / items.length;
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: AppMotion.slow,
                          curve: Curves.easeOutBack,
                          left: slot * currentIndex,
                          top: 0,
                          bottom: 0,
                          width: slot,
                          child: const _ActiveIndicator(),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _BarButton(
                                  item: items[i],
                                  selected: i == currentIndex,
                                  onTap: () => onTap(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveIndicator extends StatelessWidget {
  const _ActiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.42),
            AppColors.secondary.withValues(alpha: 0.22),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
        boxShadow: AppGlass.glow(
          AppColors.primary,
          blurRadius: AppElevation.glowSoft,
          opacity: 0.55,
          offset: Offset.zero,
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FrostedBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.textTertiary;
    final badge = item.badge ?? 0;

    return Semantics(
      selected: selected,
      label: item.label,
      button: true,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: AppMotion.medium,
                  transitionBuilder: (child, a) =>
                      ScaleTransition(scale: a, child: child),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey(selected),
                    color: color,
                    size: 22,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: -9,
                    top: -5,
                    child: _Badge(
                      count: badge,
                      color: item.badgeColor ?? AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppMotion.medium,
              style: AppTypography.caption.copyWith(
                fontSize: 10.5,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(item.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      constraints: const BoxConstraints(minWidth: 17),
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Text(
        '$count',
        style: AppTypography.numericSmall.copyWith(
          fontSize: 9.5,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
