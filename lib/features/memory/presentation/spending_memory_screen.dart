import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../budget/application/budget_controller.dart';
import '../../budget/presentation/ceiling_sheet.dart';
import 'widgets/envelope_card.dart';
import 'widgets/spend_history.dart';

/// Spending Memory: the envelope over time — what was committed, what was
/// resisted, and where the month actually went.
class SpendingMemoryScreen extends ConsumerWidget {
  const SpendingMemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final snapshot = ref.watch(budgetSnapshotProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        const ChromeSliverHeader(
          child: ScreenTitle(eyebrow: 'Spending memory', title: 'This month'),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              EnvelopeCard(
                snapshot: snapshot,
                onEditCeiling: () => showCeilingSheet(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _Win(
                      value: '${budget.impulseBuysAvoided}',
                      label: 'Impulse buys let go',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Win(
                      value: Fmt.inrCompact(budget.savedViaCooldown),
                      label: 'Kept by cooling off',
                      color: AppColors.emeraldGlow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(
                label: 'Six-month trend',
                caption: 'Settled spend against your ceiling.',
              ),
              const SizedBox(height: AppSpacing.md),
              SixMonthTrend(
                history: [...budget.monthlyHistory, budget.spentThisMonth],
                limit: budget.monthlyLimit,
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(label: 'Where it went'),
              const SizedBox(height: AppSpacing.xs),
              CategoryBreakdown(budget: budget),
              SizedBox(height: AppSpacing.navBarClearance(context)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Win extends StatelessWidget {
  const _Win({
    required this.value,
    required this.label,
    this.color = AppColors.textPrimary,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      material: CardMaterial.vellum,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.metricLarge.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
