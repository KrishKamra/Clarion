import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/catalog.dart';
import '../../../decision/application/cooldown_controller.dart';
import '../../application/regret_controller.dart';
import '../../application/regret_window.dart';
import '../../../orders/application/orders_controller.dart';
import 'regret_checkin_sheet.dart';

/// Asks "Still glad you bought it?" once a kept purchase is 14–30 days old.
class DueRegretSection extends ConsumerWidget {
  const DueRegretSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final due = RegretWindow.due(
      orders: ref.watch(ordersProvider),
      checkins: ref.watch(regretControllerProvider),
      now: now,
    );
    if (due.isEmpty) return const SizedBox.shrink();
    final catalog = ref.watch(catalogProvider).products;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '14–30 days on',
          title: 'Still glad you bought it?',
        ),
        const SizedBox(height: AppSpacing.md),
        for (final prompt in due.take(3)) ...[
          TactileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prompt.line.title, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Day ${prompt.ageDays}. Your answer tunes fit scores for similar products.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ClarionButton(
                  label: 'Still glad you bought it?',
                  tone: ButtonTone.secondary,
                  onPressed: () {
                    String? category;
                    for (final product in catalog) {
                      if (product.id == prompt.line.productId) {
                        category = product.category;
                      }
                    }
                    showRegretCheckinSheet(
                      context,
                      productTitle: prompt.line.title,
                      amount: prompt.line.subtotal,
                      productId: prompt.line.productId,
                      category: category,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.section - AppSpacing.md),
      ],
    );
  }
}
