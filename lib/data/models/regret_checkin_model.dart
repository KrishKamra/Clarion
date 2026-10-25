import 'package:flutter/foundation.dart';

/// Rating given during post-purchase Regret Check-in.
enum RegretRating {
  worthIt('Worth it', '💚'),
  neutral('Neutral', '🪙'),
  regretted('Regretted', '💔');

  const RegretRating(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// Reflection tags categorising the outcome of a purchase decision.
enum RegretTag {
  asExpected('As expected', false),
  essential('Essential buy', false),
  greatValue('Great value', false),
  impulseBuy('Impulse buy', true),
  lowUtility('Low utility', true),
  overbudget('Over budget', true);

  const RegretTag(this.label, this.isNegative);

  final String label;
  final bool isNegative;
}

/// Post-purchase reflection recorded by the user.
@immutable
class RegretCheckin {
  const RegretCheckin({
    this.id,
    this.spendId,
    required this.productTitle,
    required this.amount,
    required this.rating,
    this.tag,
    this.note,
    required this.checkedInAt,
    this.productId,
    this.category,
  });

  final int? id;
  final int? spendId;
  final String productTitle;
  final double amount;
  final RegretRating rating;
  final RegretTag? tag;
  final String? note;
  final DateTime checkedInAt;

  /// Catalogue id and category, when the check-in was made from an order.
  /// Older rows leave these null and are matched by title.
  final String? productId;
  final String? category;

  bool get isWorthIt => rating == RegretRating.worthIt;
  bool get isRegretted => rating == RegretRating.regretted;
  bool get isNeutral => rating == RegretRating.neutral;

  RegretCheckin copyWith({
    int? id,
    int? spendId,
    String? productTitle,
    double? amount,
    RegretRating? rating,
    RegretTag? tag,
    String? note,
    DateTime? checkedInAt,
    String? productId,
    String? category,
  }) {
    return RegretCheckin(
      id: id ?? this.id,
      spendId: spendId ?? this.spendId,
      productTitle: productTitle ?? this.productTitle,
      amount: amount ?? this.amount,
      rating: rating ?? this.rating,
      tag: tag ?? this.tag,
      note: note ?? this.note,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      productId: productId ?? this.productId,
      category: category ?? this.category,
    );
  }
}
