import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// An owner's review: a star rating and what living with the product was
/// actually like. Clarion asks how long they have owned it, because a review
/// after three months says more than one written on the first day.
@immutable
class Review {
  const Review({
    required this.author,
    required this.rating,
    required this.body,
    required this.ownedFor,
    required this.date,
    this.title,
    this.verified = true,
    this.mine = false,
  });

  final String author;

  /// 1–5 stars.
  final int rating;
  final String? title;
  final String body;

  /// How long the author had owned it when writing, e.g. "3 months".
  final String ownedFor;
  final DateTime date;

  /// Bought through Clarion (or, for seed reviews, a verified owner).
  final bool verified;

  /// Written by the signed-in account.
  final bool mine;
}

/// How a product's ratings spread across one to five stars.
@immutable
class RatingSummary {
  const RatingSummary(this.average, this.count, this.histogram);

  /// Spreads [count] ratings so they average [average] in the J shape real
  /// ratings take: each star down from five holds a constant fraction `r`
  /// of the one above, with `r` found by bisection. Seed data only, until
  /// real rating counts come from a backend.
  factory RatingSummary.estimate(double average, int count) {
    // Ratings below three mirror the shape from the one-star end.
    final high = average >= 3;
    final target = high ? average : 6 - average;
    List<double> weights(double r) => [
      for (var star = 1; star <= 5; star++) math.pow(r, 5 - star).toDouble(),
    ];
    double mean(List<double> w) {
      final sum = w.fold<double>(0, (a, b) => a + b);
      return [for (var i = 0; i < 5; i++) w[i] * (i + 1)]
              .fold<double>(0, (a, b) => a + b) /
          sum;
    }

    var (lo, hi) = (0.0, 1.0);
    for (var i = 0; i < 40; i++) {
      final mid = (lo + hi) / 2;
      // A larger ratio flattens the spread and lowers the mean.
      (lo, hi) = mean(weights(mid)) > target ? (mid, hi) : (lo, mid);
    }
    final w = weights((lo + hi) / 2);
    final sum = w.fold<double>(0, (a, b) => a + b);
    final histogram = [for (final x in w) (count * x / sum).round()];
    return RatingSummary(
      average,
      count,
      high ? histogram : histogram.reversed.toList(),
    );
  }

  final double average;
  final int count;

  /// Ratings per star, index 0 = one star.
  final List<int> histogram;

  double shareOf(int star) {
    final total = histogram.fold<int>(0, (a, b) => a + b);
    return total == 0 ? 0 : histogram[star - 1] / total;
  }
}
