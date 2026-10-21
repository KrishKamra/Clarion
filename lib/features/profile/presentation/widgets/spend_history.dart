import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../cart/application/budget_controller.dart';

/// Six months of settled spend as slim columns against the ceiling rule.
/// Months that broke the ceiling are marked in rose; the current month is
/// the only one set in titanium.
class SixMonthTrend extends StatelessWidget {
  const SixMonthTrend({super.key, required this.history, required this.limit});

  final List<double> history;
  final double limit;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final peak = math.max(history.reduce(math.max), limit) * 1.12;
    const chartH = 120.0;

    return TactileCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        height: chartH + 40,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 16 + (chartH - 16) * (1 - limit / peak),
              child: Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.textTertiary)),
                  const SizedBox(width: 6),
                  Text(
                    'CEILING',
                    style: AppTypography.overline.copyWith(fontSize: 8.5),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < history.length; i++)
                  Expanded(
                    child: _Column(
                      value: history[i],
                      ratio: history[i] / peak,
                      chartH: chartH - 16,
                      current: i == history.length - 1,
                      over: history[i] > limit,
                      label: _months[(now.month - history.length + i) % 12],
                      delay: i,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.value,
    required this.ratio,
    required this.chartH,
    required this.current,
    required this.over,
    required this.label,
    required this.delay,
  });

  final double value;
  final double ratio;
  final double chartH;
  final bool current;
  final bool over;
  final String label;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final color = over
        ? AppColors.rose
        : current
        ? AppColors.textPrimary
        : AppColors.textTertiary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          Fmt.inrCompact(value),
          style: AppTypography.metricSmall.copyWith(
            fontSize: 9.5,
            color: current ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: ratio),
          duration: AppMotion.reveal + Duration(milliseconds: delay * 40),
          curve: AppMotion.standard,
          builder: (context, t, _) => Container(
            width: 6,
            height: math.max(3, chartH * t),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.pillAll,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: AppTypography.overline.copyWith(
            fontSize: 9,
            color: current ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// This month's settled spend by category, as ruled rows with hairline bars.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key, required this.budget});

  final BudgetState budget;

  @override
  Widget build(BuildContext context) {
    final total = math.max(budget.spentThisMonth, 1.0);
    return Column(
      children: [
        for (final (i, c) in budget.categories.indexed) ...[
          if (i > 0) const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(c.label, style: AppTypography.label)),
                    Text(Fmt.inr(c.amount), style: AppTypography.metricSmall),
                    SizedBox(
                      width: 44,
                      child: Text(
                        Fmt.percent(c.amount / total * 100),
                        textAlign: TextAlign.right,
                        style: AppTypography.metricSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadii.pillAll,
                  child: LinearProgressIndicator(
                    value: c.amount / total,
                    minHeight: 2,
                    backgroundColor: AppColors.hairline,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
