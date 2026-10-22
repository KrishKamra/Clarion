import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/price_band_chart.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../application/watch_status.dart';
import '../application/watchlist_controller.dart';

/// 30-day historical price band with a plain-language timing read, and the
/// Price Memory Watcher (watch this product, optionally with a target price).
class PriceBandCard extends ConsumerWidget {
  const PriceBandCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history =
        ref.watch(priceHistoryProvider(product.id)).value ??
        product.priceHistory;
    final position = product.bandPosition;
    final (verdict, color) = switch (position) {
      <= 0.25 => ('Near 30-day low', AppColors.emeraldGlow),
      <= 0.6 => ('Typical price', AppColors.textSecondary),
      _ => ('Near 30-day high', AppColors.amber),
    };
    final percentile = (position * 100).round();

    return TactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('30-DAY PRICE BAND', style: AppTypography.overline),
              ),
              DynamicPill(label: verdict, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PriceBandChart(
            points: history,
            average: product.averagePrice30d,
            color: color == AppColors.textSecondary
                ? AppColors.irisGlow
                : color,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat('30d avg', Fmt.inr(product.averagePrice30d)),
              _Stat('Low', Fmt.inr(product.historyMin)),
              _Stat('High', Fmt.inr(product.historyMax)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            percentile <= 50
                ? 'Today sits in the lowest $percentile% of its band. '
                      'No rush — Clarion keeps watching.'
                : 'Today sits in the upper ${100 - percentile}% of its band. '
                      'Waiting is a reasonable choice.',
            style: AppTypography.caption,
          ),
          const Divider(height: AppSpacing.xxl),
          _WatchSection(product: product),
        ],
      ),
    );
  }
}

/// "Watch price" toggle, target-price choices and the current read.
class _WatchSection extends ConsumerWidget {
  const _WatchSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    final controller = ref.read(watchlistProvider.notifier);
    final watching = watchlist.containsKey(product.id);
    final target = watchlist[product.id];
    final options = targetOptions(product);

    final verdict = watching
        ? watchVerdict(price: product.price, target: target)
        : null;
    final (message, color) = switch (verdict) {
      null => (
        'Watch this price and Clarion remembers it every day.',
        AppColors.textSecondary,
      ),
      WatchVerdict.noTarget => (
        'Watching. Pick a target to know when it is a good time to buy.',
        AppColors.textSecondary,
      ),
      WatchVerdict.targetHit => (
        'Target reached: ${Fmt.inr(product.price)} is at or below '
            '${Fmt.inr(target!)}. A good time to decide.',
        AppColors.emeraldGlow,
      ),
      WatchVerdict.close => (
        'Close: ${Fmt.inr(product.price - target!)} above your target.',
        AppColors.amber,
      ),
      WatchVerdict.waiting => (
        'Waiting: ${Fmt.inr(product.price - target!)} above your target.',
        AppColors.textSecondary,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('PRICE WATCH', style: AppTypography.overline)),
            DynamicPill(
              label: watching ? 'Watching' : 'Watch price',
              icon: watching
                  ? Icons.visibility_rounded
                  : Icons.visibility_outlined,
              color: AppColors.irisGlow,
              selected: watching,
              onTap: () => watching
                  ? controller.unwatch(product.id)
                  : controller.watch(product.id),
            ),
          ],
        ),
        if (watching && options.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final option in options)
                DynamicPill(
                  label: 'Alert at ${Fmt.inr(option)}',
                  color: AppColors.emeraldGlow,
                  selected: target == option,
                  onTap: () => controller.setTarget(
                    product.id,
                    target == option ? null : option,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(message, style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.overline),
          const SizedBox(height: 3),
          Text(value, style: AppTypography.metricSmall),
        ],
      ),
    );
  }
}
