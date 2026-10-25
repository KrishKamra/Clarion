import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../application/impulse_risk.dart';

/// The adaptive hold: what raised or lowered it for this product.
class ImpulseRiskCard extends ConsumerWidget {
  const ImpulseRiskCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessment = ref.watch(impulseAssessmentProvider(product.id));
    final tone = assessment.score >= 45
        ? AppColors.rose
        : assessment.hold.inHours < 24
        ? AppColors.emeraldGlow
        : AppColors.textSecondary;
    return TactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IMPULSE RISK', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Score ${assessment.score} · ${assessment.hold.inHours}-hour hold',
            style: AppTypography.title.copyWith(color: tone),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            assessment.isBaseline
                ? 'Rapid adds, late-night browsing and large purchases lengthen the hold. A small, calm one shortens it.'
                : assessment.summary,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
