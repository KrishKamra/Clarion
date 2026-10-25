import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../cart/application/budget_controller.dart';
import '../application/clarity_report.dart';
import '../application/regret_controller.dart';

/// A shareable month: impulse buys avoided, money kept, regret rate,
/// and the decisions the user was glad about.
class ClarityReportScreen extends ConsumerWidget {
  const ClarityReportScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(fadeRiseRoute(const ClarityReportScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ClarityReportBuilder.build(
      budget: ref.watch(budgetProvider),
      stats: ref.watch(regretStatsProvider),
      checkins: ref.watch(regretControllerProvider),
      now: DateTime.now(),
    );
    return SubPage(
      eyebrow: 'This month',
      title: 'Clarity report',
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              TactileCard(
                material: CardMaterial.floating,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.monthLabel.toUpperCase(),
                      style: AppTypography.overline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${report.impulseBuysAvoided} impulse buys avoided',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${Fmt.inr(report.moneyKept)} kept by cooling off',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Personal regret rate ${report.regretRate}%',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      report.bestDecisions.isEmpty
                          ? 'Best decisions show up after a check-in you were glad about.'
                          : 'Best decisions: ${report.bestDecisions.join(', ')}.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ClarionButton(
                label: 'Share report',
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(
                    ShareParams(
                      text: report.shareText,
                      subject: 'Clarion clarity · ${report.monthLabel}',
                      sharePositionOrigin: box == null
                          ? null
                          : box.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
