import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../budget/application/budget_controller.dart';
import '../../../cart/application/cart_controller.dart';
import '../../../navigation/navigation_controller.dart';

/// One-line Budget Guardian status that links to the Smart Cart.
class GuardianNudgeCard extends ConsumerWidget {
  const GuardianNudgeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(budgetSnapshotProvider);
    final swaps = ref.watch(swapSuggestionsProvider);
    final color = AppColors.forBudgetRatio(b.ratio);

    final String title;
    final String body;
    if (b.isOver) {
      title = 'Your cart is ${Fmt.inr(b.overBy)} over this month\'s limit';
      body = swaps.isEmpty
          ? 'Review your Intent Cart before checking out.'
          : 'Budget Guardian found a swap that saves ${Fmt.inr(swaps.first.savings)}.';
    } else {
      title = '${Fmt.inr(b.headroom)} of headroom this month';
      body = 'Everything in your cart fits your ${Fmt.inr(b.limit)} envelope.';
    }

    return GlassContainer.card(
      tint: color,
      opacity: 0.06,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => ref.read(navigationProvider.notifier).select(AppTab.cart),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(
              b.isOver
                  ? Icons.shield_moon_rounded
                  : Icons.verified_user_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
