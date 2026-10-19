import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';

/// A parsed shopping intent, e.g. "College setup < ₹3k".
///
/// A deliberately small, on-device heuristic: it pulls out a price ceiling and
/// keyword set; the real decision engine would replace this.
@immutable
class IntentQuery {
  const IntentQuery({required this.raw, required this.keywords, this.budget});

  factory IntentQuery.parse(String input) {
    final text = input.trim();
    final lower = text.toLowerCase();

    double? budget;
    final match = _budgetPattern.firstMatch(lower);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (amount != null) {
        budget = match.group(2) != null ? amount * 1000 : amount;
      }
    }

    final keywords = lower
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.length > 2 && !_stopWords.contains(w))
        .toSet();

    return IntentQuery(raw: text, keywords: keywords, budget: budget);
  }

  static final RegExp _budgetPattern = RegExp(
    r'(?:<|under|below|within|max|upto|up to)\s*₹?\s*([\d,]+(?:\.\d+)?)\s*(k)?',
  );

  static const Set<String> _stopWords = {
    'for',
    'the',
    'and',
    'with',
    'under',
    'below',
    'within',
    'need',
    'want',
    'looking',
    'something',
    'good',
    'best',
    'buy',
    'get',
    'max',
    'upto',
  };

  final String raw;
  final Set<String> keywords;
  final double? budget;

  /// Products relevant to this intent: within budget, most keyword overlap
  /// first, then by fit score. Falls back to everything in budget.
  List<Product> rank(List<Product> catalog) {
    final affordable = catalog
        .where((p) => budget == null || p.price <= budget!)
        .toList();
    int overlap(Product p) => keywords.where(p.intentTags.contains).length;
    final relevant = affordable.where((p) => overlap(p) > 0).toList();
    final pool = relevant.isEmpty ? affordable : relevant;
    pool.sort((a, b) {
      final byOverlap = overlap(b).compareTo(overlap(a));
      return byOverlap != 0 ? byOverlap : b.fitScore.compareTo(a.fitScore);
    });
    return pool;
  }
}

class IntentController extends Notifier<IntentQuery?> {
  @override
  IntentQuery? build() => null;

  void submit(String input) {
    state = input.trim().isEmpty ? null : IntentQuery.parse(input);
  }

  void clear() => state = null;
}

final intentProvider = NotifierProvider<IntentController, IntentQuery?>(
  IntentController.new,
);

/// "Personal Fit Picks" for the current intent.
final fitPicksProvider = Provider<List<Product>>((ref) {
  final intent = ref.watch(intentProvider);
  final ranked = MockCatalog.rankedByFit;
  return intent == null ? ranked : intent.rank(ranked);
});
