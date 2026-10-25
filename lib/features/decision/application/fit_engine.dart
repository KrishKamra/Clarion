import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/trade_off_item.dart';

/// What the Heuristic Fit Engine knows about the user right now.
@immutable
class FitContext {
  const FitContext({
    required this.monthlyLimit,
    required this.spentThisMonth,
    this.keywords = const {},
    this.intentBudget,
  });

  /// Words from the stated goal, e.g. {college, setup}. Empty = no goal.
  final Set<String> keywords;

  /// The ceiling the user typed into the goal (e.g. "under 1600"), if any.
  final double? intentBudget;

  /// The monthly envelope and what is already settled against it.
  final double monthlyLimit;
  final double spentThisMonth;

  double get envelopeLeft => monthlyLimit - spentThisMonth;
}

/// A computed fit score and the signed lines that add up to it.
@immutable
class FitResult {
  const FitResult({required this.score, required this.items});

  /// 0–100. Always exactly the sum of [items]' weights.
  final int score;
  final List<TradeOffItem> items;

  /// Positive lines, biggest first.
  List<TradeOffItem> get reasons =>
      items.where((t) => t.isPositive).toList()
        ..sort((a, b) => b.weight.compareTo(a.weight));

  /// Negative lines (what the product asks of the user).
  List<TradeOffItem> get compromises =>
      items.where((t) => !t.isPositive).toList();

  /// The one or two lines worth showing on a small card.
  ///
  /// First: what this product does best, judged by how much of each rule's
  /// maximum it earned. The budget line is left out here because nearly
  /// everything shown already fits the budget, so it would be the same on
  /// every card. Second: its biggest concern, or a weak budget fit, or else
  /// its next-best strength.
  List<TradeOffItem> get highlights {
    final strengths =
        items
            .where(
              (t) =>
                  t.isPositive &&
                  t.verdict != 'Neutral' &&
                  t.title != FitEngine.budgetTitle,
            )
            .toList()
          ..sort((a, b) {
            final byShare = b.share.compareTo(a.share);
            return byShare != 0 ? byShare : b.weight.compareTo(a.weight);
          });
    final first = strengths.isNotEmpty ? strengths.first : items.first;

    final weakBudget = items.where(
      (t) => t.title == FitEngine.budgetTitle && t.share < 0.4,
    );
    final TradeOffItem? second = compromises.isNotEmpty
        ? compromises.first
        : (weakBudget.isNotEmpty
              ? weakBudget.first
              : (strengths.length > 1 ? strengths[1] : null));

    return [first, ?second];
  }

  /// The score in words: Great, Good, Fair or Poor fit.
  String get headline => FitEngine.headline(score);
}

/// Heuristic Fit Engine: computes a product's fit from four rules, then
/// subtracts penalties. Nothing is hardcoded per product.
///
/// The user sees plain words (Strong / Good / Weak) and an overall percentage.
/// The points below are only how the rules are weighted, a design choice that
/// can be tuned: matching the goal matters most, then the budget.
///
/// | Rule (shown as)      | Max | Looks at                                  |
/// |----------------------|-----|-------------------------------------------|
/// | Matches your goal    |  35 | goal words that match the product's tags  |
/// | Fits your budget     |  25 | share of your ceiling left after buying   |
/// | Good price right now |  20 | price against its 30-day average          |
/// | Owner reviews        |  20 | star rating                               |
///
/// Penalties (negative lines): over the monthly budget, above the goal's
/// price limit, and very few reviews. Penalties can never push the score below 0,
/// and the four rules add up to at most 100, so the score is always 0–100
/// and equals the sum of the lines shown.
abstract final class FitEngine {
  // Names shown to the user, in plain language.
  static const String intentTitle = 'Matches your goal';
  static const String budgetTitle = 'Fits your budget';
  static const String timingTitle = 'Good price right now';
  static const String ratingTitle = 'Owner reviews';
  static const String overBudgetTitle = 'Over your budget';
  static const String overCeilingTitle = 'Above your price limit';
  static const String fewReviewsTitle = 'Few reviews';

  static const int maxIntent = 35;
  static const int maxBudget = 25;
  static const int maxTiming = 20;
  static const int maxRating = 20;

  /// Intent points when the user has not stated a goal (neutral, not zero).
  static const int neutralIntent = 18;

  /// Products with fewer reviews than this lose a few points.
  static const int thinReviews = 150;

  static int _clamp(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

  /// "Strong" / "Good" / "Weak" from how much of a rule's maximum was earned.
  static String _strength(int points, int max) {
    final share = points / max;
    return share >= 0.75 ? 'Strong' : (share >= 0.4 ? 'Good' : 'Weak');
  }

  /// A score in words, so the number is never all the user has to go on.
  static String headline(int score) {
    if (score >= 80) return 'Great fit';
    if (score >= 60) return 'Good fit';
    if (score >= 40) return 'Fair fit';
    return 'Poor fit';
  }

  static FitResult evaluate(Product p, FitContext c) {
    // 1. Intent Alignment
    final int intentPoints;
    final String intentDetail;
    String? intentVerdict;
    if (c.keywords.isEmpty) {
      intentPoints = neutralIntent;
      intentDetail = 'You have not stated a goal yet';
      intentVerdict = 'Neutral';
    } else {
      final matched = c.keywords.where(p.matchesKeyword).toList()..sort();
      final needed = math.min(c.keywords.length, 3);
      final ratio = math.min(1.0, matched.length / needed);
      intentPoints = (maxIntent * ratio).round();
      intentDetail = matched.isEmpty
          ? 'Nothing here matches what you asked for'
          : 'Matches ${matched.length} of your goal words: '
                '${matched.join(', ')}';
    }

    // 2. Budget Safety (and the "over your limit" penalty)
    //
    // Measured against the whole ceiling, not a fixed slice of it, so every
    // change to the ceiling moves the score: the more of the ceiling a
    // purchase leaves untouched, the more points it earns.
    final left = c.envelopeLeft - p.price;
    final limit = c.monthlyLimit;
    final int budgetPoints;
    final String budgetDetail;
    int overLimitPenalty = 0;
    if (left >= 0) {
      final share = limit <= 0 ? 0.0 : math.min(1.0, left / limit);
      budgetPoints = 5 + (20 * share).round();
      budgetDetail =
          'Leaves ${Fmt.inr(left)} of your ${Fmt.inr(c.monthlyLimit)} monthly budget';
    } else {
      final share = limit <= 0 ? 1.0 : math.min(1.0, -left / limit);
      budgetPoints = 0;
      overLimitPenalty = 10 + (15 * share).round();
      budgetDetail = 'More than what is left of your monthly budget';
    }

    // 3. Price Timing: 0 points at 10% above average, 20 at 10% below.
    final discount = p.discountVsAverage;
    final timingPoints = _clamp((10 + discount * 100).round(), 0, maxTiming);
    final timingDetail = discount >= 0.01
        ? '${Fmt.percent(discount * 100)} cheaper than its usual price'
        : discount <= -0.01
        ? '${Fmt.percent(-discount * 100)} pricier than its usual price'
        : 'About its usual price';

    // 4. Owner Rating: 3.0 stars = 0 points, 4.0 = 10, 5.0 = 20.
    final ratingPoints = _clamp(((p.rating - 3) * 10).round(), 0, maxRating);

    final items = <TradeOffItem>[
      TradeOffItem(
        title: intentTitle,
        detail: intentDetail,
        weight: intentPoints,
        verdict: intentVerdict ?? _strength(intentPoints, maxIntent),
        max: maxIntent,
      ),
      TradeOffItem(
        title: budgetTitle,
        detail: budgetDetail,
        weight: budgetPoints,
        verdict: _strength(budgetPoints, maxBudget),
        max: maxBudget,
      ),
      TradeOffItem(
        title: timingTitle,
        detail: timingDetail,
        weight: timingPoints,
        verdict: _strength(timingPoints, maxTiming),
        max: maxTiming,
      ),
      TradeOffItem(
        title: ratingTitle,
        detail: '${p.rating}★ from ${p.reviewCount} owners',
        weight: ratingPoints,
        verdict: _strength(ratingPoints, maxRating),
        max: maxRating,
      ),
    ];

    // Penalties, in order. Each is capped so the total never goes below 0.
    var remaining = items.fold<int>(0, (sum, t) => sum + t.weight);
    void penalise(String title, String detail, int amount) {
      final taken = math.min(amount, remaining);
      if (taken <= 0) return;
      remaining -= taken;
      items.add(
        TradeOffItem(
          title: title,
          detail: detail,
          weight: -taken,
          verdict: 'Concern',
        ),
      );
    }

    if (overLimitPenalty > 0) {
      penalise(
        overBudgetTitle,
        '${Fmt.inr(-left)} more than what is left this month',
        overLimitPenalty,
      );
    }
    final ceiling = c.intentBudget;
    if (ceiling != null && p.price > ceiling) {
      penalise(
        overCeilingTitle,
        '${Fmt.inr(p.price - ceiling)} above the ${Fmt.inr(ceiling)} you set',
        _clamp(10 + ((p.price - ceiling) / ceiling * 50).round(), 10, 25),
      );
    }
    if (p.reviewCount < thinReviews) {
      penalise(fewReviewsTitle, 'Only ${p.reviewCount} owner reviews', 4);
    }

    final score = items.fold<int>(0, (sum, t) => sum + t.weight);
    return FitResult(score: score, items: List.unmodifiable(items));
  }
}
