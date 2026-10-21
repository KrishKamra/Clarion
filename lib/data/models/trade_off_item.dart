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
  });

  /// Short label, e.g. "Intent Alignment".
  final String title;

  /// One-line evidence, e.g. "30L volume matches your college setup".
  final String detail;

  /// Contribution to the fit score; negative for trade-offs.
  final int weight;

  bool get isPositive => weight >= 0;
}
