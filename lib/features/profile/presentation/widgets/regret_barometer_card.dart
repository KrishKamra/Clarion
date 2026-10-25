import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../cart/application/budget_controller.dart';
import '../../application/regret_controller.dart';

/// Card showing the Mindful Purchase Barometer & Post-Purchase Reflection stats.
class RegretBarometerCard extends ConsumerWidget {
  const RegretBarometerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(regretStatsProvider);
    final budget = ref.watch(budgetProvider);

    final total = stats.totalCheckedIn;
    final worthRatio = total == 0 ? 1.0 : stats.worthItCount / total;
    final neutralRatio = total == 0 ? 0.0 : stats.neutralCount / total;
    final regretRatio = total == 0 ? 0.0 : stats.regrettedCount / total;

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: SectionHeader(
                  eyebrow: 'Mindfulness',
                  title: 'Regret Barometer',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color:
                      (stats.mindfulScore >= 75
                              ? AppColors.emeraldGlow
                              : AppColors.rose)
                          .withValues(alpha: 0.15),
                  borderRadius: AppRadii.pillAll,
                  border: Border.all(
                    color: stats.mindfulScore >= 75
                        ? AppColors.emeraldGlow
                        : AppColors.rose,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${stats.mindfulScore}% Mindful',
                  style: AppTypography.label.copyWith(
                    color: stats.mindfulScore >= 75
                        ? AppColors.emeraldGlow
                        : AppColors.rose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            total == 0
                ? 'Check in on settled purchases below to see your purchase satisfaction rate.'
                : '${stats.worthItCount} of $total evaluated purchases brought lasting value.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          // Multi-color progress barometer
          ClipRRect(
            borderRadius: AppRadii.pillAll,
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (worthRatio > 0)
                    Expanded(
                      flex: (worthRatio * 100).round(),
                      child: Container(color: AppColors.emeraldGlow),
                    ),
                  if (neutralRatio > 0)
                    Expanded(
                      flex: (neutralRatio * 100).round(),
                      child: Container(color: AppColors.irisGlow),
                    ),
                  if (regretRatio > 0)
                    Expanded(
                      flex: (regretRatio * 100).round(),
                      child: Container(color: AppColors.rose),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Fmt.inr(stats.regrettedAmount),
                      style: AppTypography.metricLarge.copyWith(
                        color: stats.regrettedAmount > 0
                            ? AppColors.rose
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Regretted purchases', style: AppTypography.caption),
                  ],
                ),
              ),
              Container(height: 32, width: 1, color: AppColors.hairline),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Fmt.inr(budget.savedViaCooldown),
                      style: AppTypography.metricLarge.copyWith(
                        color: AppColors.emeraldGlow,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saved via 24h cool-off',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
