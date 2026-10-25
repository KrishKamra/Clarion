import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../l10n/l10n.dart';

/// User-facing names and colours for order states, shared by the list and
/// the detail screen.
extension OrderLabels on AppLocalizations {
  String stage(OrderStage stage, {String? area}) => switch (stage) {
    OrderStage.placed => stagePlaced,
    OrderStage.packed => stagePacked,
    OrderStage.ready => area == null ? stageReady : stageReadyAt(area),
    OrderStage.collected => stageCollected,
  };

  String reason(ReturnReason reason) => switch (reason) {
    ReturnReason.changedMind => reasonChangedMind,
    ReturnReason.notAsDescribed => reasonNotAsDescribed,
    ReturnReason.poorQuality => reasonPoorQuality,
    ReturnReason.foundBetter => reasonFoundBetter,
  };

  /// One-line status of an order as a whole.
  String orderStatus(Order order, DateTime now) {
    if (order.isFullyReturned) {
      return order.lines.first.returned!.beforePickup
          ? statusCancelled
          : statusReturned;
    }
    return stage(order.stageAt(now));
  }
}

/// Emerald once it can be collected or has been, iris while on its way,
/// quiet once it has all gone back.
Color orderStatusColor(Order order, DateTime now) {
  if (order.isFullyReturned) return AppColors.textSecondary;
  return switch (order.stageAt(now)) {
    OrderStage.placed || OrderStage.packed => AppColors.irisGlow,
    OrderStage.ready || OrderStage.collected => AppColors.emeraldGlow,
  };
}
