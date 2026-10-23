import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'frosted_chrome.dart';
import 'pressable.dart';

/// One destination in the [FloatingNavCapsule].
@immutable
class NavDestination {
  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
    this.badgeColor,
    this.dot,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Count bubble; hidden at zero.
  final int badge;

  /// Defaults to iris.
  final Color? badgeColor;

  /// Unobtrusive status dot (e.g. a cooling-off item awaiting a decision);
  /// hidden when null.
  final Color? dot;
}

/// The translucent spatial capsule that hosts primary navigation.
///
/// Frosted glass — affordable here because the capsule is fixed chrome.
/// The active pill is magnetic: in flight it stretches toward its target
/// and settles back to size on arrival, with a soft iris halo beneath.
class FloatingNavCapsule extends StatelessWidget {
  const FloatingNavCapsule({
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
                    _MagneticPill(index: currentIndex, slot: slot),
                    Row(
                      children: [
                        for (var i = 0; i < destinations.length; i++)
                          Expanded(
                            child: _NavButton(
                              destination: destinations[i],
                              selected: i == currentIndex,
                              onTap: () {
                                if (i == currentIndex) return;
                                HapticFeedback.selectionClick();
                                onSelected(i);
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

class _MagneticPill extends StatelessWidget {
  const _MagneticPill({required this.index, required this.slot});

  final int index;
  final double slot;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: index.toDouble()),
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      builder: (context, position, child) {
        // Stretch peaks mid-flight between two slots and vanishes at rest.
        final travel = (position - position.roundToDouble()).abs() * 2;
        final stretch = 1 + 0.35 * math.sin(travel * math.pi / 2);
        final width = slot * stretch;
        return Positioned(
          left: slot * position - (width - slot) / 2,
          width: width,
          top: 0,
          bottom: 0,
          child: child!,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          gradient: AppDecorations.backlight(
            AppColors.irisGlow,
            intensity: 0.3,
          ),
          border: Border.all(
            color: AppColors.irisGlow.withValues(alpha: 0.35),
            width: 0.75,
          ),
        ),
      ),
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
        haptic: false, // the capsule ticks with a selection haptic
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
                      color: destination.badgeColor ?? AppColors.iris,
                    ),
                  )
                else if (destination.dot != null)
                  Positioned(
                    right: -3,
                    top: -1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: destination.dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppMotion.medium,
              style: AppTypography.overline.copyWith(
                fontSize: 10,
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
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.onAccent,
          height: 1,
        ),
      ),
    );
  }
}
