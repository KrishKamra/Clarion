import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../budget/application/budget_controller.dart';

/// The month's envelope: a backlit ring (outer = committed incl. cart,
/// inner = settled) beside the ceiling and its parts.
class EnvelopeCard extends StatelessWidget {
  const EnvelopeCard({
    super.key,
    required this.snapshot,
    required this.onEditCeiling,
  });

  final BudgetSnapshot snapshot;
  final VoidCallback onEditCeiling;

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final color = AppColors.forBudgetRatio(s.ratio);

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ProgressRing(
                  value: s.ratio,
                  color: color,
                  size: 112,
                  strokeWidth: 4,
                  backlit: true,
                ),
                ProgressRing(
                  value: s.spent / s.limit,
                  color: AppColors.textSecondary,
                  size: 92,
                  strokeWidth: 2,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Fmt.percent(s.ratio * 100),
                      style: AppTypography.metricLarge.copyWith(color: color),
                    ),
                    Text(
                      'COMMITTED',
                      style: AppTypography.overline.copyWith(fontSize: 8.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pressable(
                  onTap: onEditCeiling,
                  semanticLabel: 'Edit monthly ceiling',
                  child: Row(
                    children: [
                      Text('CEILING', style: AppTypography.overline),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(Fmt.inr(s.limit), style: AppTypography.metricLarge),
                const SizedBox(height: AppSpacing.md),
                _Line('Settled', Fmt.inr(s.spent), AppColors.textSecondary),
                const SizedBox(height: AppSpacing.xs),
                _Line('With cart', Fmt.inr(s.committed), color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 2, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: AppTypography.caption)),
        Text(value, style: AppTypography.metricSmall),
      ],
    );
  }
}
