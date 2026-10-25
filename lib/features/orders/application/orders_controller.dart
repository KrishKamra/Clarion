import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../cart/application/budget_controller.dart';

/// Order history, newest first. Placing, collecting and returning update
/// memory at once and SQLite after, like every other controller.
class OrdersController extends Notifier<List<Order>> {
  @override
  List<Order> build() => ref.watch(initialOrdersProvider);

  Order? byId(String id) {
    for (final o in state) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Records a checkout as an order collected from the nearest store that
  /// stocks its first product.
  Order place(List<CartItem> lines) {
    final now = DateTime.now();
    final order = Order(
      id: referenceFor(now),
      placedAt: now,
      pickupArea: lines
          .map((l) => l.product.pickup?.area)
          .firstWhere((a) => a != null, orElse: () => null),
      lines: [
        for (final l in lines)
          OrderLine(
            productId: l.productId,
            title: l.product.title,
            price: l.product.price,
            quantity: l.quantity,
          ),
      ],
    );
    state = [order, ...state];
    _persist(ref.read(orderRepositoryProvider)?.insert(order));
    return order;
  }

  void markCollected(String orderId) {
    final now = DateTime.now();
    _update(orderId, (o) => o.copyWith(collectedAt: now));
    _persist(ref.read(orderRepositoryProvider)?.markCollected(orderId, now));
  }

  /// Cancels (before pickup) or returns (after) one line, and gives its cost
  /// back to the month's envelope.
  void requestReturn(String orderId, String productId, ReturnReason reason) {
    final order = byId(orderId);
    if (order == null) return;
    final request = ReturnRequest(
      reason: reason,
      requestedAt: DateTime.now(),
      beforePickup: order.collectedAt == null,
    );
    final line = order.lines.firstWhere((l) => l.productId == productId);
    if (line.returned != null) return;
    _update(
      orderId,
      (o) => o.copyWith(
        lines: [
          for (final l in o.lines)
            l.productId == productId ? l.withReturn(request) : l,
        ],
      ),
    );
    ref
        .read(budgetProvider.notifier)
        .recordRefund(line.spendLabel, line.subtotal, boughtAt: order.placedAt);
    _persist(
      ref
          .read(orderRepositoryProvider)
          ?.recordReturn(orderId, productId, request),
    );
  }

  /// `CLR-` and the order time in base 36: short enough to read out at the
  /// store counter, unique per account.
  static String referenceFor(DateTime at) =>
      'CLR-${at.millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';

  void _update(String orderId, Order Function(Order) change) {
    state = [for (final o in state) o.id == orderId ? change(o) : o];
  }

  void _persist(Future<void>? write) {
    write?.catchError(
      (Object error, StackTrace stack) => developer.log(
        'Could not save order change',
        error: error,
        stackTrace: stack,
      ),
    );
  }
}

final ordersProvider = NotifierProvider<OrdersController, List<Order>>(
  OrdersController.new,
);

/// Products this account has bought and kept: they can be reviewed as a
/// verified purchase.
final purchasedProductIdsProvider = Provider<Set<String>>((ref) {
  return {
    for (final o in ref.watch(ordersProvider))
      for (final l in o.lines)
        if (l.returned == null) l.productId,
  };
});
