import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/intent_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/catalog.dart';
import '../../decision/application/watchlist_controller.dart';
import '../application/intent_controller.dart';
import 'widgets/fit_stream.dart';
import 'widgets/horizon_header.dart';
import 'widgets/intent_summary.dart';
import 'widgets/price_memory_radar.dart';
import 'widgets/watchlist_card.dart';

/// Intent Horizon: state a goal, read a ranked stream of candidates that
/// fit it, and glance at what is unusually well-priced right now.
class IntentHomeScreen extends ConsumerWidget {
  const IntentHomeScreen({super.key});

  static const List<String> capsules = [
    'College Setup < ₹2.5k',
    'ANC for Focus',
    'Durable Commute Pack',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.watch(intentProvider);
    final picks = ref.watch(fitPicksProvider);
    final radar = ref.watch(catalogProvider.select((c) => c.priceRadar));
    final controller = ref.read(intentProvider.notifier);
    final catalog = ref.watch(catalogProvider);
    final watchlist = ref.watch(watchlistProvider);
    final watched = [
      for (final entry in watchlist.entries)
        (catalog.byId(entry.key), entry.value),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        const ChromeSliverHeader(child: HorizonHeader()),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: IntentField(
              capsules: capsules,
              activeIntent: intent?.raw,
              onSubmitted: controller.submit,
              onCleared: controller.clear,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: intent == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.xl,
                    ),
                    child: IntentSummary(
                      intent: intent,
                      matches: picks.length,
                      onClear: controller.clear,
                    ),
                  ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.section,
            bottom: AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              eyebrow: 'Ranked for you',
              title: 'Personal Fit Stream',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: AppMotion.slow,
            switchInCurve: AppMotion.standard,
            child: FitStream(
              key: ValueKey(intent?.raw),
              products: picks,
              budget: intent?.budget,
            ),
          ),
        ),
        if (radar.isNotEmpty) ...[
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.section,
              bottom: AppSpacing.md,
            ),
            sliver: const SliverToBoxAdapter(
              child: SectionHeader(eyebrow: 'Price memory', title: 'Radar'),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverToBoxAdapter(
              child: PriceMemoryRadar(products: radar),
            ),
          ),
        ],
        if (watched.isNotEmpty) ...[
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.section,
              bottom: AppSpacing.md,
            ),
            sliver: const SliverToBoxAdapter(
              child: SectionHeader(
                eyebrow: 'Price memory',
                title: 'Watching',
                caption: 'Products you are tracking against a target price.',
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverToBoxAdapter(child: WatchlistCard(watched: watched)),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppSpacing.navBarClearance(context) + AppSpacing.lg,
          ),
        ),
      ],
    );
  }
}
