import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';

/// Recommendation outcome for the "Buy now or wait?" timing analysis.
enum BuyOrWaitRecommendation {
  buyNow('Buy now', '🟢'),
  wait('Wait', '⏳');

  const BuyOrWaitRecommendation(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// Confidence level in the price dip prediction.
enum PredictionConfidence {
  high('High confidence', 0.85),
  medium('Medium confidence', 0.68),
  low('Low confidence', 0.48);

  const PredictionConfidence(this.label, this.defaultPercentage);

  final String label;
  final double defaultPercentage;
}

/// Result of analyzing historical price trends to predict price dips and timing.
@immutable
class PriceDipVerdict {
  const PriceDipVerdict({
    required this.recommendation,
    required this.headline,
    required this.explanation,
    required this.estimatedSavings,
    required this.estimatedWaitWeeks,
    required this.confidence,
    required this.confidencePercentage,
  });

  final BuyOrWaitRecommendation recommendation;
  final String headline;
  final String explanation;

  /// Expected rupee savings if waiting; 0 if recommendation is [buyNow].
  final double estimatedSavings;

  /// Expected wait time in weeks; 0 if recommendation is [buyNow].
  final int estimatedWaitWeeks;

  final PredictionConfidence confidence;
  final int confidencePercentage;

  bool get shouldWait => recommendation == BuyOrWaitRecommendation.wait;
  bool get shouldBuyNow => recommendation == BuyOrWaitRecommendation.buyNow;
}

/// Analyzes product price history and category dynamics to generate
/// plain-language "Buy now or wait?" dip predictions and confidence ratings.
abstract final class PricePredictionEngine {
  /// Evaluates a product's price history and predicts whether price will dip.
  static PriceDipVerdict analyze(Product product) {
    final current = product.price;
    final minPrice = product.historyMin;
    final avgPrice = product.averagePrice30d;
    final pos = product.bandPosition; // 0.0 at low, 1.0 at high

    final history = product.priceHistory;

    // Calculate volatility (standard deviation of 30d prices)
    final mean = avgPrice;
    final sumSquares = history.fold<double>(
      0.0,
      (sum, p) => sum + math.pow(p.price - mean, 2),
    );
    final variance = history.isEmpty ? 0.0 : sumSquares / history.length;
    final stdDev = math.sqrt(variance);
    final volatilityRatio = mean == 0 ? 0.0 : stdDev / mean;

    // Count recent dips below average in history
    final dipCount = history.where((p) => p.price <= avgPrice * 0.96).length;

    // Rule 1: Current price is near 30-day low (bottom 20% of range or within 3% of min)
    if (pos <= 0.20 || current <= minPrice * 1.03) {
      final confidencePct = (82 + (0.20 - pos).clamp(0.0, 0.20) * 50).round();
      return PriceDipVerdict(
        recommendation: BuyOrWaitRecommendation.buyNow,
        headline: 'Buy now — Price at 30-day floor',
        explanation:
            'Today’s price of ${Fmt.inr(current)} sits at or near the 30-day lowest (${Fmt.inr(minPrice)}). Further price drops are unlikely in the near term.',
        estimatedSavings: 0,
        estimatedWaitWeeks: 0,
        confidence: PredictionConfidence.high,
        confidencePercentage: confidencePct.clamp(80, 95),
      );
    }

    // Rule 2: Current price is noticeably elevated above 30-day average or high in band
    if (pos >= 0.45 || current > avgPrice * 1.02) {
      final expectedDipTarget = math.max(minPrice, avgPrice * 0.94);
      final rawSavings = current - expectedDipTarget;

      // Round savings to clean increments (nearest 50/100)
      final estimatedSavings = _roundSavings(rawSavings);
      final waitWeeks = (pos * 3.5).round().clamp(1, 4);

      // Category / festival awareness text
      final category = product.category;
      final categoryText = _getCategoryTrendNote(category, waitWeeks);

      final confidencePct = volatilityRatio > 0.05 || dipCount >= 3
          ? (78 + (pos * 12)).round()
          : (62 + (pos * 10)).round();

      final confidenceLevel = confidencePct >= 75
          ? PredictionConfidence.high
          : PredictionConfidence.medium;

      return PriceDipVerdict(
        recommendation: BuyOrWaitRecommendation.wait,
        headline:
            'Waiting ~$waitWeeks weeks likely saves ${Fmt.inr(estimatedSavings)}',
        explanation:
            '$categoryText Waiting ~$waitWeeks weeks likely saves ${Fmt.inr(estimatedSavings)} when price returns to historical dip levels.',
        estimatedSavings: estimatedSavings,
        estimatedWaitWeeks: waitWeeks,
        confidence: confidenceLevel,
        confidencePercentage: confidencePct.clamp(55, 92),
      );
    }

    // Rule 3: Price is near typical 30-day average
    final potentialSavings = _roundSavings(current - minPrice);
    if (potentialSavings >= 150) {
      return PriceDipVerdict(
        recommendation: BuyOrWaitRecommendation.wait,
        headline: 'Wait & Watch — Dip expected in ~2 weeks',
        explanation:
            'Price is currently fair at ${Fmt.inr(current)}, but periodic dips to ${Fmt.inr(minPrice)} occur every 2–3 weeks, potentially saving ${Fmt.inr(potentialSavings)}.',
        estimatedSavings: potentialSavings,
        estimatedWaitWeeks: 2,
        confidence: PredictionConfidence.medium,
        confidencePercentage: 68,
      );
    }

    return PriceDipVerdict(
      recommendation: BuyOrWaitRecommendation.buyNow,
      headline: 'Buy now — Stable typical price',
      explanation:
          'Today’s price of ${Fmt.inr(current)} is consistent with its 30-day average (${Fmt.inr(avgPrice)}) with low historical volatility.',
      estimatedSavings: 0,
      estimatedWaitWeeks: 0,
      confidence: PredictionConfidence.high,
      confidencePercentage: 80,
    );
  }

  static double _roundSavings(double raw) {
    if (raw <= 0) return 0;
    if (raw < 100) return (raw / 10).round() * 10.0;
    if (raw < 500) return (raw / 50).round() * 50.0;
    return (raw / 100).round() * 100.0;
  }

  static String _getCategoryTrendNote(String category, int waitWeeks) {
    switch (category.toLowerCase()) {
      case 'audio':
      case 'electronics':
        return 'Prices for $category gear usually drop before festival sales;';
      case 'backpacks':
      case 'bags':
      case 'commute':
        return 'Seasonal promotions for $category frequently trigger price dips;';
      case 'desk setup':
      case 'accessories':
        return 'Flash discounts for $category occur regularly in bi-weekly cycles;';
      default:
        return 'Historical trend data indicates cyclic price dips;';
    }
  }
}
