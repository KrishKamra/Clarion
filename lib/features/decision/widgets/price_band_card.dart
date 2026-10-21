import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/price_band_chart.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';

/// 30-day historical price band with a plain-language timing read.
class PriceBandCard extends StatelessWidget {
  const PriceBandCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
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
            points: product.priceHistory,
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
        ],
      ),
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
