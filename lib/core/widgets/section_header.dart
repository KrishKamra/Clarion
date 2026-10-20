import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// Editorial section rule: a mono label, a hairline running to the edge,
/// and an optional quiet action. Separates content without boxing it.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    this.caption,
    this.actionLabel,
    this.onAction,
  });

  final String label;
  final String? caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.toUpperCase(), style: AppTypography.overline),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: Divider()),
            if (actionLabel != null) ...[
              const SizedBox(width: AppSpacing.md),
              Pressable(
                onTap: onAction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    actionLabel!,
                    style: AppTypography.label.copyWith(
                      color: AppColors.irisGlow,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(caption!, style: AppTypography.caption),
        ],
      ],
    );
  }
}

/// Compact metadata label, e.g. "Pickup · 1.8 km" or "−9% vs 30-day".
class MetaTag extends StatelessWidget {
  const MetaTag({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.textSecondary,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadii.xsAll,
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.metricSmall.copyWith(
                fontSize: 11,
                color: color,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
