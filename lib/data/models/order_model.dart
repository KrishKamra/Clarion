import 'package:flutter/foundation.dart';

/// Where an order is on its way to the customer. Clarion orders are picked
/// up in store (free, same day), so the journey ends at the counter.
enum OrderStage { placed, packed, ready, collected }

/// Why an item went back. Shown to the user as a choice when returning.
enum ReturnReason { changedMind, notAsDescribed, poorQuality, foundBetter }

/// A returned or cancelled order line. Cancelled before pickup, the money is
/// back at once; a return is refunded once the item is dropped at the store.
@immutable
class ReturnRequest {
  const ReturnRequest({
    required this.reason,
    required this.requestedAt,
    required this.beforePickup,
  });

  final ReturnReason reason;
  final DateTime requestedAt;

  /// Cancelled before it was collected, rather than returned after.
  final bool beforePickup;

  /// A return is refunded a day after it is requested (simulated until a
  /// fulfilment backend reports it); a cancellation straight away.
  static const Duration refundAfter = Duration(days: 1);

  bool isRefunded(DateTime now) =>
      beforePickup || !now.isBefore(requestedAt.add(refundAfter));
}

/// One product in an order, priced as it was at checkout.
@immutable
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.returned,
  });

  final String productId;
  final String title;
  final double price;
  final int quantity;
  final ReturnRequest? returned;

  double get subtotal => price * quantity;

  /// The label this line was settled under in the spend breakdown.
  String get spendLabel => quantity > 1 ? '$title × $quantity' : title;

  OrderLine withReturn(ReturnRequest request) => OrderLine(
    productId: productId,
    title: title,
    price: price,
    quantity: quantity,
    returned: request,
  );
}

/// A placed order and its simulated fulfilment timeline.
@immutable
class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    this.pickupArea,
    this.collectedAt,
  });

  /// Short, human-readable reference, e.g. `CLR-M3K9QZ`.
  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;

  /// The store it is collected from, when the products name one.
  final String? pickupArea;

  /// When the customer confirmed pickup; `null` until then.
  final DateTime? collectedAt;

  /// Store-side milestones, simulated from the order time until a
  /// fulfilment backend reports them.
  static const Duration packedAfter = Duration(minutes: 5);
  static const Duration readyAfter = Duration(minutes: 30);

  /// Items can be returned for this long after pickup.
  static const Duration returnWindow = Duration(days: 7);

  /// When each stage was (or will be) reached; `null` for a pickup that has
  /// not been confirmed.
  DateTime? reachedAt(OrderStage stage) => switch (stage) {
    OrderStage.placed => placedAt,
    OrderStage.packed => placedAt.add(packedAfter),
    OrderStage.ready => placedAt.add(readyAfter),
    OrderStage.collected => collectedAt,
  };

  OrderStage stageAt(DateTime now) {
    if (collectedAt != null) return OrderStage.collected;
    if (!now.isBefore(placedAt.add(readyAfter))) return OrderStage.ready;
    if (!now.isBefore(placedAt.add(packedAfter))) return OrderStage.packed;
    return OrderStage.placed;
  }

  /// Every line went back, so there is nothing left to collect.
  bool get isFullyReturned => lines.every((l) => l.returned != null);

  /// Lines can be cancelled until pickup, then returned within the window.
  bool canReturn(DateTime now) =>
      !isFullyReturned &&
      (collectedAt == null || now.isBefore(collectedAt!.add(returnWindow)));

  double get total => lines.fold(0, (sum, l) => sum + l.subtotal);

  double get refunded => lines
      .where((l) => l.returned != null)
      .fold(0, (sum, l) => sum + l.subtotal);

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  Order copyWith({List<OrderLine>? lines, DateTime? collectedAt}) => Order(
    id: id,
    placedAt: placedAt,
    lines: lines ?? this.lines,
    pickupArea: pickupArea,
    collectedAt: collectedAt ?? this.collectedAt,
  );
}
