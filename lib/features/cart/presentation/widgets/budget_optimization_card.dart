import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../../budget/application/budget_controller.dart';
import '../../application/cart_controller.dart';

/// Appears when the cart breaks the monthly limit and proposes the single
/// highest-impact swap to fix it.
class BudgetOptimizationCard extends StatelessWidget {
  const BudgetOptimizationCard({
    super.key,
    required this.budget,
    required this.suggestion,
    required this.onSwap,
    required this.onCompare,
  });

  final BudgetSnapshot budget;
  final SwapSuggestion? suggestion;
  final VoidCallback onSwap;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final remainingOver = s == null ? budget.overBy : budget.overBy - s.savings;

    return GlassContainer.card(
      tint: AppColors.fitLow,
      opacity: 0.07,
      borderRadius: AppRadii.xl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.fitLow.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.fitLow,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  "You're ${Fmt.inr(budget.overBy)} over your monthly budget.",
                  style: AppTypography.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (s == null)
            Text(
              'No verified alternatives for these items. Consider holding a nice-to-have for 24 h before you decide.',
              style: AppTypography.bodySmall,
            )
          else ...[
            Row(
              children: [
                ProductThumbnail(product: s.from, size: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: ShaderMask(
                    shaderCallback: AppColors.valueGradient.createShader,
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                ProductThumbnail(product: s.to, size: 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save ${Fmt.inr(s.savings)}',
                        style: AppTypography.numeric.copyWith(
                          color: AppColors.fitHigh,
                        ),
                      ),
                      Text(
                        '${s.parity}% feature parity · verified',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text.rich(
              TextSpan(
                style: AppTypography.bodySmall.copyWith(fontSize: 13.5),
                children: [
                  const TextSpan(text: 'Swap '),
                  TextSpan(
                    text:
                        '${s.from.brand} ${s.from.title} (${Fmt.inr(s.from.price)})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' with verified alternative '),
                  TextSpan(
                    text:
                        '${s.to.brand} ${s.to.title} (${Fmt.inr(s.to.price)})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' to save ${Fmt.inr(s.savings)} with ${s.parity}% feature parity. ',
                  ),
                  TextSpan(
                    text: remainingOver <= 0
                        ? 'That brings you back within budget.'
                        : 'You\'d still be ${Fmt.inr(remainingOver)} over.',
                    style: TextStyle(
                      color: remainingOver <= 0
                          ? AppColors.fitHigh
                          : AppColors.fitMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GradientButton(
                    label: 'Swap & save ${Fmt.inr(s.savings)}',
                    icon: Icons.swap_horiz_rounded,
                    height: 48,
                    horizontalPadding: AppSpacing.md,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), AppColors.accent],
                    ),
                    onPressed: onSwap,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: 'Compare',
                    variant: GradientButtonVariant.glass,
                    height: 48,
                    horizontalPadding: AppSpacing.md,
                    onPressed: onCompare,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
