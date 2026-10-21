import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_sheet.dart';
import '../../../core/widgets/pressable.dart';
import '../../cart/application/budget_controller.dart';

enum MindfulChoice { coolOff, alternative, addAnyway }

/// Friction-by-design: shown when an add would break the monthly ceiling.
///
/// The arithmetic comes first, the recommended path (cool off) is the
/// primary action, and "add anyway" stays available — Clarion informs, it
/// never blocks.
Future<MindfulChoice?> showMindfulCheckSheet({
  required BuildContext context,
  required Product product,
  required BudgetSnapshot budget,
  Product? alternative,
}) {
  final total = budget.committed + product.price;
  final over = total - budget.limit;

  return showClarionSheet<MindfulChoice>(
    context: context,
    eyebrow: 'Mindful check',
    title: '${Fmt.inr(over)} over your ceiling',
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Line('Settled this month', budget.spent),
        _Line('Already in your cart', budget.cart),
        _Line(product.title, product.price),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Divider(),
        ),
        _Line('Month total', total, color: AppColors.rose, strong: true),
        _Line('Ceiling', budget.limit),
        const SizedBox(height: AppSpacing.xxl),
        ClarionButton(
          label: 'Start 24h Cooling Off',
          icon: Icons.hourglass_empty_rounded,
          onPressed: () => Navigator.of(context).pop(MindfulChoice.coolOff),
        ),
        if (alternative != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ClarionButton(
            label: 'See ${alternative.brand} at ${Fmt.inr(alternative.price)}',
            icon: Icons.swap_horiz_rounded,
            tone: ButtonTone.secondary,
            onPressed: () =>
                Navigator.of(context).pop(MindfulChoice.alternative),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Pressable(
            onTap: () => Navigator.of(context).pop(MindfulChoice.addAnyway),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                'Add anyway',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.amount, {this.color, this.strong = false});

  final String label;
  final double amount;
  final Color? color;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: strong ? AppTypography.label : AppTypography.bodySmall,
            ),
          ),
          Text(
            Fmt.inr(amount),
            style: (strong ? AppTypography.metric : AppTypography.metricSmall)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
