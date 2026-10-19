import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/mock_catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_logo.dart';
import '../../../../core/widgets/glass_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../budget/application/budget_controller.dart';
import '../../../decision/application/cooldown_controller.dart';
import '../../../decision/presentation/product_decision_screen.dart';
import '../../../navigation/navigation_controller.dart';

/// Logo mark, live budget badge and notifications trigger.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const ClarionLogo(size: 32),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Align(alignment: Alignment.centerRight, child: BudgetBadge()),
        ),
        const SizedBox(width: AppSpacing.sm),
        GlassIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          showDot: true,
          onPressed: () => _showNotifications(context),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    final drop = MockCatalog.priceMemoryPick;
    showGlassSheet<void>(
      context: context,
      title: 'Signals',
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final holds = ref.watch(cooldownProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NotificationTile(
                icon: Icons.trending_down_rounded,
                color: AppColors.fitHigh,
                title: 'Price memory: ${drop.title}',
                body:
                    '${Fmt.percent(drop.discountVsAverage * 100)} below its 30-day average.',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ProductDecisionScreen.open(context, drop.id);
                },
              ),
              for (final entry in holds.entries)
                _NotificationTile(
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.fitMid,
                  title: 'Cooling off: ${MockCatalog.byId(entry.key).title}',
                  body:
                      '${Fmt.countdown(entry.value.difference(DateTime.now()))} left before you decide.',
                  onTap: () {
                    ref
                        .read(navigationProvider.notifier)
                        .select(AppTab.profile);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Pill showing committed spend (settled + cart) against the monthly limit.
class BudgetBadge extends ConsumerWidget {
  const BudgetBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(budgetSnapshotProvider);
    final color = AppColors.forBudgetRatio(b.ratio);

    return Pressable(
      onTap: () => ref.read(navigationProvider.notifier).select(AppTab.cart),
      semanticLabel:
          'Budget: ${Fmt.inr(b.committed)} of ${Fmt.inr(b.limit)} committed',
      child: AnimatedContainer(
        duration: AppMotion.medium,
        height: 42,
        padding: const EdgeInsets.only(left: 6, right: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressRing(
              value: b.ratio,
              color: color,
              size: 28,
              strokeWidth: 3.2,
              child: Icon(Icons.shield_rounded, size: 12, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  TextSpan(
                    text: Fmt.inr(b.committed),
                    style: AppTypography.numericSmall.copyWith(color: color),
                    children: [
                      TextSpan(
                        text: ' / ${Fmt.inr(b.limit)}',
                        style: AppTypography.numericSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: AppRadii.mdAll,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
