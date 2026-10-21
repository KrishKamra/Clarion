import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/clarion_sheet.dart';
import '../../../cart/application/budget_controller.dart';

/// Lets the user set the monthly ceiling the Guardian protects.
Future<void> showCeilingSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: 'Envelope',
    title: 'Monthly ceiling',
    builder: (_) => const _CeilingEditor(),
  );
}

class _CeilingEditor extends ConsumerStatefulWidget {
  const _CeilingEditor();

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
          'Clarion measures every decision against this number. '
          'Changes apply from today.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
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
          label: 'Save ceiling',
          onPressed: () {
            ref.read(budgetProvider.notifier).setMonthlyLimit(_value);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
