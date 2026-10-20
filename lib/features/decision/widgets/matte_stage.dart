import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/product_artwork.dart';

/// The product on its matte stage, with a local-pickup plate in the corner.
///
/// The plate is vellum rather than frosted glass: the stage scrolls, and
/// blur is reserved for fixed chrome.
class MatteStage extends StatelessWidget {
  const MatteStage({
    super.key,
    required this.product,
    this.heroTag,
    this.height = 320,
  });

  final Product product;
  final Object? heroTag;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pickup = product.pickup;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ProductArtwork(
              product: product,
              radius: AppRadii.xl,
              heroTag: heroTag,
              glyphScale: 0.36,
            ),
          ),
          if (pickup != null)
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _PickupPlate(pickup: pickup),
            ),
        ],
      ),
    );
  }
}

class _PickupPlate extends StatelessWidget {
  const _PickupPlate({required this.pickup});

  final PickupPoint pickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.canvas.withValues(alpha: 0.72),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.rim),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 15,
            color: AppColors.emeraldGlow,
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In stock · Pickup today',
                style: AppTypography.label.copyWith(fontSize: 12.5),
              ),
              Text(
                pickup.label,
                style: AppTypography.metricSmall.copyWith(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
