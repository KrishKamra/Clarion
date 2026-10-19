import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/fit_score_dial.dart';
import '../../../core/widgets/glass_container.dart';

/// "Why We Recommend This" – every point of the fit score, itemised.
///
/// Ends with a contribution bar so the user can see at a glance how much
/// of the score each factor earned (or cost).
class ExplainabilityCard extends StatelessWidget {
  const ExplainabilityCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      tint: AppColors.primary,
      opacity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: AppColors.brandGradient.createShader,
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why we recommend this',
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      'Every point, accounted for',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              FitScoreDial(score: product.fitScore, size: 48, showLabel: false),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final f in product.fitFactors) _FactorRow(factor: f),
          const SizedBox(height: AppSpacing.md),
          _ContributionBar(
            factors: product.fitFactors,
            score: product.fitScore,
          ),
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor});

  final FitFactor factor;

  @override
  Widget build(BuildContext context) {
    final isTradeoff = factor.kind == FitFactorKind.tradeoff;
    final color = isTradeoff ? AppColors.fitMid : AppColors.fitHigh;
    final points = factor.points;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(
              isTradeoff ? Icons.priority_high_rounded : Icons.check_rounded,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '${factor.title}: ',
                style: AppTypography.label.copyWith(
                  color: isTradeoff ? AppColors.fitMid : AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: factor.detail,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: AppRadii.pillAll,
              color: (points < 0 ? AppColors.fitLow : color).withValues(
                alpha: 0.12,
              ),
            ),
            child: Text(
              '${points > 0 ? '+' : '−'}${points.abs()} pts',
              style: AppTypography.numericSmall.copyWith(
                fontSize: 11.5,
                color: points < 0 ? AppColors.fitLow : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionBar extends StatelessWidget {
  const _ContributionBar({required this.factors, required this.score});

  final List<FitFactor> factors;
  final int score;

  static const _palette = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.fitHigh,
    Color(0xFF38BDF8),
  ];

  @override
  Widget build(BuildContext context) {
    final positives = factors.where((f) => f.points > 0).toList();
    final penalty = factors
        .where((f) => f.points < 0)
        .fold<int>(0, (sum, f) => sum + f.points.abs());
    final gross = positives.fold<int>(0, (s, f) => s + f.points);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadii.pillAll,
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (var i = 0; i < positives.length; i++)
                  Expanded(
                    flex: positives[i].points,
                    child: Container(
                      margin: const EdgeInsets.only(right: 2),
                      color: _palette[i % _palette.length],
                    ),
                  ),
                if (penalty > 0)
                  Expanded(
                    flex: penalty,
                    child: Container(color: AppColors.fitLow),
                  ),
                if (gross + penalty < 100)
                  Expanded(
                    flex: 100 - gross - penalty,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$gross pts earned',
                  children: [
                    if (penalty > 0)
                      TextSpan(
                        text: '  −  $penalty trade-off',
                        style: const TextStyle(color: AppColors.fitLow),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '= $score% match',
              style: AppTypography.numericSmall.copyWith(
                color: AppColors.forFitScore(score),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
