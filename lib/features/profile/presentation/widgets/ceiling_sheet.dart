import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/clarion_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../cart/application/budget_controller.dart';

/// Lets the user set the monthly ceiling the Guardian protects.
///
/// With [welcome] set, it is the first-run prompt shown to a new account:
/// friendlier copy, and a way to keep the default and move on.
Future<void> showCeilingSheet(BuildContext context, {bool welcome = false}) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: welcome ? 'Welcome to Clarion' : 'Envelope',
    title: welcome ? 'Set your monthly ceiling' : 'Monthly ceiling',
    builder: (_) => _CeilingEditor(welcome: welcome),
  );
}

/// Plain-language explanation of what the monthly ceiling is and does.
Future<void> showCeilingInfoSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: 'Guide',
    title: 'What is a ceiling?',
    builder: (_) => const _CeilingExplainer(),
  );
}

class _CeilingExplainer extends StatelessWidget {
  const _CeilingExplainer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Your ceiling is the most you want to spend in a month. You choose '
          'it, and you can change it any time.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _Point(
          icon: Icons.track_changes_rounded,
          title: 'Everything is measured against it',
          body:
              'Each product shows how much buffer it would leave, and its '
              'Fit score includes a budget line.',
        ),
        const _Point(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Settled and in cart',
          body:
              'Settled is what you have already bought this month. Add your '
              'cart and you get your committed total, the ring in Profile.',
        ),
        const _Point(
          icon: Icons.shield_outlined,
          title: 'The Guardian watches the line',
          body:
              'Your cart bar moves from Safe to Caution to Over. Go over and '
              'Clarion suggests cheaper swaps and asks you to confirm at '
              'checkout.',
        ),
        const _Point(
          icon: Icons.lightbulb_outline_rounded,
          title: 'Picking a number',
          body:
              'Choose what you can comfortably spend on non-essentials, not '
              'an aspirational figure. A ceiling you can keep beats a high '
              'one.',
        ),
        const SizedBox(height: AppSpacing.md),
        ClarionButton(
          label: 'Got it',
          tone: ButtonTone.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.irisGlow),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label),
                const SizedBox(height: AppSpacing.xxs),
                Text(body, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CeilingEditor extends ConsumerStatefulWidget {
  const _CeilingEditor({required this.welcome});

  final bool welcome;

  @override
  ConsumerState<_CeilingEditor> createState() => _CeilingEditorState();
}

class _CeilingEditorState extends ConsumerState<_CeilingEditor> {
  late double _value = ref.read(budgetProvider).monthlyLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.welcome
              ? 'What is the most you want to spend in a month? Clarion '
                    'measures every decision against this number and warns you '
                    'before you cross it. You can change it any time from '
                    'Profile.'
              : 'Clarion measures every decision against this number. '
                    'Changes apply from today.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: Pressable(
            onTap: () => showCeilingInfoSheet(context),
            semanticLabel: 'What is a ceiling?',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.irisGlow,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'What is a ceiling?',
                    style: AppTypography.label.copyWith(
                      color: AppColors.irisGlow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(child: Text(Fmt.inr(_value), style: AppTypography.metricXL)),
        const SizedBox(height: AppSpacing.md),
        Slider(
          value: _value,
          min: 2000,
          max: 20000,
          divisions: 36,
          onChanged: (v) {
            if (v != _value) HapticFeedback.selectionClick();
            setState(() => _value = v);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Fmt.inr(2000), style: AppTypography.metricSmall),
            Text(Fmt.inr(20000), style: AppTypography.metricSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        ClarionButton(
          label: widget.welcome ? 'Set my ceiling' : 'Save ceiling',
          onPressed: () {
            ref.read(budgetProvider.notifier).setMonthlyLimit(_value);
            Navigator.of(context).pop();
          },
        ),
        if (widget.welcome) ...[
          const SizedBox(height: AppSpacing.sm),
          ClarionButton(
            label:
                'Keep ${Fmt.inr(ref.read(budgetProvider).monthlyLimit)} for now',
            tone: ButtonTone.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }
}
