import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_metric.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../budget/application/budget_controller.dart';

/// The Spending Barometer: committed spend against the monthly ceiling as a
/// single multi-segment bar — settled, in cart, then headroom or overage —
/// with the ceiling marked as a fixed tick.
class SpendingBarometer extends StatelessWidget {
  const SpendingBarometer({super.key, required this.budget});

  final BudgetSnapshot budget;

  @override
  Widget build(BuildContext context) {
    final b = budget;
    final status = AppColors.forBudgetRatio(b.ratio);

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SPENDING BAROMETER', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedMetric(
                value: b.committed,
                format: Fmt.inr,
                style: AppTypography.metricXL,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '/ ${Fmt.inr(b.limit)}',
                style: AppTypography.metric.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            b.isOver
                ? '${Fmt.inr(b.overBy)} past your ceiling'
                : '${Fmt.inr(b.headroom)} of headroom this month',
            style: AppTypography.label.copyWith(color: status),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SegmentBar(budget: b),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Legend('Settled', b.spent, AppColors.textSecondary),
              _Legend('In cart', b.cart, AppColors.irisGlow),
              b.isOver
                  ? _Legend('Over', b.overBy, AppColors.rose)
                  : _Legend('Headroom', b.headroom, AppColors.emeraldGlow),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.budget});

  final BudgetSnapshot budget;

  @override
  Widget build(BuildContext context) {
    final b = budget;
    final scale = math.max(b.committed, b.limit);
    final cartWithin = b.isOver ? math.max(0.0, b.cart - b.overBy) : b.cart;
    final segments = <(double, Color)>[
      (b.spent, AppColors.textSecondary),
      (cartWithin, AppColors.irisGlow),
      if (b.isOver)
        (b.overBy, AppColors.rose)
      else
        (b.headroom, AppColors.hairline),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final ceilingX = c.maxWidth * (b.limit / scale);
        return SizedBox(
          height: 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 8,
                height: 6,
                child: ClipRRect(
                  borderRadius: AppRadii.pillAll,
                  child: Row(
                    children: [
                      for (final (amount, color) in segments)
                        if (amount > 0)
                          _Segment(
                            flex: (amount / scale * 1000).round().clamp(
                              1,
                              1000,
                            ),
                            color: color,
                          ),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: AppMotion.slow,
                curve: AppMotion.standard,
                left: ceilingX - 0.75,
                top: 0,
                bottom: 0,
                width: 1.5,
                child: const ColoredBox(color: AppColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.flex, required this.color});

  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: AnimatedContainer(
        duration: AppMotion.slow,
        curve: AppMotion.standard,
        margin: const EdgeInsets.only(right: 2),
        color: color,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.amount, this.color);

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 2, color: color),
              const SizedBox(width: 6),
              Text(label.toUpperCase(), style: AppTypography.overline),
            ],
          ),
          const SizedBox(height: 4),
          Text(Fmt.inr(amount), style: AppTypography.metricSmall),
        ],
      ),
    );
  }
}
