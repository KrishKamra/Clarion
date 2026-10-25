import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';
import '../../cart/application/budget_controller.dart';
import '../../decision/application/fit_engine.dart';
import '../../profile/application/regret_controller.dart';
import '../../profile/application/regret_window.dart';

/// A parsed shopping intent, e.g. "Daily EDC for College < ₹2,500".
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
    'seeking',
    'accomplish',
  };

  final String raw;
  final Set<String> keywords;
  final double? budget;

  /// Products relevant to this intent: within budget and matching at least
  /// one goal word, most overlap first, then by fit score.
  ///
  /// A goal with words that match nothing in the catalogue returns an empty
  /// list (the app says "no matches found"); only a goal with no words at all,
  /// such as "under 2000", falls back to everything within budget.
  ///
  /// [scoreOf] supplies the fit score used to break ties (the live computed
  /// score); it defaults to the product's built-in score.
  List<Product> rank(List<Product> catalog, {int Function(Product)? scoreOf}) {
    final score = scoreOf ?? ((Product p) => p.fitScore);
    final affordable = catalog
        .where((p) => budget == null || p.price <= budget!)
        .toList();
    int overlap(Product p) => keywords.where(p.matchesKeyword).length;
    final pool = keywords.isEmpty
        ? affordable
        : affordable.where((p) => overlap(p) > 0).toList();
    pool.sort((a, b) {
      final byOverlap = overlap(b).compareTo(overlap(a));
      return byOverlap != 0 ? byOverlap : score(b).compareTo(score(a));
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

  /// Applies a reading that may have come from the on-device parser or a model.
  void apply(IntentQuery query) {
    state = query.raw.trim().isEmpty ? null : query;
  }

  void clear() => state = null;
}

final intentProvider = NotifierProvider<IntentController, IntentQuery?>(
  IntentController.new,
);

/// The Heuristic Fit Engine's verdict for one product, recomputed whenever
/// the stated goal or the monthly budget changes.
final fitProvider = Provider.family<FitResult, String>((ref, productId) {
  final catalog = ref.watch(catalogProvider);
  final product = catalog.byId(productId);
  final intent = ref.watch(intentProvider);
  final budget = ref.watch(budgetProvider);
  final checkins = ref.watch(regretControllerProvider);
  return FitEngine.evaluate(
    product,
    FitContext(
      keywords: intent?.keywords ?? const {},
      intentBudget: intent?.budget,
      monthlyLimit: budget.monthlyLimit,
      spentThisMonth: budget.spentThisMonth,
      regretNudge: RegretWindow.nudge(
        product: product,
        checkins: checkins,
        catalog: catalog.products,
      ),
    ),
  );
});

/// The Curated Fit Stream for the current intent, ranked by computed fit.
final fitPicksProvider = Provider<List<Product>>((ref) {
  final intent = ref.watch(intentProvider);
  final all = ref.watch(catalogProvider).products;
  final scores = {
    for (final p in all) p.id: ref.watch(fitProvider(p.id)).score,
  };
  int scoreOf(Product p) => scores[p.id] ?? p.fitScore;
  final ranked = [...all]..sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));
  return intent == null ? ranked : intent.rank(ranked, scoreOf: scoreOf);
});
