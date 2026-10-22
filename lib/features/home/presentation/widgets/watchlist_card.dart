import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/dynamic_pill.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/product_artwork.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/models/product_model.dart';
import '../../../decision/application/watch_status.dart';
import '../../../decision/presentation/product_decision_screen.dart';

/// Price Memory Watcher on Home: every product the user is watching, with its
/// target price and whether now is a good time to decide.
class WatchlistCard extends StatelessWidget {
  const WatchlistCard({super.key, required this.watched});

  /// Watched product -> target price (`null` when there is no target).
  final List<(Product, double?)> watched;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (final (i, (product, target)) in watched.indexed) ...[
            if (i > 0) const Divider(),
            _WatchRow(product: product, target: target),
          ],
        ],
      ),
    );
  }
}

class _WatchRow extends StatelessWidget {
  const _WatchRow({required this.product, required this.target});

  final Product product;
  final double? target;

  @override
  Widget build(BuildContext context) {
    final verdict = watchVerdict(price: product.price, target: target);
    final (label, color) = switch (verdict) {
      WatchVerdict.targetHit => ('Target hit', AppColors.emeraldGlow),
      WatchVerdict.close => ('Close', AppColors.amber),
      WatchVerdict.waiting => ('Waiting', AppColors.textSecondary),
      WatchVerdict.noTarget => ('No target', AppColors.textSecondary),
    };
    final tag = 'watch-${product.id}';
    final detail = target == null
        ? 'Now ${Fmt.inr(product.price)}'
        : 'Now ${Fmt.inr(product.price)} · target ${Fmt.inr(target!)}';

    return Pressable(
      onTap: () =>
          ProductDecisionScreen.open(context, product.id, heroTag: tag),
      semanticLabel: '${product.title}: $label. $detail',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            ProductArtwork(product: product, size: 44, heroTag: tag),
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
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.metricSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DynamicPill(label: label, color: color),
          ],
        ),
      ),
    );
  }
}
