import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/dynamic_pill.dart';
import '../../../../core/widgets/fit_score_gauge.dart';
import '../../../../core/widgets/product_artwork.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/trade_off_item.dart';
import '../../../decision/presentation/product_decision_screen.dart';

/// Personal Fit Stream: a horizontal carousel of candidates.
///
/// Progressive disclosure: each card surfaces only the fit score, a single
/// line of rationale and the top two weighted factors. The full ledger and
/// specifications live one tap away on the decision canvas.
class FitStream extends StatelessWidget {
  const FitStream({super.key, required this.products, this.budget});

  final List<Product> products;

  /// The intent's ceiling, if any — used for the empty state.
  final double? budget;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: _Empty(budget: budget),
      );
    }

    return SizedBox(
      height: FitStreamCard.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final p = products[i];
          final tag = 'stream-${p.id}';
          return FitStreamCard(
            key: ValueKey(p.id),
            product: p,
            heroTag: tag,
            onTap: () =>
                ProductDecisionScreen.open(context, p.id, heroTag: tag),
          );
        },
      ),
    );
  }
}

/// One candidate. Matte material, no blur — it repeats in a fast list.
class FitStreamCard extends StatelessWidget {
  const FitStreamCard({
    super.key,
    required this.product,
    required this.onTap,
    this.heroTag,
  });

  static const double width = 264;
  static const double height = 356;

  final Product product;
  final VoidCallback onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final top = <TradeOffItem>[
      p.reasons.first,
      if (p.compromises.isNotEmpty) p.compromises.first,
    ];

    return SizedBox(
      width: width,
      height: height,
      child: TactileCard(
        onTap: onTap,
        semanticLabel: '${p.title}, ${p.fitScore} percent fit',
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 128,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProductArtwork(
                      product: p,
                      radius: AppRadii.md,
                      heroTag: heroTag,
                      glyphScale: 0.4,
                    ),
                  ),
                  if (p.pickup != null)
                    Positioned(
                      left: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: DynamicPill(
                        label: p.pickup!.distanceLabel,
                        icon: Icons.storefront_outlined,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.overline,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(Fmt.inr(p.price), style: AppTypography.metric),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FitScoreGauge(score: p.fitScore, size: 64),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              p.rationale,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption,
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            for (final t in top) _FactorLine(item: t),
          ],
        ),
      ),
    );
  }
}

/// A weighted factor with its signed contribution in mono.
class _FactorLine extends StatelessWidget {
  const _FactorLine({required this.item});

  final TradeOffItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isPositive ? AppColors.emeraldGlow : AppColors.amber;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              Fmt.points(item.weight),
              style: AppTypography.metricSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({this.budget});

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
