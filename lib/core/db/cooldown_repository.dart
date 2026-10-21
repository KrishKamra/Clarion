import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Reads and writes 24h Cooling Off holds in the `cooldown_holds` table.
///
/// The repository only talks to SQLite. The Riverpod controller keeps the
/// in-memory state the UI watches and calls this to make changes durable.
class CooldownRepository {
  CooldownRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// Every saved hold as productId -> moment the hold expires.
  Future<Map<String, DateTime>> loadAll() async {
    final rows = await _db.query(AppDatabase.cooldownHoldsTable);
    return {
      for (final row in rows)
        row['product_id']! as String: DateTime.fromMillisecondsSinceEpoch(
          row['expires_at']! as int,
        ),
    };
  }

  /// Saves a hold, replacing any existing hold for the same product.
  Future<void> upsert(
    String productId,
    DateTime startedAt,
    DateTime expiresAt,
  ) async {
    await _db.insert(AppDatabase.cooldownHoldsTable, {
      'product_id': productId,
      'started_at': startedAt.millisecondsSinceEpoch,
      'expires_at': expiresAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Deletes the hold for [productId] (no-op if there isn't one).
  Future<void> remove(String productId) async {
    await _db.delete(
      AppDatabase.cooldownHoldsTable,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
