import 'package:flutter/material.dart';

import '../../../../core/models/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/price_trend_chart.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../../../core/widgets/section_header.dart';

/// Highlights an item trading meaningfully below its 30-day average.
///
/// Framed as information ("Clarion remembers prices"), never urgency – there
/// is deliberately no countdown or "only N left" pressure.
class PriceMemoryCard extends StatelessWidget {
  const PriceMemoryCard({
    super.key,
    required this.product,
    required this.onTap,
    this.heroTag,
  });

  final Product product;
  final VoidCallback onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final pct = product.discountVsAverage * 100;
    final isLowest = product.price <= product.historyMin;

    return GlassContainer.card(
      tint: AppColors.accent,
      opacity: 0.05,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: AppRadii.smAll,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 17,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text('Price Memory Alert', style: AppTypography.label),
              ),
              TagPill(
                label: '−${Fmt.percent(pct)} vs 30-day avg',
                icon: Icons.trending_down_rounded,
                color: AppColors.fitHigh,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              ProductThumbnail(product: product, size: 60, heroTag: heroTag),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.brand} · ${product.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          Fmt.inr(product.price),
                          style: AppTypography.numeric.copyWith(
                            color: AppColors.fitHigh,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'avg ${Fmt.inr(product.averagePrice30d)}',
                          style: AppTypography.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PriceTrendChart(
            points: product.priceHistory,
            average: product.averagePrice30d,
            height: 64,
            color: AppColors.fitHigh,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  isLowest
                      ? 'Lowest price in 30 days. No rush — Clarion keeps watching.'
                      : 'Below its usual price. No rush — Clarion keeps watching.',
                  style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Review',
                style: AppTypography.label.copyWith(color: AppColors.accent),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
