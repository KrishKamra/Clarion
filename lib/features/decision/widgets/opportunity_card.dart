import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../profile/application/opportunity_cost.dart';

/// What this price costs in progress toward a savings goal.
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({super.key, required this.cost, this.grouped = false});

  final OpportunityCost cost;

  /// Inside a fact sheet: content only, the sheet supplies the card.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final category = cost.categorySentence;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OPPORTUNITY COST', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        Text(cost.sentence, style: AppTypography.title),
        if (category != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            category,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
    return grouped ? content : TactileCard(child: content);
  }
}
