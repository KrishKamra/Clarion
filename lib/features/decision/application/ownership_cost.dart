import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';

/// What a product costs once use, consumables and accessories are included.
@immutable
class OwnershipCost {
  const OwnershipCost({
    required this.usesPerYear,
    required this.costPerUse,
    required this.consumablesPerYear,
    required this.accessories,
    required this.firstYearTotal,
  });

  final int usesPerYear;

  /// Price spread across a year of expected use.
  final double costPerUse;
  final double consumablesPerYear;
  final double accessories;

  /// Sticker price plus a year of consumables and the accessories it needs.
  final double firstYearTotal;

  String get perUseLabel => '${Fmt.inr(costPerUse)} per use over a year';
}

/// Turns a sticker price into a year of use. Figures are category defaults
/// so every product can show them without a separate data feed.
abstract final class OwnershipCostEngine {
  static OwnershipCost of(Product product) {
    final profile = _profiles[product.category] ?? _fallback;
    final uses = profile.usesPerYear <= 0 ? 1 : profile.usesPerYear;
    final consumables = profile.consumablesPerYear;
    final accessories = profile.accessories;
    return OwnershipCost(
      usesPerYear: uses,
      costPerUse: product.price / uses,
      consumablesPerYear: consumables,
      accessories: accessories,
      firstYearTotal: product.price + consumables + accessories,
    );
  }

  static const _fallback = _UseProfile(200, 0, 0);

  static const _profiles = {
    'Bags': _UseProfile(365, 0, 180),
    'Audio': _UseProfile(300, 400, 0),
    'Study': _UseProfile(250, 0, 0),
    'Everyday': _UseProfile(300, 0, 0),
    'Power': _UseProfile(200, 0, 0),
  };
}

@immutable
class _UseProfile {
  const _UseProfile(
    this.usesPerYear,
    this.consumablesPerYear,
    this.accessories,
  );

  final int usesPerYear;
  final double consumablesPerYear;
  final double accessories;
}
