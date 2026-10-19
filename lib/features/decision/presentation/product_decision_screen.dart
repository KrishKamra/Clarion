import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/fit_score_dial.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/section_header.dart';
import '../../navigation/navigation_controller.dart';
import '../application/compare_controller.dart';
import '../widgets/decision_action_bar.dart';
import '../widgets/explainability_card.dart';
import '../widgets/price_history_card.dart';
import '../widgets/product_gallery.dart';
import '../widgets/spec_grid.dart';

/// Decision Support View – an explainable replacement for a classic PDP.
///
/// Instead of persuading, it lays out the evidence: price memory, an
/// itemised fit score with trade-offs, and the purchase's budget impact.
class ProductDecisionScreen extends ConsumerWidget {
  const ProductDecisionScreen({
    super.key,
    required this.productId,
    this.heroTag,
  });

  final String productId;
  final Object? heroTag;

  /// Pushes the decision view with a soft fade-up transition.
  static Future<void> open(
    BuildContext context,
    String productId, {
    Object? heroTag,
    bool replace = false,
  }) {
    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) =>
          ProductDecisionScreen(productId: productId, heroTag: heroTag),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.emphasized,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
    final nav = Navigator.of(context);
    return replace ? nav.pushReplacement(route) : nav.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = MockCatalog.byId(productId);
    final topInset = MediaQuery.paddingOf(context).top;
    final hasPair = MockCatalog.comparePairs.any(
      (p) => p.leftId == product.id || p.rightId == product.id,
    );

    void openCompare() {
      ref.read(compareProvider.notifier).focusProduct(product.id);
      ref.read(navigationProvider.notifier).select(AppTab.compare);
      Navigator.of(context).popUntil((r) => r.isFirst);
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundDeep,
      bottomNavigationBar: DecisionActionBar(product: product),
      body: AmbientBackground(
        primaryGlow: product.palette.first,
        secondaryGlow: product.palette.last,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    topInset + AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ProductGallery(product: product, heroTag: heroTag),
                  ),
                ),
                SliverPadding(
                  padding: AppSpacing.screenPadding.copyWith(
                    top: AppSpacing.xl,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _TitleBlock(product: product),
                      const SizedBox(height: AppSpacing.xl),
                      ExplainabilityCard(product: product),
                      const SizedBox(height: AppSpacing.lg),
                      PriceHistoryCard(product: product),
                      const SizedBox(height: AppSpacing.xxl),
                      const SectionHeader(title: 'Key specs'),
                      const SizedBox(height: AppSpacing.md),
                      SpecGrid(specs: product.specs),
                      if (hasPair) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        _AlternativeCard(
                          product: product,
                          onCompare: openCompare,
                        ),
                      ],
                      // Clearance for the sticky decision bar.
                      SizedBox(
                        height: 190 + MediaQuery.paddingOf(context).bottom,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: topInset + AppSpacing.lg,
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    blur: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  if (hasPair)
                    GlassIconButton(
                      icon: Icons.balance_rounded,
                      tooltip: 'Compare',
                      blur: true,
                      onPressed: openCompare,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.overline.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(product.title, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.fitMid,
                  ),
                  const SizedBox(width: 3),
                  Text('${product.rating}', style: AppTypography.numericSmall),
                  Flexible(
                    child: Text(
                      '  ·  ${product.reviewCount} verified reviews',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    Fmt.inr(product.price),
                    style: AppTypography.numericLarge,
                  ),
                  if (pct.abs() >= 1)
                    TagPill(
                      label: pct > 0
                          ? '−${Fmt.percent(pct)} vs 30-day avg'
                          : '+${Fmt.percent(-pct)} vs 30-day avg',
                      color: pct > 0 ? AppColors.fitHigh : AppColors.fitMid,
                      icon: pct > 0
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      dense: true,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FitScoreDial(score: product.fitScore, size: 84),
      ],
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.product, required this.onCompare});

  final Product product;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final pair = MockCatalog.comparePairs.firstWhere(
      (p) => p.leftId == product.id || p.rightId == product.id,
    );
    final other = MockCatalog.byId(
      pair.leftId == product.id ? pair.rightId : pair.leftId,
    );
    final diff = other.price - product.price;

    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onCompare,
      child: Row(
        children: [
          ProductThumbnail(product: other, size: 52),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALSO CONSIDERED', style: AppTypography.overline),
                const SizedBox(height: 3),
                Text(
                  '${other.brand} ${other.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
                const SizedBox(height: 2),
                Text(
                  '${other.fitScore}% match · ${diff < 0 ? '${Fmt.inr(-diff)} cheaper' : '${Fmt.inr(diff)} more'}',
                  style: AppTypography.caption.copyWith(
                    color: diff < 0
                        ? AppColors.fitHigh
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Compare',
            style: AppTypography.label.copyWith(color: AppColors.accent),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
