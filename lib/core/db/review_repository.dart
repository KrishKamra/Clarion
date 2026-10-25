import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// The account's own review of one product, as stored on disk.
typedef SavedReview = ({
  String productId,
  int rating,
  String? title,
  String body,
  DateTime createdAt,
});

/// Reads and writes the `reviews` table: one review per product.
class ReviewRepository {
  ReviewRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  Future<List<SavedReview>> loadAll() async {
    final rows = await _db.query(AppDatabase.reviewsTable);
    return [
      for (final r in rows)
        (
          productId: r['product_id']! as String,
          rating: r['rating']! as int,
          title: r['title'] as String?,
          body: r['body']! as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            r['created_at']! as int,
          ),
        ),
    ];
  }

  /// Saves the review, replacing an earlier one for the same product.
  Future<void> save(SavedReview review) async {
    await _db.insert(AppDatabase.reviewsTable, {
      'product_id': review.productId,
      'rating': review.rating,
      'title': review.title,
      'body': review.body,
      'created_at': review.createdAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(String productId) async {
    await _db.delete(
      AppDatabase.reviewsTable,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
