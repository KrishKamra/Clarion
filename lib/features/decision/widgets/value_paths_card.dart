import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../../cart/application/value_alternatives.dart';

/// Refurbished and repair alternatives, with the money and the material saved.
class ValuePathsCard extends StatelessWidget {
  const ValuePathsCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final paths = ValueAlternatives.forProduct(product);
    if (paths.isEmpty) return const SizedBox.shrink();
    return TactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REFURBISHED & REPAIR', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          for (final (index, path) in paths.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.lg),
            Text(
              '${path.kindLabel} saves ${Fmt.inr(path.savingsAgainst(product.price))} at ${path.parity}% parity',
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${path.note} Sustainability ${path.sustainability}.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
