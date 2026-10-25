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

/// Quiet header: the Clarion mark and name, the live monthly budget
/// indicator and the profile node.
class HorizonHeader extends ConsumerWidget {
  const HorizonHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const ClarionWordmark(size: 24),
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

/// What is left of the monthly ceiling after settled spend and the cart,
/// beside a backlit miniature gauge. The full breakdown lives one tap away
/// on the Guardian.
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
              child: Text(
                b.isOver
                    ? '${Fmt.inr(b.overBy)} over'
                    : '${Fmt.inr(b.headroom)} left',
                style: AppTypography.metricSmall.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
