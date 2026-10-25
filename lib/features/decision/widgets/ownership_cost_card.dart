import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../application/ownership_cost.dart';

/// Sticker price restated as a year of use, plus consumables and accessories.
class OwnershipCostCard extends StatelessWidget {
  const OwnershipCostCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cost = OwnershipCostEngine.of(product);
    final extras = <String>[
      if (cost.consumablesPerYear > 0)
        'Consumables ${Fmt.inr(cost.consumablesPerYear)} a year',
      if (cost.accessories > 0) 'Accessories ${Fmt.inr(cost.accessories)}',
      'A year of ownership ${Fmt.inr(cost.firstYearTotal)}',
    ];
    return TactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COST PER USE', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Text(cost.perUseLabel, style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${cost.usesPerYear} uses a year. ${extras.join(' · ')}.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
