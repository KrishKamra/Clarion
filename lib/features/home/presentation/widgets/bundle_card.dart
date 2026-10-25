import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../cart/application/cart_controller.dart';
import '../../application/bundle_planner.dart';

/// The best-fitting set under the goal's ceiling, rather than a ranked list.
class BundleCard extends ConsumerWidget {
  const BundleCard({super.key, required this.plan});

  final BundlePlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TactileCard(
      material: CardMaterial.floating,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BUDGET-OPTIMAL SET', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${Fmt.inr(plan.total)} of ${Fmt.inr(plan.ceiling)} · fit ${plan.fit}',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The best combination under the ceiling, one item per category.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in plan.items) ...[
            Text(
              '${item.title} · ${Fmt.inr(item.price)}',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          ClarionButton(
            label: 'Add this set',
            tone: ButtonTone.secondary,
            onPressed: () {
              final cart = ref.read(cartProvider.notifier);
              for (final item in plan.items) {
                cart.add(item.id);
              }
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}
