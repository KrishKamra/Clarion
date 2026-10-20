import 'package:flutter/material.dart';

import '../../../../core/models/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fit_dial.dart';
import '../../../../core/widgets/product_artwork.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tactile_card.dart';

/// One entry in the Curated Fit Stream: the product, its fit dial, its
/// strongest reason, its honest compromise, and where to pick it up.
///
/// Raised material (no blur) — it repeats inside a scroll view.
class FitStreamCard extends StatelessWidget {
  const FitStreamCard({
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
    final p = product;
    final reason = p.matches.reduce((a, b) => a.points >= b.points ? a : b);
    final tradeoff = p.tradeoffs.isEmpty ? null : p.tradeoffs.first;
    final discount = p.discountVsAverage;

    return TactileCard(
      onTap: onTap,
      semanticLabel: '${p.title}, ${p.fitScore} percent fit',
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProductArtwork(product: p, size: 68, heroTag: heroTag),
              const SizedBox(width: AppSpacing.md + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.brand.toUpperCase(), style: AppTypography.overline),
                    const SizedBox(height: 3),
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Row(
                      children: [
                        Text(Fmt.inr(p.price), style: AppTypography.metric),
                        if (discount >= 0.03) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              '−${Fmt.percent(discount * 100)} vs 30d',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.metricSmall.copyWith(
                                color: AppColors.emeraldGlow,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FitDial(score: p.fitScore, size: 56),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          _Bullet(factor: reason),
          if (tradeoff != null) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            _Bullet(factor: tradeoff),
          ],
          if (p.pickup != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MetaTag(
                      label: 'Pickup today · ${p.pickup!.label}',
                      icon: Icons.storefront_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A verified reason or trade-off with its signed contribution in mono.
class _Bullet extends StatelessWidget {
  const _Bullet({required this.factor});

  final FitFactor factor;

  @override
  Widget build(BuildContext context) {
    final color = factor.isTradeoff ? AppColors.amber : AppColors.emeraldGlow;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 30,
          child: Text(
            Fmt.points(factor.points),
            style: AppTypography.metricSmall.copyWith(color: color),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '${factor.title}  ',
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: factor.detail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Shown when nothing in the catalogue honours the stated ceiling.
class FitStreamEmpty extends StatelessWidget {
  const FitStreamEmpty({super.key, this.budget});

  final double? budget;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      material: CardMaterial.vellum,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Text(
            budget == null
                ? 'Nothing fits that yet'
                : 'Nothing fits ${Fmt.inr(budget!)} yet',
            style: AppTypography.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Clarion won’t stretch your limits to show you something. '
            'Try loosening one constraint.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
