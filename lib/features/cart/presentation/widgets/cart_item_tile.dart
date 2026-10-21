import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fit_score_gauge.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/product_artwork.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../core/widgets/dynamic_pill.dart';
import '../../../../data/models/cart_item_model.dart';

/// Intent Cart row: swipe to remove, a quantity stepper, the item's fit, and
/// its intent priority — tap the pill to re-rank how essential it is.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.line,
    required this.onTap,
    required this.onRemove,
    required this.onQuantity,
    required this.onPriority,
  });

  final CartItem line;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantity;
  final VoidCallback onPriority;

  @override
  Widget build(BuildContext context) {
    final p = line.product;

    return Dismissible(
      key: ValueKey('dismiss-${p.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        child: Text(
          'REMOVE',
          style: AppTypography.overline.copyWith(color: AppColors.rose),
        ),
      ),
      child: TactileCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Row(
          children: [
            ProductArtwork(product: p, size: 60, heroTag: 'cart-${p.id}'),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  DynamicPill(
                    label: line.priority.label,
                    color: _priorityColor(line.priority),
                    selected: true,
                    onTap: onPriority,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(Fmt.inr(line.subtotal), style: AppTypography.metric),
                      const Spacer(),
                      _Stepper(quantity: line.quantity, onChanged: onQuantity),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            FitScoreGauge(score: p.fitScore, size: 36, animate: false),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, int next, String label) => Pressable(
      onTap: () => onChanged(next),
      semanticLabel: label,
      scale: 0.85,
      child: SizedBox.square(
        dimension: 28,
        child: Icon(icon, size: 15, color: AppColors.textSecondary),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillAll,
        color: AppColors.vellum,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            quantity == 1 ? Icons.close_rounded : Icons.remove_rounded,
            quantity - 1,
            'Decrease quantity',
          ),
          SizedBox(
            width: 18,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTypography.metricSmall,
            ),
          ),
          button(Icons.add_rounded, quantity + 1, 'Increase quantity'),
        ],
      ),
    );
  }
}

Color _priorityColor(IntentPriority p) => switch (p) {
  IntentPriority.essential => AppColors.emeraldGlow,
  IntentPriority.important => AppColors.irisGlow,
  IntentPriority.niceToHave => AppColors.amber,
};
