import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/intent_input.dart';
import '../../../core/widgets/section_header.dart';
import '../../decision/presentation/product_decision_screen.dart';
import '../application/intent_controller.dart';
import 'widgets/fit_stream_card.dart';
import 'widgets/horizon_header.dart';
import 'widgets/intent_summary.dart';

/// Intent Horizon: state a goal, then read a calm, ranked stream of products
/// that fit it — each with its score, its reasons and its compromise.
class IntentHomeScreen extends ConsumerWidget {
  const IntentHomeScreen({super.key});

  static const List<String> capsules = [
    'Daily EDC for College < ₹2,500',
    'Active Noise Cancellation for Deep Work',
    'Late-night Study Desk Setup',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.watch(intentProvider);
    final picks = ref.watch(fitPicksProvider);
    final controller = ref.read(intentProvider.notifier);

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
            child: IntentInput(
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
            bottom: AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              label: 'Curated fit stream',
              caption: intent == null
                  ? 'Ranked by personal fit to your goals and envelope.'
                  : 'Ranked for “${intent.raw}”.',
            ),
          ),
        ),
        if (picks.isEmpty)
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverToBoxAdapter(
              child: FitStreamEmpty(budget: intent?.budget),
            ),
          )
        else
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList.separated(
              itemCount: picks.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final p = picks[i];
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
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppSpacing.navBarClearance(context) + AppSpacing.lg,
          ),
        ),
      ],
    );
  }
}
