import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Whether a larger value of a spec is better for the user.
enum SpecPolarity { higherIsBetter, lowerIsBetter, neutral }

/// A single comparable product attribute, e.g. "Weight: 1.2 kg".
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

  /// Human readable value, e.g. `30 L`.
  final String display;

  /// Numeric value for winner calculation; `null` for qualitative specs.
  final double? value;
  final SpecPolarity polarity;
}

/// Polarity of an explainability factor.
enum FitFactorKind { match, tradeoff }

/// One line of the "Why we recommend this" explanation.
@immutable
class FitFactor {
  const FitFactor({
    required this.title,
    required this.detail,
    required this.points,
    this.kind = FitFactorKind.match,
  });

  final String title;
  final String detail;

  /// Contribution to the fit score; negative for trade-offs.
  final int points;
  final FitFactorKind kind;
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
    required this.fitTagline,
    required this.icon,
    required this.palette,
    required this.rating,
    required this.reviewCount,
    required this.specs,
    required this.fitFactors,
    required this.priceHistory,
    required this.intentTags,
    this.storeDistanceKm,
    this.alternativeId,
    this.alternativeParity,
  });

  final String id;
  final String brand;
  final String title;
  final String category;
  final double price;
  final double averagePrice30d;

  /// 0–100 match against the user's active intent.
  final int fitScore;

  /// One-line explainability summary shown on cards.
  final String fitTagline;

  /// Visual stand-in for product photography.
  final IconData icon;

  /// Two-stop gradient giving each product a distinct identity.
  final List<Color> palette;

  final double rating;
  final int reviewCount;
  final List<ProductSpec> specs;
  final List<FitFactor> fitFactors;

  /// Daily prices for the last 30 days, oldest first; last == [price].
  final List<double> priceHistory;

  /// Lower-case keywords used by the local intent matcher.
  final Set<String> intentTags;

  /// Distance to the nearest store with stock, if any.
  final double? storeDistanceKm;

  /// Cheaper, verified alternative the Budget Guardian may suggest.
  final String? alternativeId;

  /// Feature parity (0–100) of [alternativeId] relative to this product.
  final int? alternativeParity;

  /// Fraction below (positive) or above (negative) the 30-day average.
  double get discountVsAverage => 1 - price / averagePrice30d;

  bool get isPriceDrop => discountVsAverage >= 0.10;

  double get historyMin => priceHistory.reduce(math.min);
  double get historyMax => priceHistory.reduce(math.max);

  ProductSpec? spec(String key) {
    for (final s in specs) {
      if (s.key == key) return s;
    }
    return null;
  }
}
