import 'package:flutter/foundation.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';

/// Return-window and warranty dates for one kept line.
@immutable
class VaultEntry {
  const VaultEntry({
    required this.order,
    required this.line,
    required this.product,
    this.returnCloses,
    this.warrantyExpires,
  });

  final Order order;
  final OrderLine line;
  final Product? product;

  /// When the 7-day return window ends. Null until the order is collected.
  final DateTime? returnCloses;

  /// Null for a lifetime warranty.
  final DateTime? warrantyExpires;

  bool returnClosesWithin(DateTime now, Duration window) {
    final closes = returnCloses;
    if (closes == null) return false;
    return !closes.isBefore(now) && closes.difference(now) <= window;
  }

  int? get daysUntilReturnCloses {
    final closes = returnCloses;
    if (closes == null) return null;
    return closes.difference(DateTime.now()).inDays;
  }
}

abstract final class WarrantyVault {
  static const Duration returnReminderLead = Duration(days: 3);
  static const Duration warrantyReminderLead = Duration(days: 30);

  /// Warranty length in years, from the product spec. Null means lifetime
  /// or unknown, and no expiry reminder is scheduled.
  static int? warrantyYears(Product? product) {
    final years = product?.spec('warranty')?.value;
    if (years == null || years >= 90) return null;
    final whole = years.round();
    return whole <= 0 ? null : whole;
  }

  static List<VaultEntry> entries({
    required List<Order> orders,
    required List<Product> catalog,
  }) {
    Product? find(String id) {
      for (final product in catalog) {
        if (product.id == id) return product;
      }
      return null;
    }

    final list = <VaultEntry>[];
    for (final order in orders) {
      for (final line in order.lines) {
        if (line.returned != null) continue;
        final product = find(line.productId);
        final years = warrantyYears(product);
        list.add(
          VaultEntry(
            order: order,
            line: line,
            product: product,
            returnCloses: order.collectedAt?.add(Order.returnWindow),
            warrantyExpires: years == null
                ? null
                : DateTime(
                    order.placedAt.year + years,
                    order.placedAt.month,
                    order.placedAt.day,
                  ),
          ),
        );
      }
    }
    return list;
  }

  /// Moment to say the return window closes in three days.
  static DateTime? returnReminderAt(Order order) {
    final start = order.collectedAt ?? order.placedAt;
    return start.add(Order.returnWindow).subtract(returnReminderLead);
  }
}
