import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_sheet.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../l10n/l10n.dart';
import '../application/browse_controller.dart';
import 'browse_screen.dart';

/// Filters apply as they change, so the count on the button is always the
/// number of products the user will see.
Future<void> showBrowseFilterSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: context.l10n.browseTitle,
    title: context.l10n.filters,
    builder: (_) => const _FilterSheet(),
  );
}

Future<void> showBrowseSortSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: context.l10n.browseTitle,
    title: context.l10n.sortTitle,
    builder: (_) => const _SortSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  static const List<double> ratings = [4.0, 4.3, 4.5];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filters = ref.watch(browseProvider);
    final count = ref.watch(browseResultsProvider).length;
    final ceiling = ref.watch(priceCeilingProvider);
    final controller = ref.read(browseProvider.notifier);
    void set(BrowseFilters f) => controller.set(f);
    final maxPrice = filters.maxPrice ?? ceiling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.maxPrice, style: AppTypography.label)),
            Text(
              filters.maxPrice == null ? l10n.anyPrice : Fmt.inr(maxPrice),
              style: AppTypography.metricSmall,
            ),
          ],
        ),
        Slider(
          value: maxPrice,
          min: 300,
          max: ceiling,
          divisions: ((ceiling - 300) / 100).round(),
          label: Fmt.inr(maxPrice),
          semanticFormatterCallback: (v) => Fmt.inr(v),
          onChanged: (v) =>
              set(filters.copyWith(maxPrice: () => v >= ceiling ? null : v)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.minRating, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final r in [null, ...ratings])
              DynamicPill(
                label: r == null ? l10n.anyRating : l10n.ratingAtLeast('$r'),
                icon: r == null ? null : Icons.star_rounded,
                size: PillSize.regular,
                color: AppColors.irisGlow,
                selected: filters.minRating == r,
                onTap: () => set(filters.copyWith(minRating: () => r)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.show, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            DynamicPill(
              label: l10n.pickupNearby,
              icon: Icons.storefront_outlined,
              size: PillSize.regular,
              color: AppColors.irisGlow,
              selected: filters.pickupOnly,
              onTap: () =>
                  set(filters.copyWith(pickupOnly: !filters.pickupOnly)),
            ),
            DynamicPill(
              label: l10n.belowAverageFilter,
              icon: Icons.trending_down_rounded,
              size: PillSize.regular,
              color: AppColors.emeraldGlow,
              selected: filters.belowAverageOnly,
              onTap: () => set(
                filters.copyWith(belowAverageOnly: !filters.belowAverageOnly),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        ClarionButton(
          label: l10n.showResults(count),
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (filters.activeCount > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          ClarionButton(
            label: l10n.clearFilters,
            tone: ButtonTone.secondary,
            onPressed: () => set(filters.cleared()),
          ),
        ],
      ],
    );
  }
}

class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filters = ref.watch(browseProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final sort in BrowseSort.values)
          Semantics(
            selected: filters.sort == sort,
            inMutuallyExclusiveGroup: true,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 52,
              title: Text(
                sortLabel(l10n, sort),
                style: AppTypography.body.copyWith(
                  color: filters.sort == sort
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              trailing: filters.sort == sort
                  ? Icon(Icons.check_rounded, color: AppColors.irisGlow)
                  : null,
              onTap: () {
                ref
                    .read(browseProvider.notifier)
                    .set(filters.copyWith(sort: sort));
                Navigator.of(context).pop();
              },
            ),
          ),
      ],
    );
  }
}
