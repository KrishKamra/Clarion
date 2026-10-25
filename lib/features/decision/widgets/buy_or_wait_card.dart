import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../application/price_prediction_engine.dart';
import '../application/watchlist_controller.dart';

/// Card showing the "Buy now or wait?" timing verdict, price dip prediction,
/// confidence level meter, and one-tap price watch action.
class BuyOrWaitCard extends ConsumerWidget {
  const BuyOrWaitCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verdict = PricePredictionEngine.analyze(product);
    final watchlist = ref.watch(watchlistProvider);
    final controller = ref.read(watchlistProvider.notifier);
    final watching = watchlist.containsKey(product.id);

    final statusColor = verdict.shouldBuyNow
        ? AppColors.emeraldGlow
        : AppColors.amber;

    final targetPrice = product.price - verdict.estimatedSavings;

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('BUY NOW OR WAIT?', style: AppTypography.overline),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: DynamicPill(
                  label: verdict.shouldWait
                      ? '${verdict.recommendation.emoji} WAIT ~${verdict.estimatedWaitWeeks} '
                            '${verdict.estimatedWaitWeeks == 1 ? 'WK' : 'WKS'}'
                      : '${verdict.recommendation.emoji} BUY NOW',
                  color: statusColor,
                  selected: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            verdict.headline,
            style: AppTypography.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            verdict.explanation,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Confidence Meter
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.vellum,
              borderRadius: AppRadii.mdAll,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'PREDICTION CONFIDENCE',
                        style: AppTypography.overline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${verdict.confidencePercentage}% (${verdict.confidence.label})',
                      style: AppTypography.metricSmall.copyWith(
                        color: statusColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadii.pillAll,
                  child: LinearProgressIndicator(
                    value: verdict.confidencePercentage / 100,
                    minHeight: 4,
                    backgroundColor: AppColors.hairline,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (verdict.shouldWait) ...[
            const SizedBox(height: AppSpacing.lg),
            ClarionButton(
              label: watching
                  ? 'Watching (${Fmt.inr(watchlist[product.id] ?? targetPrice)})'
                  : 'Set Alert for ${Fmt.inr(targetPrice)} Target',
              icon: watching
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              tone: watching ? ButtonTone.secondary : ButtonTone.primary,
              onPressed: () {
                if (watching) {
                  controller.unwatch(product.id);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Price Watch removed.')),
                    );
                } else {
                  controller.watch(product.id);
                  controller.setTarget(product.id, targetPrice);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          'Price Watch set! Alerting when ${product.title} reaches ${Fmt.inr(targetPrice)}.',
                        ),
                      ),
                    );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
