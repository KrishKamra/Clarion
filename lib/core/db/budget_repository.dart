import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'demo_seed.dart';

/// One category's settled spending this month, as stored on disk.
typedef SavedSpend = ({String label, double amount});

/// The persisted part of the budget: the monthly envelope, the mindful stats
/// and this month's settled spend per category.
class StoredBudget {
  const StoredBudget({
    required this.monthlyLimit,
    required this.impulseBuysAvoided,
    required this.savedViaCooldown,
    required this.spend,
  });

  final double monthlyLimit;
  final int impulseBuysAvoided;
  final double savedViaCooldown;
  final List<SavedSpend> spend;
}

/// Reads and writes the `budget_profile` and `spend_entries` tables.
class BudgetRepository {
  BudgetRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  /// Loads the envelope and this month's spend. If the single profile row is
  /// missing it is created from the demo defaults first.
  Future<StoredBudget> load() async {
    final rows = await _db.query(
      AppDatabase.budgetProfileTable,
      where: 'id = 1',
      limit: 1,
    );

    double limit = DemoSeed.monthlyLimit;
    int avoided = DemoSeed.impulseBuysAvoided;
    double saved = DemoSeed.savedViaCooldown;

    if (rows.isEmpty) {
      await _db.insert(AppDatabase.budgetProfileTable, {
        'id': 1,
        'monthly_limit': limit,
        'impulse_buys_avoided': avoided,
        'saved_via_cooldown': saved,
      });
    } else {
      final row = rows.first;
      limit = (row['monthly_limit']! as num).toDouble();
      avoided = row['impulse_buys_avoided']! as int;
      saved = (row['saved_via_cooldown']! as num).toDouble();
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month).millisecondsSinceEpoch;
    final spendRows = await _db.rawQuery(
      'SELECT category, SUM(amount) AS total '
      'FROM ${AppDatabase.spendEntriesTable} '
      'WHERE spent_at >= ? '
      'GROUP BY category HAVING total > 0 ORDER BY MIN(id)',
      [monthStart],
    );

    return StoredBudget(
      monthlyLimit: limit,
      impulseBuysAvoided: avoided,
      savedViaCooldown: saved,
      spend: [
        for (final row in spendRows)
          (
            label: row['category']! as String,
            amount: (row['total']! as num).toDouble(),
          ),
      ],
    );
  }

  Future<void> setMonthlyLimit(double limit) async {
    await _db.update(AppDatabase.budgetProfileTable, {
      'monthly_limit': limit,
    }, where: 'id = 1');
  }

  /// Records a settled purchase. [category] is a free label: the checkout
  /// uses the product's name, so spend reads as a list of what was bought.
  Future<void> addSpend(String category, double amount) async {
    await _db.insert(AppDatabase.spendEntriesTable, {
      'category': category,
      'amount': amount,
      'spent_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Takes a refund back off the newest entry recorded this month under
  /// [category], never below zero. A refund for an earlier month leaves this
  /// month's spend alone.
  Future<void> refund(String category, double amount) async {
    final now = DateTime.now();
    await _db.rawUpdate(
      'UPDATE ${AppDatabase.spendEntriesTable} '
      'SET amount = MAX(amount - ?, 0) '
      'WHERE id = (SELECT id FROM ${AppDatabase.spendEntriesTable} '
      'WHERE category = ? AND spent_at >= ? ORDER BY id DESC LIMIT 1)',
      [amount, category, DateTime(now.year, now.month).millisecondsSinceEpoch],
    );
  }

  /// Credits one impulse buy avoided and the money it would have cost.
  Future<void> recordImpulseAvoided(double amount) async {
    await _db.rawUpdate(
      'UPDATE ${AppDatabase.budgetProfileTable} '
      'SET impulse_buys_avoided = impulse_buys_avoided + 1, '
      'saved_via_cooldown = saved_via_cooldown + ? '
      'WHERE id = 1',
      [amount],
    );
  }
}
