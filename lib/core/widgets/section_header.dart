import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// Section anchor: an optional mono eyebrow, a 18px title, an optional
/// caption and a quiet trailing action. Hierarchy comes from type and
/// space — no rules or boxes needed.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.caption,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? eyebrow;
  final String? caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!.toUpperCase(), style: AppTypography.overline),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(title, style: AppTypography.title),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(caption!, style: AppTypography.bodySmall),
              ],
            ],
          ),
        ),
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
    );
  }
}
