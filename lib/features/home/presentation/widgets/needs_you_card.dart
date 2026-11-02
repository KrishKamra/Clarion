import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/catalog.dart';
import '../../../../l10n/l10n.dart';
import '../../../decision/application/cooldown_controller.dart';
import '../../../decision/application/watchlist_controller.dart';
import '../../../decision/presentation/product_decision_screen.dart';
import '../../../navigation/navigation_controller.dart';
import '../../../orders/application/orders_controller.dart';
import '../../../orders/presentation/order_detail_screen.dart';
import '../../../profile/application/regret_controller.dart';
import '../../application/attention.dart';

/// What is waiting on the user, in one quiet card: holds that have ended,
/// closing return windows, prices at target, purchases to reflect on.
/// When nothing is, it says "All clear" in a single line — the cue that
/// there is nothing more to do here.
class NeedsYouCard extends ConsumerWidget {
  const NeedsYouCard({super.key});

  static const _shown = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final items = Attention.collect(
      holds: ref.watch(cooldownProvider),
      watchlist: ref.watch(watchlistProvider),
      orders: ref.watch(ordersProvider),
      checkins: ref.watch(regretControllerProvider),
      products: {for (final p in ref.watch(catalogProvider).products) p.id: p},
      now: now,
    );
    final l10n = context.l10n;

    if (items.isEmpty) {
      return Semantics(
        container: true,
        child: Row(
          children: [
            _Dot(color: AppColors.good),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.attentionClear, style: AppTypography.label),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.attentionClearDetail,
                style: AppTypography.caption,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );
    }

    return TactileCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.attentionEyebrow(items.length).toUpperCase(),
            style: AppTypography.overline,
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final (i, item) in items.take(_shown).indexed) ...[
            if (i > 0) Divider(height: 1, color: AppColors.hairline),
            _Row(item: item, onTap: () => _open(context, ref, item)),
          ],
          if (items.length > _shown)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                l10n.attentionMore(items.length - _shown),
                style: AppTypography.caption,
              ),
            ),
        ],
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref, AttentionItem item) {
    switch (item.kind) {
      case AttentionKind.returnClosing:
        OrderDetailScreen.open(context, item.orderId!);
      case AttentionKind.checkIn:
        ref.read(navigationProvider.notifier).select(AppTab.profile);
      case AttentionKind.holdReady || AttentionKind.targetHit:
        ProductDecisionScreen.open(context, item.productId!);
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap});

  final AttentionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.kind) {
      AttentionKind.holdReady => AppColors.action,
      AttentionKind.returnClosing => AppColors.caution,
      AttentionKind.targetHit => AppColors.good,
      AttentionKind.checkIn => AppColors.textTertiary,
    };
    return Pressable(
      onTap: onTap,
      semanticLabel: '${item.title}. ${item.detail}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            _Dot(color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(item.detail, style: AppTypography.caption),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
