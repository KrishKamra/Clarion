import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fit_score_dial.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../application/cart_controller.dart';

/// Intent Cart row: swipe to remove, stepper for quantity, and an inline
/// one-tap swap when a verified cheaper alternative exists.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.line,
    required this.onTap,
    required this.onRemove,
    required this.onQuantity,
    this.swap,
    this.onSwap,
  });

  final CartLine line;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantity;
  final SwapSuggestion? swap;
  final VoidCallback? onSwap;

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
        decoration: BoxDecoration(
          borderRadius: AppRadii.lgAll,
          gradient: LinearGradient(
            colors: [
              AppColors.fitLow.withValues(alpha: 0),
              AppColors.fitLow.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.fitLow),
            SizedBox(width: 6),
            Text(
              'Remove',
              style: TextStyle(
                color: AppColors.fitLow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GlassContainer.card(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                ProductThumbnail(product: p, size: 68, heroTag: 'cart-${p.id}'),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.brand.toUpperCase(),
                        style: AppTypography.overline,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            Fmt.inr(line.subtotal),
                            style: AppTypography.numeric,
                          ),
                          const Spacer(),
                          _Stepper(
                            quantity: line.quantity,
                            onChanged: onQuantity,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FitScoreDial(
                  score: p.fitScore,
                  size: 40,
                  showLabel: false,
                  animate: false,
                ),
              ],
            ),
            if (swap != null) ...[
              const SizedBox(height: AppSpacing.md),
              _SwapStrip(swap: swap!, onSwap: onSwap),
            ],
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
    Widget btn(IconData icon, VoidCallback onTap, String label) => Pressable(
      onTap: onTap,
      semanticLabel: label,
      scale: 0.85,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillAll,
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.glassBorderFaint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            () => onChanged(quantity - 1),
            'Decrease quantity',
          ),
          SizedBox(
            width: 18,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTypography.numericSmall,
            ),
          ),
          btn(
            Icons.add_rounded,
            () => onChanged(quantity + 1),
            'Increase quantity',
          ),
        ],
      ),
    );
  }
}

class _SwapStrip extends StatelessWidget {
  const _SwapStrip({required this.swap, required this.onSwap});

  final SwapSuggestion swap;
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.mdAll,
        color: AppColors.accent.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 15,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '${swap.to.brand} ${swap.to.title.split(' ').first} · ',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: 'save ${Fmt.inr(swap.savings)}',
                    style: const TextStyle(
                      color: AppColors.fitHigh,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' · ${swap.parity}% parity'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Pressable(
            onTap: onSwap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: AppRadii.pillAll,
                gradient: AppColors.valueGradient,
              ),
              child: Text(
                'Swap',
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
