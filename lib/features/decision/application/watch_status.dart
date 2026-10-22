import '../../../data/models/product_model.dart';

/// Where a watched product stands against the user's target price.
enum WatchVerdict {
  /// Watching with no target set.
  noTarget,

  /// Price is at or below the target: a good time to decide.
  targetHit,

  /// Within 5% above the target.
  close,

  /// Still comfortably above the target.
  waiting,
}

/// Pure rule behind the Price Memory Watcher's "good time to buy" read.
WatchVerdict watchVerdict({required double price, double? target}) {
  if (target == null) return WatchVerdict.noTarget;
  if (price <= target) return WatchVerdict.targetHit;
  if (price <= target * 1.05) return WatchVerdict.close;
  return WatchVerdict.waiting;
}

/// Target prices offered for [product]: its 30-day low (rounded up to the
/// next rupee), then 5% and 10% below today's price (rounded to ₹10).
/// Highest first, with duplicates removed.
List<double> targetOptions(Product product) {
  double round10(double v) => (v / 10).round() * 10.0;

  final options = <double>{
    product.historyMin.ceilToDouble(),
    round10(product.price * 0.95),
    round10(product.price * 0.90),
  }.toList()..sort((a, b) => b.compareTo(a));

  // A target above today's price would be "hit" the moment it is set.
  final ceiling = product.price.ceilToDouble();
  return options.where((t) => t <= ceiling).toList();
}
