import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'frosted_chrome.dart';
import 'pressable.dart';

/// One destination in the [FloatingNavBar].
@immutable
class NavDestination {
  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
    this.badgeColor = AppColors.irisGlow,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Count bubble; hidden at zero.
  final int badge;
  final Color badgeColor;
}

/// The floating glass island that hosts primary navigation.
///
/// A frosted capsule (fixed chrome, so the backdrop blur is affordable)
/// with a magnetic indicator: as it travels between tabs it stretches
/// toward its destination and settles back to size on arrival.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const double _inset = 5;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.navBarMargin + bottom,
      ),
      child: FrostedChrome(
        borderRadius: AppRadii.pillAll,
        floating: true,
        child: SizedBox(
          height: AppSpacing.navBarHeight,
          child: Padding(
            padding: const EdgeInsets.all(_inset),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slot = constraints.maxWidth / destinations.length;
                return Stack(
                  children: [
                    _MagneticIndicator(index: currentIndex, slot: slot),
                    Row(
                      children: [
                        for (var i = 0; i < destinations.length; i++)
                          Expanded(
                            child: _NavButton(
                              destination: destinations[i],
                              selected: i == currentIndex,
                              onTap: () {
                                if (i != currentIndex) onSelected(i);
                              },
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
    );
  }
}

class _MagneticIndicator extends StatelessWidget {
  const _MagneticIndicator({required this.index, required this.slot});

  final int index;
  final double slot;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: index.toDouble()),
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      builder: (context, position, _) {
        // Stretch peaks mid-flight between two slots and vanishes at rest.
        final travel = (position - position.roundToDouble()).abs() * 2;
        final stretch = 1 + 0.35 * math.sin(travel * math.pi / 2);
        final width = slot * stretch;
        return Positioned(
          left: slot * position - (width - slot) / 2,
          width: width,
          top: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.pillAll,
              color: AppColors.iris.withValues(alpha: 0.18),
              border: Border.all(
                color: AppColors.irisGlow.withValues(alpha: 0.32),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.textTertiary;

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? destination.activeIcon : destination.icon,
                  color: color,
                  size: 20,
                ),
                if (destination.badge > 0)
                  Positioned(
                    right: -10,
                    top: -6,
                    child: _Badge(
                      count: destination.badge,
                      color: destination.badgeColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppMotion.medium,
              style: AppTypography.overline.copyWith(
                fontSize: 9,
                letterSpacing: 0.6,
                color: color,
              ),
              child: Text(destination.label.toUpperCase(), maxLines: 1),
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
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Text(
        '$count',
        style: AppTypography.metricSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.onAccent,
          height: 1,
        ),
      ),
    );
  }
}
