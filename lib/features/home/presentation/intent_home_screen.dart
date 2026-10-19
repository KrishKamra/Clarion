import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_sliver_header.dart';
import '../../../core/widgets/intent_search_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../decision/presentation/product_decision_screen.dart';
import '../../navigation/navigation_controller.dart';
import '../application/intent_controller.dart';
import 'widgets/fit_pick_card.dart';
import 'widgets/guardian_nudge_card.dart';
import 'widgets/home_header.dart';
import 'widgets/price_memory_card.dart';

/// Intent-first home: state a goal, see ranked, explained fit picks.
class IntentHomeScreen extends ConsumerWidget {
  const IntentHomeScreen({super.key});

  static const List<String> quickPrompts = [
    'College Setup < ₹3k',
    'Noise-Canceling for Study',
    'Minimalist EDC Backpack',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.watch(intentProvider);
    final picks = ref.watch(fitPicksProvider);
    final priceDrop = MockCatalog.priceMemoryPick;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        const GlassSliverHeader(child: HomeHeader()),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: _Hero(
              activePrompt: intent?.raw,
              onSubmitted: ref.read(intentProvider.notifier).submit,
              onCleared: ref.read(intentProvider.notifier).clear,
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
                      top: AppSpacing.lg,
                    ),
                    child: _IntentSummary(
                      intent: intent,
                      matches: picks.length,
                      onClear: ref.read(intentProvider.notifier).clear,
                    ),
                  ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xxxl,
            bottom: AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Personal Fit Picks',
              subtitle: intent == null
                  ? 'Ranked by match to your goals & budget'
                  : 'Ranked for "${intent.raw}"',
              actionLabel: 'Compare',
              onAction: () =>
                  ref.read(navigationProvider.notifier).select(AppTab.compare),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: AppMotion.slow,
            switchInCurve: AppMotion.emphasized,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _FitPicksCarousel(
              key: ValueKey(intent?.raw),
              products: picks,
              budget: intent?.budget,
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xxxl),
          sliver: const SliverToBoxAdapter(child: GuardianNudgeCard()),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xxxl,
            bottom: AppSpacing.lg,
          ),
          sliver: const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Worth a look',
              subtitle: 'Signals from your price memory',
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding,
          sliver: SliverToBoxAdapter(
            child: PriceMemoryCard(
              product: priceDrop,
              heroTag: 'memory-${priceDrop.id}',
              onTap: () => ProductDecisionScreen.open(
                context,
                priceDrop.id,
                heroTag: 'memory-${priceDrop.id}',
              ),
            ),
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

class _Hero extends StatelessWidget {
  const _Hero({
    required this.onSubmitted,
    required this.onCleared,
    this.activePrompt,
  });

  final ValueChanged<String> onSubmitted;
  final VoidCallback onCleared;
  final String? activePrompt;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 5) return 'Late night thinking';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_greeting.toUpperCase(), style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            text: 'What are you looking to ',
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: ShaderMask(
                  shaderCallback: const LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ).createShader,
                  child: Text(
                    'accomplish?',
                    style: AppTypography.display.copyWith(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          style: AppTypography.display.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Describe a goal. Clarion finds what fits — and shows you why.',
          style: AppTypography.bodySmall.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        IntentSearchBar(
          quickPrompts: IntentHomeScreen.quickPrompts,
          activePrompt: activePrompt,
          onSubmitted: onSubmitted,
          onCleared: onCleared,
        ),
      ],
    );
  }
}

class _IntentSummary extends StatelessWidget {
  const _IntentSummary({
    required this.intent,
    required this.matches,
    required this.onClear,
  });

  final IntentQuery intent;
  final int matches;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      tint: AppColors.primary,
      opacity: 0.08,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INTERPRETED INTENT',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (intent.budget != null)
                      TagPill(
                        label: '≤ ${Fmt.inr(intent.budget!)}',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.fitHigh,
                        dense: true,
                      ),
                    for (final k in intent.keywords.take(4))
                      TagPill(
                        label: k,
                        color: AppColors.textSecondary,
                        dense: true,
                      ),
                    TagPill(
                      label: '$matches ${matches == 1 ? 'match' : 'matches'}',
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.accent,
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Clear intent',
            onPressed: onClear,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _FitPicksCarousel extends ConsumerWidget {
  const _FitPicksCarousel({super.key, required this.products, this.budget});

  final List<Product> products;
  final double? budget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: GlassContainer.card(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(
                Icons.travel_explore_rounded,
                color: AppColors.textTertiary,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                budget == null
                    ? 'Nothing matches yet'
                    : 'Nothing fits ${Fmt.inr(budget!)} yet',
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Clarion won\'t stretch your limits to show you something. Try loosening one constraint.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: FitPickCard.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final p = products[i];
          final tag = 'pick-${p.id}';
          return FitPickCard(
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
