import 'package:flutter/foundation.dart';

/// One signed line of a product's fit breakdown: a reason it suits the
/// stated intent (positive weight) or a compromise it asks of the user
/// (negative weight). A product's weights sum exactly to its fit score.
@immutable
class TradeOffItem {
  const TradeOffItem({
    required this.title,
    required this.detail,
    required this.weight,
    this.verdict,
    this.max = 0,
  });

  /// Short label, e.g. "Intent Alignment".
  final String title;

  /// One-line evidence, e.g. "30L volume matches your college setup".
  final String detail;

  /// Contribution to the fit score; negative for trade-offs.
  final int weight;

  /// Plain-language reading of [weight] for display, e.g. "Strong" or
  /// "Concern". When null, widgets fall back to the signed number.
  final String? verdict;

  /// The most this line could contribute (0 when unknown, e.g. mock data).
  final int max;

  /// How much of the maximum was earned, 0 to 1 (0 when [max] is unknown).
  double get share => max <= 0 ? 0 : weight / max;

  bool get isPositive => weight >= 0;
}
