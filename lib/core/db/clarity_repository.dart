import 'package:sqflite/sqflite.dart';

import '../../data/models/clarity_models.dart';
import 'app_database.dart';

/// Savings goals, category ceilings, impulse signals and friend votes.
class ClarityRepository {
  ClarityRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.db;

  Future<List<SavingsGoal>> loadGoals() async {
    final rows = await _db.query(
      AppDatabase.savingsGoalsTable,
      orderBy: 'created_at ASC',
    );
    return [
      for (final row in rows)
        SavingsGoal(
          id: row['id']! as String,
          name: row['name']! as String,
          target: (row['target_amount']! as num).toDouble(),
          saved: (row['saved_amount']! as num).toDouble(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at']! as int,
          ),
        ),
    ];
  }

  Future<void> upsertGoal(SavingsGoal goal) async {
    await _db.insert(AppDatabase.savingsGoalsTable, {
      'id': goal.id,
      'name': goal.name,
      'target_amount': goal.target,
      'saved_amount': goal.saved,
      'created_at': goal.createdAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeGoal(String id) async {
    await _db.delete(
      AppDatabase.savingsGoalsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryBudget>> loadCategoryBudgets() async {
    final rows = await _db.query(AppDatabase.categoryBudgetsTable);
    return [
      for (final row in rows)
        CategoryBudget(
          category: row['category']! as String,
          monthlyLimit: (row['monthly_limit']! as num).toDouble(),
        ),
    ];
  }

  Future<void> upsertCategoryBudget(CategoryBudget budget) async {
    await _db.insert(AppDatabase.categoryBudgetsTable, {
      'category': budget.category,
      'monthly_limit': budget.monthlyLimit,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeCategoryBudget(String category) async {
    await _db.delete(
      AppDatabase.categoryBudgetsTable,
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<List<ImpulseEvent>> loadImpulseEvents() async {
    final rows = await _db.query(
      AppDatabase.impulseEventsTable,
      orderBy: 'occurred_at ASC',
    );
    return [
      for (final row in rows)
        ImpulseEvent(
          kind: row['kind']! as String,
          productId: row['product_id'] as String?,
          amount: (row['amount']! as num).toDouble(),
          at: DateTime.fromMillisecondsSinceEpoch(row['occurred_at']! as int),
        ),
    ];
  }

  Future<void> insertImpulse(ImpulseEvent event) async {
    await _db.insert(AppDatabase.impulseEventsTable, {
      'kind': event.kind,
      'product_id': event.productId,
      'amount': event.amount,
      'occurred_at': event.at.millisecondsSinceEpoch,
    });
  }

  Future<List<FriendVote>> loadVotes() async {
    final rows = await _db.query(
      AppDatabase.friendVotesTable,
      orderBy: 'voted_at ASC',
    );
    return [
      for (final row in rows)
        FriendVote(
          ballotId: row['ballot_id']! as String,
          choiceId: row['choice_id']! as String,
          voter: row['voter_label']! as String,
          leftId: row['left_id']! as String,
          rightId: row['right_id']! as String,
          at: DateTime.fromMillisecondsSinceEpoch(row['voted_at']! as int),
        ),
    ];
  }

  Future<void> upsertVote(FriendVote vote) async {
    await _db.insert(AppDatabase.friendVotesTable, {
      'ballot_id': vote.ballotId,
      'choice_id': vote.choiceId,
      'voter_label': vote.voter,
      'left_id': vote.leftId,
      'right_id': vote.rightId,
      'voted_at': vote.at.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
