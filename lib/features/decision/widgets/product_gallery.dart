import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_glass.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/product_thumbnail.dart';

/// Swipeable product imagery with a frosted local-pickup badge.
class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.product,
    this.heroTag,
    this.height = 340,
  });

  final Product product;
  final Object? heroTag;
  final double height;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  static const _views = [
    (label: 'Overview', scale: 0.42),
    (label: 'Detail', scale: 0.68),
    (label: 'Scale', scale: 0.3),
  ];

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _views.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => ProductThumbnail(
                    product: product,
                    borderRadius: AppRadii.xl,
                    iconScale: _views[i].scale,
                    heroTag: i == 0 ? widget.heroTag : null,
                  ),
                ),
                if (product.storeDistanceKm != null)
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: _PickupBadge(distanceKm: product.storeDistanceKm!),
                  ),
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: _ViewLabel(label: _views[_page].label),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _views.length; i++)
              AnimatedContainer(
                duration: AppMotion.medium,
                curve: AppMotion.standard,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.pillAll,
                  gradient: i == _page ? AppColors.brandGradient : null,
                  color: i == _page
                      ? null
                      : Colors.white.withValues(alpha: 0.18),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// True-glass badge – a single, static overlay, so the blur cost is fine.
class _PickupBadge extends StatelessWidget {
  const _PickupBadge({required this.distanceKm});

  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.mdAll,
      child: BackdropFilter(
        filter: AppGlass.blur(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDeep.withValues(alpha: 0.4),
            borderRadius: AppRadii.mdAll,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 14,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$distanceKm km away',
                    style: AppTypography.label.copyWith(fontSize: 12.5),
                  ),
                  Text(
                    'In stock · Pickup today',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.5,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewLabel extends StatelessWidget {
  const _ViewLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep.withValues(alpha: 0.55),
        borderRadius: AppRadii.pillAll,
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        child: Text(
          label,
          key: ValueKey(label),
          style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
