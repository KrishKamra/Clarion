import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/utils/formatters.dart';

/// Which side of a comparison wins a criterion.
enum CompareWinner { left, right, tie, none }

/// One aligned row of the differential compare matrix.
@immutable
class CompareRow {
  const CompareRow({
    required this.key,
    required this.label,
    required this.left,
    required this.right,
    required this.winner,
    required this.isDifferent,
  });

  final String key;
  final String label;
  final String left;
  final String right;
  final CompareWinner winner;
  final bool isDifferent;
}

/// Selected pair index + user-elevated priority criteria.
@immutable
class CompareState {
  const CompareState({required this.pairIndex, required this.priorities});

  final int pairIndex;
  final Set<String> priorities;

  ComparePair get pair => MockCatalog.comparePairs[pairIndex];
}

class CompareController extends Notifier<CompareState> {
  @override
  CompareState build() => CompareState(
    pairIndex: 0,
    priorities: {MockCatalog.comparePairs.first.priorityKeys.first},
  );

  void selectPair(int index) {
    final pair = MockCatalog.comparePairs[index];
    state = CompareState(
      pairIndex: index,
      priorities: {pair.priorityKeys.first},
    );
  }

  /// Opens the pair containing [productId], if one exists. Returns success.
  bool focusProduct(String productId) {
    final index = MockCatalog.comparePairs.indexWhere(
      (p) => p.leftId == productId || p.rightId == productId,
    );
    if (index < 0) return false;
    if (index != state.pairIndex) selectPair(index);
    return true;
  }

  void togglePriority(String key) {
    final next = {...state.priorities};
    if (!next.remove(key)) next.add(key);
    state = CompareState(pairIndex: state.pairIndex, priorities: next);
  }
}

final compareProvider = NotifierProvider<CompareController, CompareState>(
  CompareController.new,
);

/// Result of evaluating a pair against the user's priorities.
@immutable
class CompareResult {
  const CompareResult({
    required this.left,
    required this.right,
    required this.rows,
    required this.leftScore,
    required this.rightScore,
  });

  final Product left;
  final Product right;
  final List<CompareRow> rows;

  /// Weighted criterion wins (priorities count double).
  final double leftScore;
  final double rightScore;

  List<CompareRow> get differences => rows.where((r) => r.isDifferent).toList();
  List<CompareRow> get identical => rows.where((r) => !r.isDifferent).toList();

  CompareWinner get overall {
    if (leftScore == rightScore) return CompareWinner.tie;
    return leftScore > rightScore ? CompareWinner.left : CompareWinner.right;
  }
}

final compareResultProvider = Provider<CompareResult>((ref) {
  final state = ref.watch(compareProvider);
  final left = MockCatalog.byId(state.pair.leftId);
  final right = MockCatalog.byId(state.pair.rightId);

  final rows = <CompareRow>[
    _row(
      ProductSpec(
        key: 'price',
        label: 'Price',
        display: '',
        value: left.price,
        polarity: SpecPolarity.lowerIsBetter,
      ),
      ProductSpec(
        key: 'price',
        label: 'Price',
        display: '',
        value: right.price,
        polarity: SpecPolarity.lowerIsBetter,
      ),
      leftDisplay: Fmt.inr(left.price),
      rightDisplay: Fmt.inr(right.price),
    ),
  ];

  final keys = <String>[
    ...left.specs.map((s) => s.key),
    ...right.specs.map((s) => s.key).where((k) => left.spec(k) == null),
  ];
  for (final key in keys) {
    rows.add(_row(left.spec(key), right.spec(key)));
  }

  var leftScore = 0.0;
  var rightScore = 0.0;
  for (final row in rows) {
    final weight = state.priorities.contains(row.key) ? 2.0 : 1.0;
    if (row.winner == CompareWinner.left) leftScore += weight;
    if (row.winner == CompareWinner.right) rightScore += weight;
  }

  return CompareResult(
    left: left,
    right: right,
    rows: rows,
    leftScore: leftScore,
    rightScore: rightScore,
  );
});

CompareRow _row(
  ProductSpec? a,
  ProductSpec? b, {
  String? leftDisplay,
  String? rightDisplay,
}) {
  final spec = a ?? b!;
  final l = leftDisplay ?? a?.display ?? '—';
  final r = rightDisplay ?? b?.display ?? '—';
  final av = a?.value;
  final bv = b?.value;

  var winner = CompareWinner.none;
  if (av != null && bv != null && spec.polarity != SpecPolarity.neutral) {
    if (av == bv) {
      winner = CompareWinner.tie;
    } else {
      final leftBetter = spec.polarity == SpecPolarity.higherIsBetter
          ? av > bv
          : av < bv;
      winner = leftBetter ? CompareWinner.left : CompareWinner.right;
    }
  }

  return CompareRow(
    key: spec.key,
    label: spec.label,
    left: l,
    right: r,
    winner: winner,
    isDifferent: l != r,
  );
}
