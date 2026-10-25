import 'package:flutter/foundation.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/regret_checkin_model.dart';

/// A purchase old enough to ask "Still glad you bought it?" and not yet rated.
@immutable
class DueRegret {
  const DueRegret({
    required this.order,
    required this.line,
    required this.ageDays,
  });

  final Order order;
  final OrderLine line;
  final int ageDays;
}

/// The 14–30 day regret window, and how those answers move fit scores.
abstract final class RegretWindow {
  static const int opensAfterDays = 14;
  static const int closesAfterDays = 30;

  /// Kept lines bought between 14 and 30 days ago that have no check-in.
  static List<DueRegret> due({
    required List<Order> orders,
    required List<RegretCheckin> checkins,
    required DateTime now,
  }) {
    final rated = checkins.map((c) => c.productTitle).toSet();
    final prompts = <DueRegret>[];
    for (final order in orders) {
      final age = now.difference(order.placedAt).inDays;
      if (age < opensAfterDays || age > closesAfterDays) continue;
      for (final line in order.lines) {
        if (line.returned != null) continue;
        if (rated.contains(line.title)) continue;
        prompts.add(DueRegret(order: order, line: line, ageDays: age));
      }
    }
    return prompts;
  }

  /// Points to add to a product's fit from check-ins in its category.
  ///
  /// A regretted purchase pulls similar products down (up to −8). A purchase
  /// the user was glad about lifts them (up to +6). No history leaves the
  /// score untouched.
  static int nudge({
    required Product product,
    required List<RegretCheckin> checkins,
    required List<Product> catalog,
  }) {
    String? categoryOf(RegretCheckin checkin) {
      if (checkin.category != null && checkin.category!.isNotEmpty) {
        return checkin.category;
      }
      for (final item in catalog) {
        if (checkin.productId != null && item.id == checkin.productId) {
          return item.category;
        }
      }
      for (final item in catalog) {
        if (item.title == checkin.productTitle) return item.category;
      }
      return null;
    }

    final same = [
      for (final checkin in checkins)
        if (categoryOf(checkin) == product.category) checkin,
    ];
    if (same.isEmpty) return 0;
    final regretted = same.where((c) => c.isRegretted).length;
    final glad = same.where((c) => c.isWorthIt).length;
    return (-4 * regretted + 2 * glad).clamp(-8, 6);
  }
}

/// Personal regret rate, as a percentage of check-ins. Zero when unrated.
int regretRateOf(List<RegretCheckin> checkins) {
  if (checkins.isEmpty) return 0;
  final regretted = checkins.where((c) => c.isRegretted).length;
  return ((regretted / checkins.length) * 100).round();
}
