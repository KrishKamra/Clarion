import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../cart/application/budget_controller.dart';
import '../../auth/application/auth_service.dart';
import '../../decision/application/cooldown_controller.dart';
import '../../tour/app_tour.dart';
import 'widgets/ceiling_sheet.dart';
import 'widgets/envelope_card.dart';
import 'widgets/pending_hold_tile.dart';
import 'widgets/spend_history.dart';

/// Spending Profile: the envelope over time — what is committed, what is
/// cooling off, what was resisted, and where the month actually went.
class SpendingProfileScreen extends ConsumerWidget {
  const SpendingProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final snapshot = ref.watch(budgetSnapshotProvider);
    final holds = ref.watch(cooldownProvider);
    ref.watch(clockProvider); // refresh countdowns

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        const ChromeSliverHeader(
          child: ScreenTitle(eyebrow: 'Spending profile', title: 'This month'),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              // Account and appearance live at the top, like most apps.
              if (ref.watch(currentUserProvider) case final user?) ...[
                const SectionHeader(eyebrow: 'Signed in', title: 'Account'),
                const SizedBox(height: AppSpacing.md),
                _AccountCard(
                  label: user.email ?? user.displayName ?? 'Clarion account',
                ),
                const SizedBox(height: AppSpacing.section),
              ],
              const SectionHeader(eyebrow: 'Display', title: 'Appearance'),
              const SizedBox(height: AppSpacing.md),
              const _AppearancePicker(),
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(eyebrow: 'Help', title: 'App tour'),
              const SizedBox(height: AppSpacing.md),
              DynamicPill(
                label: 'Replay the tour',
                icon: Icons.explore_outlined,
                size: PillSize.regular,
                color: AppColors.irisGlow,
                onTap: () => ref.read(appTourProvider.notifier).start(),
              ),
              const SizedBox(height: AppSpacing.section),
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
              if (holds.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.section),
                const SectionHeader(
                  eyebrow: 'Anti-impulse',
                  title: 'Cooling off',
                  caption: 'Parked for 24h. Decide once the urge has passed.',
                ),
                const SizedBox(height: AppSpacing.md),
                for (final entry in holds.entries) ...[
                  PendingHoldTile(productId: entry.key, until: entry.value),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(
                eyebrow: 'History',
                title: 'Six-month trend',
                caption: 'Settled spend against your ceiling.',
              ),
              const SizedBox(height: AppSpacing.md),
              SixMonthTrend(
                history: [...budget.monthlyHistory, budget.spentThisMonth],
                limit: budget.monthlyLimit,
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(eyebrow: 'Breakdown', title: 'Where it went'),
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
  const _Win({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      material: CardMaterial.vellum,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.metricLarge.copyWith(
              color: color ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _AppearancePicker extends ConsumerWidget {
  const _AppearancePicker();

  static const _options = [
    (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (value, label, icon) in _options)
          DynamicPill(
            label: label,
            icon: icon,
            size: PillSize.regular,
            color: AppColors.irisGlow,
            selected: mode == value,
            onTap: () => ref.read(themeModeProvider.notifier).select(value),
          ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      material: CardMaterial.vellum,
      child: Row(
        children: [
          Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label,
            ),
          ),
          Pressable(
            onTap: AuthService.signOut,
            semanticLabel: 'Sign out',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Text(
                'Sign out',
                style: AppTypography.label.copyWith(color: AppColors.rose),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
