import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/product_artwork.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../budget/application/budget_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../application/cooldown_controller.dart';
import '../presentation/product_decision_screen.dart';

/// An item parked in its 24h cooling-off period, with the two honest
/// outcomes: let it go, or keep it.
class PendingHoldTile extends ConsumerWidget {
  const PendingHoldTile({
    super.key,
    required this.productId,
    required this.until,
  });

  final String productId;
  final DateTime until;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(catalogProvider).byId(productId);
    final remaining = until.difference(DateTime.now());
    final elapsed =
        1 - remaining.inSeconds / CooldownController.period.inSeconds;

    void snack(String m) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => ProductDecisionScreen.open(context, productId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProductArtwork(product: product, size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${Fmt.inr(product.price)} · '
                      '${remaining.isNegative ? 'ready to decide' : '${Fmt.countdown(remaining)} left'}',
                      style: AppTypography.metricSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadii.pillAll,
                      child: LinearProgressIndicator(
                        value: elapsed.clamp(0.0, 1.0),
                        minHeight: 3,
                        backgroundColor: AppColors.hairline,
                        color: AppColors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClarionButton(
                  label: 'Let it go',
                  height: 42,
                  tone: ButtonTone.secondary,
                  onPressed: () {
                    ref.read(cooldownProvider.notifier).release(productId);
                    ref
                        .read(budgetProvider.notifier)
                        .recordImpulseAvoided(product.price);
                    snack('${Fmt.inr(product.price)} stays in your envelope.');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ClarionButton(
                  label: 'Still want it',
                  height: 42,
                  onPressed: () {
                    ref.read(cooldownProvider.notifier).release(productId);
                    ref.read(cartProvider.notifier).add(productId);
                    snack('Moved to your Intent Cart.');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
