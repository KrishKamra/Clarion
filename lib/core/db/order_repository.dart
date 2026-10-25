import 'package:sqflite/sqflite.dart';

import '../../data/models/order_model.dart';
import 'app_database.dart';

/// Reads and writes the `orders` and `order_lines` tables.
class OrderRepository {
  OrderRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// Every order with its lines, newest first.
  Future<List<Order>> loadAll() async {
    final orders = await _db.query(
      AppDatabase.ordersTable,
      orderBy: 'placed_at DESC',
    );
    final lines = await _db.query(
      AppDatabase.orderLinesTable,
      orderBy: 'position',
    );
    final reasons = ReturnReason.values.asNameMap();
    return [
      for (final o in orders)
        Order(
          id: o['id']! as String,
          placedAt: _time(o['placed_at'])!,
          pickupArea: o['pickup_area'] as String?,
          collectedAt: _time(o['collected_at']),
          lines: [
            for (final l in lines)
              if (l['order_id'] == o['id'])
                OrderLine(
                  productId: l['product_id']! as String,
                  title: l['title']! as String,
                  price: (l['price']! as num).toDouble(),
                  quantity: l['quantity']! as int,
                  returned: l['returned_at'] == null
                      ? null
                      : ReturnRequest(
                          reason:
                              reasons[l['return_reason']] ??
                              ReturnReason.changedMind,
                          requestedAt: _time(l['returned_at'])!,
                          beforePickup: l['before_pickup'] == 1,
                        ),
                ),
          ],
        ),
    ];
  }

  Future<void> insert(Order order) async {
    final batch = _db.batch();
    batch.insert(AppDatabase.ordersTable, {
      'id': order.id,
      'placed_at': order.placedAt.millisecondsSinceEpoch,
      'pickup_area': order.pickupArea,
    });
    for (final (i, line) in order.lines.indexed) {
      batch.insert(AppDatabase.orderLinesTable, {
        'order_id': order.id,
        'product_id': line.productId,
        'title': line.title,
        'price': line.price,
        'quantity': line.quantity,
        'position': i,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> markCollected(String orderId, DateTime at) async {
    await _db.update(
      AppDatabase.ordersTable,
      {'collected_at': at.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> recordReturn(
    String orderId,
    String productId,
    ReturnRequest request,
  ) async {
    await _db.update(
      AppDatabase.orderLinesTable,
      {
        'return_reason': request.reason.name,
        'returned_at': request.requestedAt.millisecondsSinceEpoch,
        'before_pickup': request.beforePickup ? 1 : 0,
      },
      where: 'order_id = ? AND product_id = ?',
      whereArgs: [orderId, productId],
    );
  }

  static DateTime? _time(Object? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms as int);
}
