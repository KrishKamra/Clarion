import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../data/models/clarity_models.dart';

class SavingsController extends Notifier<List<SavingsGoal>> {
  @override
  List<SavingsGoal> build() => ref.watch(initialSavingsGoalsProvider);

  void add({required String name, required double target}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || target <= 0) return;
    final goal = SavingsGoal(
      id: 'goal-${DateTime.now().microsecondsSinceEpoch}',
      name: trimmed,
      target: target,
      createdAt: DateTime.now(),
    );
    state = [...state, goal];
    _write(ref.read(clarityRepositoryProvider)?.upsertGoal(goal));
  }

  void remove(String id) {
    state = [
      for (final goal in state)
        if (goal.id != id) goal,
    ];
    _write(ref.read(clarityRepositoryProvider)?.removeGoal(id));
  }
}

class CategoryBudgetController extends Notifier<List<CategoryBudget>> {
  @override
  List<CategoryBudget> build() => ref.watch(initialCategoryBudgetsProvider);

  void set(String category, double limit) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    if (limit <= 0) {
      state = [
        for (final budget in state)
          if (budget.category != trimmed) budget,
      ];
      _write(
        ref.read(clarityRepositoryProvider)?.removeCategoryBudget(trimmed),
      );
      return;
    }
    final budget = CategoryBudget(category: trimmed, monthlyLimit: limit);
    state = [
      for (final existing in state)
        if (existing.category != trimmed) existing,
      budget,
    ];
    _write(ref.read(clarityRepositoryProvider)?.upsertCategoryBudget(budget));
  }
}

void _write(Future<void>? write) {
  write?.catchError((Object error, StackTrace stack) {
    developer.log(
      'Could not save savings change',
      error: error,
      stackTrace: stack,
    );
  });
}

final savingsGoalsProvider =
    NotifierProvider<SavingsController, List<SavingsGoal>>(
      SavingsController.new,
    );

final categoryBudgetsProvider =
    NotifierProvider<CategoryBudgetController, List<CategoryBudget>>(
      CategoryBudgetController.new,
    );
