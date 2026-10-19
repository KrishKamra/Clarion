import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../budget/application/budget_controller.dart';

enum MindfulChoice { hold, addAnyway, alternative }

/// Friction-by-design: shown when an add-to-cart would break the budget.
///
/// The recommended action (hold) is the primary button; "add anyway" stays
/// available – Clarion informs, it never blocks.
Future<MindfulChoice?> showMindfulCheckSheet({
  required BuildContext context,
  required Product product,
  required BudgetSnapshot budget,
  Product? alternative,
}) {
  return showGlassSheet<MindfulChoice>(
    context: context,
    builder: (context) {
      final total = budget.committed + product.price;
      final over = total - budget.limit;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.fitLow.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: AppColors.fitLow,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mindful check', style: AppTypography.title),
                    Text(
                      'This would put you ${Fmt.inr(over)} over your ${Fmt.inr(budget.limit)} limit.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _Line('Settled this month', budget.spent),
          _Line('Already in your cart', budget.cart),
          _Line(product.title, product.price),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          _Line('Month total', total, emphasise: true, color: AppColors.fitLow),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Hold to Think (24h)',
            icon: Icons.hourglass_top_rounded,
            onPressed: () => Navigator.of(context).pop(MindfulChoice.hold),
          ),
          if (alternative != null) ...[
            const SizedBox(height: AppSpacing.sm),
            GradientButton(
              label:
                  'See ${alternative.brand} for ${Fmt.inr(alternative.price)}',
              icon: Icons.swap_horiz_rounded,
              variant: GradientButtonVariant.glass,
              onPressed: () =>
                  Navigator.of(context).pop(MindfulChoice.alternative),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => Navigator.of(context).pop(MindfulChoice.addAnyway),
            child: Text(
              'Add anyway',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.amount, {this.emphasise = false, this.color});

  final String label;
  final double amount;
  final bool emphasise;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: emphasise ? AppTypography.label : AppTypography.bodySmall,
            ),
          ),
          Text(
            Fmt.inr(amount),
            style:
                (emphasise ? AppTypography.numeric : AppTypography.numericSmall)
                    .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
