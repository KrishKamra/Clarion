import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/order_model.dart';
import '../../../l10n/l10n.dart';
import '../../decision/application/cooldown_controller.dart';
import '../application/orders_controller.dart';
import 'order_detail_screen.dart';
import 'order_labels.dart';

/// Every order the account has placed, newest first.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(fadeRiseRoute(const OrdersScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orders = ref.watch(ordersProvider);
    return SubPage(
      eyebrow: l10n.ordersEyebrow,
      title: l10n.ordersTitle,
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: orders.isEmpty
              ? SliverToBoxAdapter(
                  child: TactileCard(
                    material: CardMaterial.vellum,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Text(
                      l10n.noOrders,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => OrderCard(order: orders[i]),
                ),
        ),
      ],
    );
  }
}

/// An order at a glance: reference, date, what is in it, and where it is.
class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final status = l10n.orderStatus(order, now);
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(order.placedAt);
    final titles = order.lines.map((l) => l.title).join(', ');
    return TactileCard(
      onTap: () => OrderDetailScreen.open(context, order.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: AppTypography.metricSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              DynamicPill(label: status, color: orderStatusColor(order, now)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            titles,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$date · ${l10n.itemCount(order.itemCount)}',
                  style: AppTypography.caption,
                ),
              ),
              Text(
                Fmt.inr(order.total - order.refunded),
                style: AppTypography.metric,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
