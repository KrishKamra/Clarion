import 'package:sqflite/sqflite.dart';

import '../../data/models/product_model.dart';
import 'app_database.dart';

/// Reads and writes Price Memory: the `price_observations` table (one price
/// per product per day) and the `watchlist` table (products being watched,
/// each with an optional target price).
class PriceWatchRepository {
  PriceWatchRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// `2026-10-22`: the text key used for `observed_on`. Sorts correctly as
  /// plain text, so `ORDER BY observed_on` is also chronological order.
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ── Price observations ─────────────────────────────────────────────────

  /// Records today's price for every product, and back-fills the days we have
  /// not seen yet from the catalogue's 30-day history.
  ///
  /// Safe to run on every launch: `UNIQUE (product_id, observed_on)` means a
  /// day is stored once. Past days are never overwritten (`ignore`); today's
  /// row is refreshed (`replace`) so the latest price always wins.
  Future<void> recordPrices(Iterable<Product> products) async {
    final batch = _db.batch();
    final today = dayKey(DateTime.now());

    for (final p in products) {
      for (final point in p.priceHistory) {
        batch.insert(AppDatabase.priceObservationsTable, {
          'product_id': p.id,
          'price': point.price,
          'observed_on': dayKey(point.date),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      batch.insert(AppDatabase.priceObservationsTable, {
        'product_id': p.id,
        'price': p.price,
        'observed_on': today,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// The last [days] days of recorded prices for [productId], oldest first.
  Future<List<PricePoint>> historyFor(String productId, {int days = 30}) async {
    final rows = await _db.query(
      AppDatabase.priceObservationsTable,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'observed_on DESC',
      limit: days,
    );
    return [
      for (final row in rows.reversed)
        PricePoint(
          DateTime.parse(row['observed_on']! as String),
          (row['price']! as num).toDouble(),
        ),
    ];
  }

  // ── Watchlist ──────────────────────────────────────────────────────────

  /// Every watched product as productId -> target price (`null` = no target).
  Future<Map<String, double?>> loadWatchlist() async {
    final rows = await _db.query(
      AppDatabase.watchlistTable,
      orderBy: 'added_at ASC',
    );
    return {
      for (final row in rows)
        row['product_id']! as String: (row['target_price'] as num?)?.toDouble(),
    };
  }

  /// Starts watching [productId], or updates its [targetPrice].
  Future<void> upsert(String productId, double? targetPrice) async {
    await _db.insert(AppDatabase.watchlistTable, {
      'product_id': productId,
      'target_price': targetPrice,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Stops watching [productId] (no-op if it was not watched).
  Future<void> remove(String productId) async {
    await _db.delete(
      AppDatabase.watchlistTable,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
