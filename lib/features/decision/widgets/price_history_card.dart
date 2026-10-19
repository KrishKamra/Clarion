import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/price_trend_chart.dart';
import '../../../core/widgets/section_header.dart';

/// 30-day price memory with a plain-language timing verdict.
class PriceHistoryCard extends StatelessWidget {
  const PriceHistoryCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final pct = product.discountVsAverage * 100;
    final (verdict, color) = switch (pct) {
      >= 10 => ('Great time to buy', AppColors.fitHigh),
      >= 3 => ('Below its usual price', AppColors.fitHigh),
      > -3 => ('Typical price', AppColors.textSecondary),
      _ => ('Above average — consider waiting', AppColors.fitMid),
    };

    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Price memory', style: AppTypography.titleSmall),
              ),
              TagPill(label: verdict, color: color, dense: true),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Last 30 days · dashed line is the average',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          PriceTrendChart(
            points: product.priceHistory,
            average: product.averagePrice30d,
            height: 92,
            color: color == AppColors.textSecondary ? AppColors.accent : color,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Stat(label: 'Now', value: Fmt.inr(product.price), color: color),
              _Stat(
                label: '30-day avg',
                value: Fmt.inr(product.averagePrice30d),
              ),
              _Stat(label: 'Low', value: Fmt.inr(product.historyMin)),
              _Stat(label: 'High', value: Fmt.inr(product.historyMax)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.numericSmall.copyWith(
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
