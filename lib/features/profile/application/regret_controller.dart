import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../data/models/regret_checkin_model.dart';

/// Aggregated stats derived from user regret check-ins.
@immutable
class RegretStats {
  const RegretStats({
    required this.totalCheckedIn,
    required this.worthItCount,
    required this.regrettedCount,
    required this.neutralCount,
    required this.regrettedAmount,
    required this.worthItAmount,
  });

  final int totalCheckedIn;
  final int worthItCount;
  final int regrettedCount;
  final int neutralCount;
  final double regrettedAmount;
  final double worthItAmount;

  /// Percentage of evaluated purchases rated "Worth it" (0-100).
  /// Defaults to 100 if no check-ins exist.
  int get mindfulScore {
    if (totalCheckedIn == 0) return 100;
    return ((worthItCount / totalCheckedIn) * 100).round();
  }

  /// Share of check-ins marked regretted, 0–100. Zero when nothing is rated.
  int get regretRate {
    if (totalCheckedIn == 0) return 0;
    return ((regrettedCount / totalCheckedIn) * 100).round();
  }
}

/// Manages post-purchase Regret Check-ins.
class RegretController extends Notifier<List<RegretCheckin>> {
  @override
  List<RegretCheckin> build() => ref.watch(initialRegretCheckinsProvider);

  /// Checks if a product/spend title has already been evaluated.
  bool isCheckedIn(String productTitle) {
    return state.any((c) => c.productTitle == productTitle);
  }

  /// Gets the existing check-in for a product title, if any.
  RegretCheckin? getCheckin(String productTitle) {
    for (final c in state) {
      if (c.productTitle == productTitle) return c;
    }
    return null;
  }

  /// Records or updates a post-purchase reflection check-in.
  Future<void> recordCheckin({
    int? spendId,
    required String productTitle,
    required double amount,
    required RegretRating rating,
    RegretTag? tag,
    String? note,
    String? productId,
    String? category,
  }) async {
    final now = DateTime.now();
    final existingIndex = state.indexWhere(
      (c) => c.productTitle == productTitle,
    );
    final previous = existingIndex >= 0 ? state[existingIndex] : null;
    final newCheckin = RegretCheckin(
      id: previous?.id,
      spendId: spendId,
      productTitle: productTitle,
      amount: amount,
      rating: rating,
      tag: tag,
      note: note,
      checkedInAt: now,
      productId: productId ?? previous?.productId,
      category: category ?? previous?.category,
    );

    if (existingIndex >= 0) {
      final updatedList = [...state];
      updatedList[existingIndex] = newCheckin;
      state = updatedList;
    } else {
      state = [newCheckin, ...state];
    }

    final repo = ref.read(regretRepositoryProvider);
    if (repo != null) {
      try {
        final saved = await repo.addCheckin(newCheckin);
        // Update state with generated ID if new
        final i = state.indexWhere((c) => c.productTitle == productTitle);
        if (i >= 0 && state[i].id == null) {
          final copy = [...state];
          copy[i] = saved;
          state = copy;
        }
      } catch (error, stack) {
        developer.log(
          'Could not save regret checkin',
          error: error,
          stackTrace: stack,
        );
      }
    }
  }

  /// Deletes a regret check-in.
  Future<void> removeCheckin(int id) async {
    state = state.where((c) => c.id != id).toList();
    final repo = ref.read(regretRepositoryProvider);
    if (repo != null) {
      try {
        await repo.removeCheckin(id);
      } catch (error, stack) {
        developer.log(
          'Could not remove regret checkin',
          error: error,
          stackTrace: stack,
        );
      }
    }
  }
}

final regretControllerProvider =
    NotifierProvider<RegretController, List<RegretCheckin>>(
      RegretController.new,
    );

/// Derived provider for aggregated regret stats.
final regretStatsProvider = Provider<RegretStats>((ref) {
  final checkins = ref.watch(regretControllerProvider);
  var worthItCount = 0;
  var regrettedCount = 0;
  var neutralCount = 0;
  var regrettedAmount = 0.0;
  var worthItAmount = 0.0;

  for (final c in checkins) {
    if (c.isWorthIt) {
      worthItCount++;
      worthItAmount += c.amount;
    } else if (c.isRegretted) {
      regrettedCount++;
      regrettedAmount += c.amount;
    } else {
      neutralCount++;
    }
  }

  return RegretStats(
    totalCheckedIn: checkins.length,
    worthItCount: worthItCount,
    regrettedCount: regrettedCount,
    neutralCount: neutralCount,
    regrettedAmount: regrettedAmount,
    worthItAmount: worthItAmount,
  );
});
