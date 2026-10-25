import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'trade_off_item.dart';

/// Whether a larger value of a spec is better for the user.
enum SpecPolarity { higherIsBetter, lowerIsBetter, neutral }

/// A single comparable product attribute, e.g. "Weight: 1.1 kg".
@immutable
class ProductSpec {
  const ProductSpec({
    required this.key,
    required this.label,
    required this.display,
    this.value,
    this.polarity = SpecPolarity.neutral,
  });

  /// Stable key used to align rows across products in the compare matrix.
  final String key;
  final String label;

  /// Human-readable value, e.g. `30 L`.
  final String display;

  /// Numeric value for winner calculation; `null` for qualitative specs.
  final double? value;
  final SpecPolarity polarity;
}

/// One day's closing price.
@immutable
class PricePoint {
  const PricePoint(this.date, this.price);

  final DateTime date;
  final double price;
}

/// A local store holding stock for same-day pickup.
@immutable
class PickupPoint {
  const PickupPoint(this.area, this.distanceKm);

  final String area;
  final double distanceKm;

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';
}

/// A product as evaluated by Clarion's decision-support engine.
@immutable
class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.title,
    required this.category,
    required this.price,
    required this.averagePrice30d,
    required this.fitScore,
    required this.rationale,
    required this.icon,
    required this.tone,
    required this.rating,
    required this.reviewCount,
    required this.specs,
    required this.tradeOffs,
    required this.priceHistory,
    required this.intentTags,
    this.pickup,
    this.alternativeId,
    this.alternativeParity,
  });

  final String id;
  final String brand;
  final String title;
  final String category;
  final double price;

  /// 30-day moving average.
  final double averagePrice30d;

  /// 0–100 match against the user's active intent.
  final int fitScore;

  /// Single-line explainability summary for cards.
  final String rationale;

  /// Glyph standing in for product photography.
  final IconData icon;

  /// A single muted hue that tints the product's stage light.
  final Color tone;

  final double rating;
  final int reviewCount;
  final List<ProductSpec> specs;

  /// Signed fit factors; weights sum exactly to [fitScore].
  final List<TradeOffItem> tradeOffs;

  /// Daily prices for the last 30 days, oldest first; last == [price].
  final List<PricePoint> priceHistory;

  /// Lower-case keywords used by the local intent matcher.
  final Set<String> intentTags;

  /// Nearest store with stock, if any.
  final PickupPoint? pickup;

  /// Cheaper, verified alternative the Budget Guardian may suggest.
  final String? alternativeId;

  /// Spec parity (0–100) of [alternativeId] relative to this product.
  final int? alternativeParity;

  /// Where a product photo is looked for, in order: drop `<id>.jpg` (or
  /// `.png` / `.webp`) into `assets/products/`. Without one, the product keeps
  /// its glyph on the studio stage.
  static const List<String> imageExtensions = ['jpg', 'png', 'webp'];

  List<String> get imageAssets => [
    for (final ext in imageExtensions) 'assets/products/$id.$ext',
  ];

  /// Whether a word from the user's goal describes this product: a goal tag,
  /// or a word in its brand, name or category. Plurals are treated alike, so
  /// "headphone" finds headphones.
  bool matchesKeyword(String word) {
    final w = _stem(word.toLowerCase());
    bool hit(String term) => _stem(term) == w;
    if (intentTags.any(hit)) return true;
    return '$brand $title $category'
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.isNotEmpty)
        .any(hit);
  }

  static String _stem(String s) =>
      s.length > 3 && s.endsWith('s') ? s.substring(0, s.length - 1) : s;

  /// Fraction below (positive) or above (negative) the 30-day average.
  double get discountVsAverage => 1 - price / averagePrice30d;

  double get historyMin => priceHistory.map((p) => p.price).reduce(math.min);
  double get historyMax => priceHistory.map((p) => p.price).reduce(math.max);

  /// Where today's price sits inside its 30-day band: 0 = low, 1 = high.
  double get bandPosition {
    final span = historyMax - historyMin;
    return span <= 0 ? 0.5 : (price - historyMin) / span;
  }

  List<TradeOffItem> get reasons =>
      tradeOffs.where((t) => t.isPositive).toList()
        ..sort((a, b) => b.weight.compareTo(a.weight));

  List<TradeOffItem> get compromises =>
      tradeOffs.where((t) => !t.isPositive).toList();

  ProductSpec? spec(String key) {
    for (final s in specs) {
      if (s.key == key) return s;
    }
    return null;
  }
}
