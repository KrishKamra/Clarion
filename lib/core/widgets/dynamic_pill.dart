import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// Pill scale: compact metadata badges vs. tappable choice chips.
enum PillSize { compact, regular }

/// One micro-badge for categories, tags, trade-offs and choices.
///
/// * Static (no [onTap]) — a quiet mono badge, e.g. "Pickup in 1.8 km" or
///   "−19% vs 30d", tinted by [color].
/// * Interactive — a selectable chip (intent suggestions, priorities) that
///   ticks with a selection haptic and animates between states.
class DynamicPill extends StatelessWidget {
  const DynamicPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
    this.onTap,
    this.size = PillSize.compact,
  });

  final String label;
  final IconData? icon;

  /// Accent for the badge (static) or the selected state (interactive).
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;
  final PillSize size;

  bool get _interactive => onTap != null;

  @override
  Widget build(BuildContext context) {
    final regular = size == PillSize.regular;
    final active = !_interactive || selected;
    final color = this.color ?? AppColors.textSecondary;

    final Color fill;
    final Color stroke;
    final Color ink;
    if (_interactive) {
      fill = selected ? color.withValues(alpha: 0.16) : AppColors.vellum;
      stroke = selected ? color.withValues(alpha: 0.55) : AppColors.hairline;
      ink = selected ? AppColors.textPrimary : AppColors.textSecondary;
    } else {
      fill = color.withValues(alpha: 0.08);
      stroke = color.withValues(alpha: 0.18);
      ink = color;
    }

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: regular
          ? AppTypography.label.copyWith(fontSize: 13, color: ink)
          : AppTypography.metricSmall.copyWith(
              fontSize: 11,
              letterSpacing: -0.1,
              color: ink,
            ),
    );

    final pill = AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.standard,
      padding: regular
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: regular ? AppRadii.pillAll : AppRadii.xsAll,
        color: fill,
        border: Border.all(color: stroke, width: active ? 1 : 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: regular ? 14 : 12, color: ink),
            const SizedBox(width: 5),
          ],
          Flexible(child: text),
        ],
      ),
    );

    if (!_interactive) return pill;
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        haptic: false,
        scale: 0.96,
        semanticLabel: label,
        child: pill,
      ),
    );
  }
}
