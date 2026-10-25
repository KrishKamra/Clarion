import 'package:sqflite/sqflite.dart';

import '../../data/models/regret_checkin_model.dart';
import 'app_database.dart';

/// Reads and writes Regret Check-in entries in SQLite.
class RegretRepository {
  RegretRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// Loads all saved regret check-ins, ordered by check-in time (newest first).
  Future<List<RegretCheckin>> loadAll() async {
    final rows = await _db.query(
      AppDatabase.regretCheckinsTable,
      orderBy: 'checked_in_at DESC',
    );
    return [
      for (final row in rows)
        RegretCheckin(
          id: row['id'] as int?,
          spendId: row['spend_id'] as int?,
          productTitle: row['product_title']! as String,
          amount: (row['amount']! as num).toDouble(),
          rating: RegretRating.values.firstWhere(
            (r) => r.name == row['rating'],
            orElse: () => RegretRating.worthIt,
          ),
          tag: row['tag'] == null
              ? null
              : RegretTag.values.firstWhere(
                  (t) => t.name == row['tag'],
                  orElse: () => RegretTag.asExpected,
                ),
          note: row['note'] as String?,
          checkedInAt: DateTime.fromMillisecondsSinceEpoch(
            row['checked_in_at']! as int,
          ),
        ),
    ];
  }

  /// Inserts a new check-in, or updates the saved one when [checkin] carries
  /// its row `id` (`replace` only matches on the primary key, so the id must
  /// be written or every edit would add a duplicate row).
  Future<RegretCheckin> addCheckin(RegretCheckin checkin) async {
    final id = await _db.insert(AppDatabase.regretCheckinsTable, {
      if (checkin.id != null) 'id': checkin.id,
      if (checkin.spendId != null) 'spend_id': checkin.spendId,
      'product_title': checkin.productTitle,
      'amount': checkin.amount,
      'rating': checkin.rating.name,
      'tag': checkin.tag?.name,
      'note': checkin.note,
      'checked_in_at': checkin.checkedInAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return checkin.copyWith(id: id);
  }

  /// Removes a check-in by its ID.
  Future<void> removeCheckin(int id) async {
    await _db.delete(
      AppDatabase.regretCheckinsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
