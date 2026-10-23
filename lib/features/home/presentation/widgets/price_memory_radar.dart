import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/dynamic_pill.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/product_artwork.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/models/product_model.dart';
import '../../../decision/presentation/product_decision_screen.dart';

/// Price Memory Radar: tracked items trading meaningfully below their
/// 30-day moving average.
///
/// Framed as information, never urgency — there is no countdown and no
/// "only N left". One card, ruled rows, deepest discount first.
class PriceMemoryRadar extends StatelessWidget {
  const PriceMemoryRadar({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (final (i, p) in products.indexed) ...[
            if (i > 0) const Divider(),
            _RadarRow(product: p),
          ],
        ],
      ),
    );
  }
}

class _RadarRow extends StatelessWidget {
  const _RadarRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final tag = 'radar-${p.id}';
    return Pressable(
      onTap: () => ProductDecisionScreen.open(context, p.id, heroTag: tag),
      semanticLabel:
          '${p.title}: good price, ${Fmt.inr(p.price)} versus average '
          '${Fmt.inr(p.averagePrice30d)}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            ProductArtwork(product: p, size: 44, heroTag: tag),
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGlow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            text: 'Good price — ',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.emeraldGlow,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${Fmt.inr(p.price)} vs avg ${Fmt.inr(p.averagePrice30d)}',
                                style: AppTypography.metricSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DynamicPill(
              label: '−${Fmt.percent(p.discountVsAverage * 100)}',
              color: AppColors.emeraldGlow,
            ),
          ],
        ),
      ),
    );
  }
}
