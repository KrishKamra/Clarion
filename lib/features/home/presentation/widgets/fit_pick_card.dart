import 'package:flutter/material.dart';

import '../../../../core/models/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fit_score_dial.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../../../core/widgets/section_header.dart';

/// Card in the "Personal Fit Picks" carousel.
///
/// Faux glass (no backdrop blur) because it repeats inside a scroll view.
class FitPickCard extends StatelessWidget {
  const FitPickCard({
    super.key,
    required this.product,
    required this.onTap,
    this.heroTag,
  });

  static const double width = 232;
  static const double height = 348;

  final Product product;
  final VoidCallback onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final fitColor = AppColors.forFitScore(product.fitScore);
    final discount = product.discountVsAverage;

    return GlassContainer.card(
      width: width,
      height: height,
      borderRadius: AppRadii.xl - 4,
      padding: const EdgeInsets.all(AppSpacing.md - 2),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 152,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ProductThumbnail(
                    product: product,
                    borderRadius: AppRadii.lg - 2,
                    heroTag: heroTag,
                    iconScale: 0.38,
                  ),
                ),
                if (product.storeDistanceKm != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: TagPill(
                      label: '${product.storeDistanceKm} km',
                      icon: Icons.near_me_rounded,
                      dense: true,
                    ),
                  ),
                Positioned(
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundDeep.withValues(alpha: 0.78),
                      border: Border.all(
                        color: fitColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: FitScoreDial(score: product.fitScore, size: 62),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand.toUpperCase(),
                  style: AppTypography.overline,
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 42,
                  child: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(fontSize: 15),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(Fmt.inr(product.price), style: AppTypography.numeric),
                    if (discount >= 0.05) ...[
                      const SizedBox(width: AppSpacing.sm),
                      TagPill(
                        label: '−${Fmt.percent(discount * 100)}',
                        color: AppColors.fitHigh,
                        dense: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: fitColor.withValues(alpha: 0.08),
              borderRadius: AppRadii.smAll,
              border: Border.all(color: fitColor.withValues(alpha: 0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: fitColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    product.fitTagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
