import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/product_artwork.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/catalog.dart';
import '../../../data/models/order_model.dart';
import '../../../l10n/l10n.dart';
import '../../decision/application/cooldown_controller.dart';
import '../../decision/presentation/product_decision_screen.dart';
import '../application/orders_controller.dart';
import 'order_labels.dart';
import 'return_sheet.dart';

/// One order: where it is on its way to the counter, what is in it, and
/// a calm way to cancel or return any item.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  static Future<void> open(BuildContext context, String orderId) =>
      Navigator.of(context)
          .push(fadeRiseRoute(OrderDetailScreen(orderId: orderId)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final order = ref
        .watch(
          ordersProvider.select((all) => all.where((o) => o.id == orderId)),
        )
        .firstOrNull;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    if (order == null) {
      return SubPage(eyebrow: l10n.orderEyebrow, title: orderId, slivers: []);
    }
    final canReturn = order.canReturn(now);

    return SubPage(
      eyebrow: l10n.orderEyebrow,
      title: order.id,
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              _Tracking(order: order, now: now),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                title: l10n.inThisOrder,
                caption: canReturn
                    ? order.collectedAt == null
                          ? l10n.cancelPolicy
                          : l10n.returnPolicy(Order.returnWindow.inDays)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final line in order.lines) ...[
                _LineTile(order: order, line: line, canReturn: canReturn),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.lg),
              _Totals(order: order),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tracking extends ConsumerWidget {
  const _Tracking({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final local = MaterialLocalizations.of(context);
    final stage = order.stageAt(now);
    final returned = order.isFullyReturned;
    String time(DateTime t) =>
        '${local.formatShortMonthDay(t)}, '
        '${local.formatTimeOfDay(TimeOfDay.fromDateTime(t))}';

    return TactileCard(
      material: CardMaterial.floating,
      tint: returned ? null : orderStatusColor(order, now),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.orderStatus(order, now).toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: orderStatusColor(order, now),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            returned
                ? l10n.allItemsReturned
                : stage == OrderStage.ready
                ? l10n.showAtCounter(order.id)
                : stage == OrderStage.collected
                ? l10n.enjoyIt
                : l10n.weWillTellYou,
            style: AppTypography.titleSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final s in OrderStage.values)
            _Step(
              label: l10n.stage(s, area: order.pickupArea),
              time: switch (order.reachedAt(s)) {
                final t? when !t.isAfter(now) => time(t),
                final t? => l10n.expectedAt(time(t)),
                null => null,
              },
              reached: s.index <= stage.index,
              last: s == OrderStage.values.last,
            ),
          if (stage == OrderStage.ready && !returned) ...[
            const SizedBox(height: AppSpacing.md),
            ClarionButton(
              label: l10n.markCollected,
              icon: Icons.check_rounded,
              tone: ButtonTone.positive,
              onPressed: () =>
                  ref.read(ordersProvider.notifier).markCollected(order.id),
            ),
          ],
        ],
      ),
    );
  }
}

/// A point on the vertical timeline, joined to the next by a rule.
class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.time,
    required this.reached,
    required this.last,
  });

  final String label;
  final String? time;
  final bool reached;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ink = reached ? AppColors.emeraldGlow : AppColors.textTertiary;
    return MergeSemantics(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  const SizedBox(height: 3),
                  Icon(
                    reached
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: ink,
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: reached ? ink : AppColors.hairline,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.label.copyWith(
                        color: reached
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (time != null) Text(time!, style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineTile extends ConsumerWidget {
  const _LineTile({
    required this.order,
    required this.line,
    required this.canReturn,
  });

  final Order order;
  final OrderLine line;
  final bool canReturn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(catalogProvider);
    final known = catalog.products.any((p) => p.id == line.productId);
    final returned = line.returned;
    final now = ref.watch(clockProvider).value ?? DateTime.now();

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: known
          ? () => ProductDecisionScreen.open(context, line.productId)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (known) ...[
                ProductArtwork(product: catalog.byId(line.productId), size: 52),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line.quantity > 1
                          ? '${line.quantity} × ${Fmt.inr(line.price)}'
                          : Fmt.inr(line.price),
                      style: AppTypography.metricSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (returned != null)
                DynamicPill(
                  label: returned.isRefunded(now)
                      ? l10n.refunded(Fmt.inr(line.subtotal))
                      : l10n.returnInProgress,
                  color: returned.isRefunded(now)
                      ? AppColors.emeraldGlow
                      : AppColors.amber,
                ),
            ],
          ),
          if (returned == null && canReturn) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: DynamicPill(
                label: order.collectedAt == null
                    ? l10n.cancelItem
                    : l10n.returnItem,
                icon: Icons.undo_rounded,
                size: PillSize.regular,
                color: AppColors.irisGlow,
                onTap: () => showReturnSheet(context, order, line),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget row(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodySmall)),
          Text(value, style: AppTypography.metricSmall.copyWith(color: color)),
        ],
      ),
    );
    return Column(
      children: [
        row(l10n.orderTotal, Fmt.inr(order.total)),
        row(l10n.pickupLabel, l10n.pickupFree),
        if (order.refunded > 0)
          row(
            l10n.refundedLabel,
            Fmt.inr(-order.refunded),
            color: AppColors.emeraldGlow,
          ),
        const Divider(),
        row(l10n.youPaid, Fmt.inr(order.total - order.refunded)),
      ],
    );
  }
}
