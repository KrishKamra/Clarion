import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_wordmark.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../../core/widgets/round_icon_button.dart';
import '../../../cart/application/budget_controller.dart';
import '../../../navigation/navigation_controller.dart';

/// Quiet header: monogram, the live monthly budget indicator and the
/// profile node.
class HorizonHeader extends ConsumerWidget {
  const HorizonHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const ClarionWordmark(size: 22, showName: false),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Align(alignment: Alignment.centerRight, child: BudgetMetric()),
        ),
        const SizedBox(width: AppSpacing.md),
        RoundIconButton(
          icon: Icons.person_outline_rounded,
          semanticLabel: 'Spending profile',
          size: 36,
          onPressed: () =>
              ref.read(navigationProvider.notifier).select(AppTab.profile),
        ),
      ],
    );
  }
}

/// Committed spend (settled + cart) against the monthly ceiling, beside a
/// backlit miniature gauge. Tapping opens the Guardian.
class BudgetMetric extends ConsumerWidget {
  const BudgetMetric({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(budgetSnapshotProvider);
    final color = AppColors.forBudgetRatio(b.ratio);

    return Pressable(
      onTap: () => ref.read(navigationProvider.notifier).select(AppTab.cart),
      semanticLabel:
          'Budget: ${Fmt.inr(b.committed)} of ${Fmt.inr(b.limit)} committed',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressRing(
            value: b.ratio,
            color: color,
            size: 18,
            strokeWidth: 2,
            backlit: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  text: Fmt.inr(b.committed),
                  children: [
                    TextSpan(
                      text: ' / ${Fmt.inr(b.limit)}',
                      style: const TextStyle(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                style: AppTypography.metricSmall.copyWith(fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
