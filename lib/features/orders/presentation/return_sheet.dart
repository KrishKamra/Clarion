import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_sheet.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../data/models/order_model.dart';
import '../../../l10n/l10n.dart';
import '../application/orders_controller.dart';
import 'order_labels.dart';

/// Cancel (before pickup) or return (after) one order line. No retention
/// tricks: one reason, the amount that comes back, and a confirm.
Future<void> showReturnSheet(
  BuildContext context,
  Order order,
  OrderLine line,
) {
  final l10n = context.l10n;
  final cancelling = order.collectedAt == null;
  return showClarionSheet<void>(
    context: context,
    eyebrow: line.title,
    title: cancelling ? l10n.cancelItem : l10n.returnItem,
    builder: (_) => _ReturnForm(order: order, line: line),
  );
}

class _ReturnForm extends ConsumerStatefulWidget {
  const _ReturnForm({required this.order, required this.line});

  final Order order;
  final OrderLine line;

  @override
  ConsumerState<_ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends ConsumerState<_ReturnForm> {
  ReturnReason? _reason;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cancelling = widget.order.collectedAt == null;
    final amount = Fmt.inr(widget.line.subtotal);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.returnWhy, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final r in ReturnReason.values)
              DynamicPill(
                label: l10n.reason(r),
                size: PillSize.regular,
                color: AppColors.irisGlow,
                selected: _reason == r,
                onTap: () => setState(() => _reason = r),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          cancelling
              ? l10n.cancelExplainer(amount)
              : l10n.returnExplainer(
                  amount,
                  widget.order.pickupArea ?? l10n.yourStore,
                ),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
        ClarionButton(
          label: cancelling ? l10n.confirmCancel : l10n.confirmReturn,
          onPressed: _reason == null
              ? null
              : () {
                  ref
                      .read(ordersProvider.notifier)
                      .requestReturn(
                        widget.order.id,
                        widget.line.productId,
                        _reason!,
                      );
                  Navigator.of(context).pop();
                },
        ),
      ],
    );
  }
}
