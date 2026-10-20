import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/section_header.dart';
import '../../application/intent_controller.dart';

/// Shows how Clarion read the intent — ceiling, keywords, match count — so
/// the ranking below is never a black box.
class IntentSummary extends StatelessWidget {
  const IntentSummary({
    super.key,
    required this.intent,
    required this.matches,
    required this.onClear,
  });

  final IntentQuery intent;
  final int matches;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INTERPRETED AS', style: AppTypography.overline),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (intent.budget != null)
                    MetaTag(
                      label: '≤ ${Fmt.inr(intent.budget!)}',
                      color: AppColors.emeraldGlow,
                    ),
                  for (final k in intent.keywords.take(4)) MetaTag(label: k),
                  MetaTag(
                    label: '$matches ${matches == 1 ? 'match' : 'matches'}',
                    color: AppColors.irisGlow,
                  ),
                ],
              ),
            ],
          ),
        ),
        Pressable(
          onTap: onClear,
          semanticLabel: 'Clear intent',
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md, top: 2),
            child: Text(
              'Reset',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
