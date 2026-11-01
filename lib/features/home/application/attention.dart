import 'package:flutter/foundation.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/regret_checkin_model.dart';
import '../../decision/application/watch_status.dart';
import '../../profile/application/regret_window.dart';

/// Why something is waiting on the user. Order is priority: a decision
/// that is ready beats a deadline, which beats a good price, which beats
/// a reflection.
enum AttentionKind { holdReady, returnClosing, targetHit, checkIn }

/// One thing that genuinely needs a decision now.
@immutable
class AttentionItem {
  const AttentionItem({
    required this.kind,
    required this.title,
    required this.detail,
    this.productId,
    this.orderId,
  });

  final AttentionKind kind;
  final String title;
  final String detail;
  final String? productId;
  final String? orderId;
}

/// Everything that needs the user, and nothing that merely could.
///
/// This is what makes Clarion something to open, settle and close: when
/// the list is empty the app says so, rather than offering more to look at.
abstract final class Attention {
  /// A return window this close to closing is worth a look.
  static const Duration returnHeadsUp = Duration(days: 3);

  static List<AttentionItem> collect({
    required Map<String, DateTime> holds,
    required Map<String, double?> watchlist,
    required List<Order> orders,
    required List<RegretCheckin> checkins,
    required Map<String, Product> products,
    required DateTime now,
  }) {
    final items = <AttentionItem>[];

    for (final MapEntry(key: id, value: endsAt) in holds.entries) {
      final product = products[id];
      if (product == null || endsAt.isAfter(now)) continue;
      items.add(
        AttentionItem(
          kind: AttentionKind.holdReady,
          title: product.title,
          detail: 'Cooling-off is over. Decide with a clear head.',
          productId: id,
        ),
      );
    }

    for (final order in orders) {
      final collected = order.collectedAt;
      if (collected == null || !order.canReturn(now)) continue;
      final closes = collected.add(Order.returnWindow);
      if (closes.difference(now) > returnHeadsUp) continue;
      final kept = order.lines.where((l) => l.returned == null).toList();
      if (kept.isEmpty) continue;
      final days = closes.difference(now).inHours ~/ 24;
      items.add(
        AttentionItem(
          kind: AttentionKind.returnClosing,
          title: kept.first.title,
          detail: days <= 0
              ? 'Return window closes today.'
              : 'Return window closes in $days ${days == 1 ? 'day' : 'days'}.',
          orderId: order.id,
        ),
      );
    }

    for (final MapEntry(key: id, value: target) in watchlist.entries) {
      final product = products[id];
      if (product == null) continue;
      if (watchVerdict(price: product.price, target: target) !=
          WatchVerdict.targetHit) {
        continue;
      }
      items.add(
        AttentionItem(
          kind: AttentionKind.targetHit,
          title: product.title,
          detail: 'At or below your target.',
          productId: id,
        ),
      );
    }

    final due = RegretWindow.due(orders: orders, checkins: checkins, now: now);
    for (final prompt in due) {
      items.add(
        AttentionItem(
          kind: AttentionKind.checkIn,
          title: prompt.line.title,
          detail: 'Still glad you bought it? One tap.',
          productId: prompt.line.productId,
        ),
      );
    }

    items.sort((a, b) => a.kind.index.compareTo(b.kind.index));
    return items;
  }
}
