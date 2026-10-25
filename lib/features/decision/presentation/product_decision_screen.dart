import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/fit_score_gauge.dart';
import '../../../core/widgets/obsidian_canvas.dart';
import '../../../core/widgets/product_artwork.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tour_target.dart';
import '../../../l10n/l10n.dart';
import '../../home/application/intent_controller.dart';
import '../../navigation/navigation_controller.dart';
import '../../reviews/presentation/reviews_section.dart';
import '../application/compare_controller.dart';
import '../application/share_product.dart';
import '../widgets/buy_or_wait_card.dart';
import '../widgets/decision_drawer.dart';
import '../widgets/explainability_card.dart';
import '../widgets/matte_stage.dart';
import '../widgets/price_band_card.dart';
import '../widgets/spec_list.dart';

/// The explainable decision canvas that replaces a classic product page.
///
/// No urgency, no upsell: the product on a matte stage, its price in
/// context, every point of its fit score, and — in the drawer — what it
/// would do to the month.
class ProductDecisionScreen extends ConsumerWidget {
  const ProductDecisionScreen({
    super.key,
    required this.productId,
    this.heroTag,
  });

  final String productId;
  final Object? heroTag;

  /// Pushes the decision canvas with a short fade-and-rise.
  static Future<void> open(
    BuildContext context,
    String productId, {
    Object? heroTag,
    bool replace = false,
  }) {
    final route = fadeRiseRoute<void>(
      ProductDecisionScreen(productId: productId, heroTag: heroTag),
    );
    final nav = Navigator.of(context);
    return replace ? nav.pushReplacement(route) : nav.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final product = catalog.byId(productId);
    final pair = catalog.pairFor(product.id);
    final insets = MediaQuery.paddingOf(context);

    void openCompare() {
      ref.read(compareProvider.notifier).focusProduct(product.id);
      ref.read(navigationProvider.notifier).select(AppTab.compare);
      Navigator.of(context).popUntil((r) => r.isFirst);
    }

    return ObsidianCanvas(
      glow: product.tone,
      glowIntensity: 0.08,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: DecisionDrawer(product: product),
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    insets.top + AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: MatteStage(product: product, heroTag: heroTag),
                  ),
                ),
                SliverPadding(
                  padding: AppSpacing.screenPadding.copyWith(
                    top: AppSpacing.xxl,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _TitleBlock(product: product),
                      const SizedBox(height: AppSpacing.xxl),
                      TourTargetBox(
                        id: TourTarget.ledger,
                        child: ExplainabilityCard(product: product),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BuyOrWaitCard(product: product),
                      const SizedBox(height: AppSpacing.md),
                      PriceBandCard(product: product),
                      const SizedBox(height: AppSpacing.section),
                      SectionHeader(title: context.l10n.specifications),
                      const SizedBox(height: AppSpacing.xs),
                      SpecList(specs: product.specs),
                      const SizedBox(height: AppSpacing.section),
                      ReviewsSection(productId: product.id),
                      if (pair != null) ...[
                        const SizedBox(height: AppSpacing.section),
                        SectionHeader(title: context.l10n.alsoConsidered),
                        const SizedBox(height: AppSpacing.md),
                        _AlternativeRow(
                          product: product,
                          other: catalog.byId(pair.other(product.id)),
                          onCompare: openCompare,
                        ),
                      ],
                      // Clearance for the decision drawer.
                      SizedBox(height: 200 + insets.bottom),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: insets.top + AppSpacing.lg,
              left: AppSpacing.xxl + AppSpacing.xs,
              right: AppSpacing.xxl + AppSpacing.xs,
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: context.l10n.back,
                    frosted: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) => RoundIconButton(
                      icon: Icons.ios_share_rounded,
                      semanticLabel: context.l10n.share,
                      frosted: true,
                      onPressed: () => shareProduct(
                        context,
                        product,
                        fit: ref.read(fitProvider(product.id)).score,
                      ),
                    ),
                  ),
                  if (pair != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    RoundIconButton(
                      icon: Icons.compare_arrows_rounded,
                      semanticLabel: context.l10n.openInCompare,
                      frosted: true,
                      onPressed: openCompare,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends ConsumerWidget {
  const _TitleBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = product.discountVsAverage * 100;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${product.brand} · ${product.category}'.toUpperCase(),
                style: AppTypography.overline,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(product.title, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${product.rating}★  ·  '
                '${context.l10n.verifiedOwners(product.reviewCount)}',
                semanticsLabel:
                    '${context.l10n.ratedOutOfFive('${product.rating}')}, '
                    '${context.l10n.verifiedOwners(product.reviewCount)}',
                style: AppTypography.metricSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Wraps rather than overflows at large text sizes.
              Wrap(
                spacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Fmt.inr(product.price),
                      style: AppTypography.metricXL,
                    ),
                  ),
                  if (pct.abs() >= 1) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${pct > 0 ? '−' : '+'}${Fmt.percent(pct.abs())} vs 30d avg',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.metricSmall.copyWith(
                          color: pct > 0
                              ? AppColors.emeraldGlow
                              : AppColors.amber,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FitScoreGauge(
          score: ref.watch(fitProvider(product.id)).score,
          size: 88,
        ),
      ],
    );
  }
}

class _AlternativeRow extends ConsumerWidget {
  const _AlternativeRow({
    required this.product,
    required this.other,
    required this.onCompare,
  });

  final Product product;
  final Product other;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diff = other.price - product.price;
    final otherFit = ref.watch(fitProvider(other.id)).score;

    return TactileCard(
      onTap: onCompare,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ProductArtwork(product: other, size: 52),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${other.brand} ${other.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
                const SizedBox(height: 3),
                Text(
                  '$otherFit fit · ${diff < 0 ? '${Fmt.inr(-diff)} less' : '${Fmt.inr(diff)} more'}',
                  style: AppTypography.metricSmall.copyWith(
                    color: diff < 0
                        ? AppColors.emeraldGlow
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Compare',
            style: AppTypography.label.copyWith(color: AppColors.irisGlow),
          ),
        ],
      ),
    );
  }
}
