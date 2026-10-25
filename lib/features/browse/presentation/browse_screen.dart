import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/fit_score_gauge.dart';
import '../../../core/widgets/product_artwork.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../../../l10n/l10n.dart';
import '../../decision/presentation/product_decision_screen.dart';
import '../../home/application/intent_controller.dart';
import '../application/browse_controller.dart';
import 'browse_filter_sheet.dart';

/// The whole catalogue, for when the user knows the shelf but not the goal:
/// narrow by category, price, rating, pickup or price dip, and sort. Fit
/// stays visible on every row, and best fit is the default order.
class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  /// Opens Browse, on [category] if given.
  static Future<void> open(BuildContext context, {String? category}) {
    final container = ProviderScope.containerOf(context, listen: false);
    if (category != null) {
      container.read(browseProvider.notifier).showCategory(category);
    }
    return Navigator.of(context).push(fadeRiseRoute(const BrowseScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filters = ref.watch(browseProvider);
    final results = ref.watch(browseResultsProvider);
    final categories = ref.watch(categoriesProvider);
    final controller = ref.read(browseProvider.notifier);

    return SubPage(
      eyebrow: l10n.browseEyebrow,
      title: l10n.browseTitle,
      trailing: Text(
        l10n.resultCount(results.length),
        style: AppTypography.metricSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.md),
              physics: const BouncingScrollPhysics(),
              children: [
                for (final c in [null, ...categories]) ...[
                  DynamicPill(
                    label: c == null
                        ? l10n.allCategories
                        : categoryLabel(l10n, c),
                    size: PillSize.regular,
                    color: AppColors.irisGlow,
                    selected: filters.category == c,
                    onTap: () =>
                        controller.set(filters.copyWith(category: () => c)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                DynamicPill(
                  label: filters.activeCount == 0
                      ? l10n.filters
                      : l10n.filtersActive(filters.activeCount),
                  icon: Icons.tune_rounded,
                  size: PillSize.regular,
                  color: AppColors.irisGlow,
                  selected: filters.activeCount > 0,
                  onTap: () => showBrowseFilterSheet(context),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: DynamicPill(
                    label: l10n.sortedBy(sortLabel(l10n, filters.sort)),
                    icon: Icons.swap_vert_rounded,
                    size: PillSize.regular,
                    color: AppColors.irisGlow,
                    onTap: () => showBrowseSortSheet(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (results.isEmpty)
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: _NoResults(
                onClear: () => controller.set(filters.cleared()),
              ),
            ),
          )
        else
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
            sliver: SliverList.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) =>
                  BrowseRow(key: ValueKey(results[i].id), product: results[i]),
            ),
          ),
      ],
    );
  }
}

/// One product in the list: photo, name, price against its average,
/// rating, and fit.
class BrowseRow extends ConsumerWidget {
  const BrowseRow({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = product;
    final fit = ref.watch(fitProvider(p.id)).score;
    final dip = (p.discountVsAverage * 100).round();
    final tag = 'browse-${p.id}';
    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => ProductDecisionScreen.open(context, p.id, heroTag: tag),
      semanticLabel: l10n.productSummary(
        '${p.brand} ${p.title}',
        Fmt.inr(p.price),
        fit,
      ),
      child: Row(
        children: [
          ProductArtwork(product: p, size: 72, heroTag: tag),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.brand} · ${categoryLabel(l10n, p.category)}'
                      .toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.overline,
                ),
                const SizedBox(height: 2),
                Text(
                  p.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(Fmt.inr(p.price), style: AppTypography.metric),
                    if (dip >= 1)
                      DynamicPill(
                        label: l10n.belowAverage(dip),
                        color: AppColors.emeraldGlow,
                      ),
                    StarRating(rating: p.rating, size: 12),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FitScoreGauge(score: fit, size: 52),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TactileCard(
      material: CardMaterial.vellum,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Text(l10n.noResultsTitle, style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.noResultsBody,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          DynamicPill(
            label: l10n.clearFilters,
            size: PillSize.regular,
            color: AppColors.irisGlow,
            onTap: onClear,
          ),
        ],
      ),
    );
  }
}

/// A catalogue category in the user's language; unknown ones as given.
String categoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      'Bags' => l10n.categoryBags,
      'Audio' => l10n.categoryAudio,
      'Study' => l10n.categoryStudy,
      'Everyday' => l10n.categoryEveryday,
      'Power' => l10n.categoryPower,
      _ => category,
    };

/// The user-facing name of a sort order.
String sortLabel(AppLocalizations l10n, BrowseSort sort) => switch (sort) {
  BrowseSort.bestFit => l10n.sortBestFit,
  BrowseSort.priceLow => l10n.sortPriceLow,
  BrowseSort.priceHigh => l10n.sortPriceHigh,
  BrowseSort.rating => l10n.sortRating,
  BrowseSort.biggestDip => l10n.sortBiggestDip,
};
