import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// A cart line as stored on disk: product id, quantity and the intent
/// priority's name. The cart controller turns these back into full cart
/// items using the catalogue.
typedef SavedCartLine = ({String productId, int quantity, String priority});

/// Reads and writes the Intent Cart in the `cart_items` table.
class CartRepository {
  CartRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// Saved lines in on-screen order.
  Future<List<SavedCartLine>> loadAll() async {
    final rows = await _db.query(
      AppDatabase.cartItemsTable,
      orderBy: 'position ASC',
    );
    return [
      for (final row in rows)
        (
          productId: row['product_id']! as String,
          quantity: row['quantity']! as int,
          priority: row['priority']! as String,
        ),
    ];
  }

  /// Replaces the whole saved cart with [lines] in one transaction.
  ///
  /// A cart is a handful of rows, so rewriting it on every change is simpler
  /// and safer than tracking individual inserts, removes and swaps.
  /// (`added_at` therefore records when the cart was last saved.)
  Future<void> replaceAll(List<SavedCartLine> lines) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction((txn) async {
      await txn.delete(AppDatabase.cartItemsTable);
      final batch = txn.batch();
      for (var i = 0; i < lines.length; i++) {
        batch.insert(AppDatabase.cartItemsTable, {
          'product_id': lines[i].productId,
          'quantity': lines[i].quantity,
          'priority': lines[i].priority,
          'position': i,
          'added_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }
}
