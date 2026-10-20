import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/tactile_card.dart';

/// "Why This Fits You" — the fit score as a ledger. Every signed line is
/// shown, and the total is printed beneath them, so the number is never
/// asserted, only derived.
class ExplainabilityCard extends StatelessWidget {
  const ExplainabilityCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forFit(product.fitScore);

    return TactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('WHY THIS FITS YOU', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.xs),
          Text('Every point, accounted for.', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          for (final (i, f) in product.fitFactors.indexed) ...[
            if (i > 0) const Divider(),
            _LedgerRow(factor: f),
          ],
          const SizedBox(height: AppSpacing.sm),
          _Total(score: product.fitScore, color: color),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.factor});

  final FitFactor factor;

  @override
  Widget build(BuildContext context) {
    final color = factor.isTradeoff ? AppColors.amber : AppColors.emeraldGlow;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              Fmt.points(factor.points),
              style: AppTypography.metric.copyWith(color: color, height: 1.3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(factor.title, style: AppTypography.label),
                const SizedBox(height: 2),
                Text(factor.detail, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The sum line, backlit in the fit colour — the one place on the card
/// where colour pools, because it is the conclusion.
class _Total extends StatelessWidget {
  const _Total({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.mdAll,
        gradient: AppDecorations.backlight(color, intensity: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '=',
              style: AppTypography.metric.copyWith(color: color),
            ),
          ),
          Expanded(
            child: Text('Personal fit score', style: AppTypography.label),
          ),
          Text(
            '$score',
            style: AppTypography.metricLarge.copyWith(color: color),
          ),
          Text(
            '/100',
            style: AppTypography.metricSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
