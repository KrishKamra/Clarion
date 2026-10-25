import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../cart/application/budget_controller.dart';
import '../../auth/application/auth_service.dart';
import '../../../l10n/l10n.dart';
import '../../decision/application/cooldown_controller.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../orders/presentation/warranty_vault_screen.dart';
import '../../tour/app_tour.dart';
import 'clarity_report_screen.dart';
import 'widgets/ceiling_sheet.dart';
import 'widgets/delete_account_sheet.dart';
import 'widgets/due_regret_card.dart';
import 'widgets/email_verification_card.dart';
import 'widgets/envelope_card.dart';
import 'widgets/pending_hold_tile.dart';
import 'widgets/regret_barometer_card.dart';
import 'widgets/savings_goals_card.dart';
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
    final orders = ref.watch(ordersProvider);
    final l10n = context.l10n;
    ref.watch(clockProvider); // refresh countdowns

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        ChromeSliverHeader(
          child: ScreenTitle(
            eyebrow: l10n.profileEyebrow,
            title: l10n.profileTitle,
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              // Account and appearance live at the top, like most apps.
              if (ref.watch(currentUserProvider) case final user?) ...[
                SectionHeader(
                  eyebrow: l10n.signedInEyebrow,
                  title: l10n.account,
                ),
                const SizedBox(height: AppSpacing.md),
                _AccountCard(
                  label: user.email ?? user.displayName ?? 'Clarion account',
                ),
                // Only accounts that still need it; Google accounts arrive
                // verified.
                if (!user.emailVerified) ...[
                  const SizedBox(height: AppSpacing.md),
                  EmailVerificationCard(user: user),
                ],
                const SizedBox(height: AppSpacing.section),
              ],
              SectionHeader(
                eyebrow: l10n.ordersEyebrow,
                title: l10n.ordersTitle,
                actionLabel: orders.isEmpty ? null : l10n.seeAll,
                onAction: () => OrdersScreen.open(context),
              ),
              const SizedBox(height: AppSpacing.md),
              if (orders.isEmpty)
                Text(l10n.noOrders, style: AppTypography.bodySmall)
              else
                OrderCard(order: orders.first),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                eyebrow: l10n.displayEyebrow,
                title: l10n.appearance,
              ),
              const SizedBox(height: AppSpacing.md),
              const _AppearancePicker(),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(eyebrow: l10n.displayEyebrow, title: l10n.language),
              const SizedBox(height: AppSpacing.md),
              const _LanguagePicker(),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(eyebrow: l10n.helpEyebrow, title: l10n.appTour),
              const SizedBox(height: AppSpacing.md),
              DynamicPill(
                label: l10n.replayTour,
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
                      label: l10n.impulseLetGo,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Win(
                      value: Fmt.inrCompact(budget.savedViaCooldown),
                      label: l10n.keptByCoolingOff,
                      color: AppColors.emeraldGlow,
                    ),
                  ),
                ],
              ),
              if (holds.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.section),
                SectionHeader(
                  eyebrow: l10n.antiImpulseEyebrow,
                  title: l10n.coolingOffTitle,
                  caption: l10n.coolingOffCaption,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final entry in holds.entries) ...[
                  PendingHoldTile(productId: entry.key, until: entry.value),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              const SizedBox(height: AppSpacing.section),
              const DueRegretSection(),
              const SavingsGoalsCard(),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  DynamicPill(
                    label: 'Clarity report',
                    icon: Icons.auto_awesome_outlined,
                    size: PillSize.regular,
                    color: AppColors.irisGlow,
                    onTap: () => ClarityReportScreen.open(context),
                  ),
                  DynamicPill(
                    label: 'Warranty vault',
                    icon: Icons.inventory_2_outlined,
                    size: PillSize.regular,
                    color: AppColors.irisGlow,
                    onTap: () => WarrantyVaultScreen.open(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              const RegretBarometerCard(),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                eyebrow: l10n.historyEyebrow,
                title: l10n.sixMonthTrend,
                caption: l10n.sixMonthCaption,
              ),
              const SizedBox(height: AppSpacing.md),
              SixMonthTrend(
                history: [...budget.monthlyHistory, budget.spentThisMonth],
                limit: budget.monthlyLimit,
              ),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                eyebrow: l10n.breakdownEyebrow,
                title: l10n.whereItWent,
              ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final l10n = context.l10n;
    final options = [
      (ThemeMode.system, l10n.themeSystem, Icons.brightness_auto_outlined),
      (ThemeMode.light, l10n.themeLight, Icons.light_mode_outlined),
      (ThemeMode.dark, l10n.themeDark, Icons.dark_mode_outlined),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (value, label, icon) in options)
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

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    // Each language is named in itself, so it can be found from any other.
    final options = [
      (null, context.l10n.themeSystem),
      (const Locale('en'), 'English'),
      (const Locale('hi'), 'हिन्दी'),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (value, label) in options)
          DynamicPill(
            label: label,
            icon: value == null ? Icons.language_rounded : null,
            size: PillSize.regular,
            color: AppColors.irisGlow,
            selected: locale == value,
            onTap: () => ref.read(localeProvider.notifier).select(value),
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
            semanticLabel: context.l10n.signOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                context.l10n.signOut,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Pressable(
            onTap: () => showDeleteAccountSheet(context),
            semanticLabel: context.l10n.deleteAccountShort,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                context.l10n.deleteAccountShort,
                style: AppTypography.caption.copyWith(color: AppColors.rose),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
