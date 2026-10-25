import 'package:flutter/foundation.dart';

import '../../../data/models/product_model.dart';

enum ValuePathKind { refurbished, repair }

/// A refurbished buy or a repair, offered beside a new purchase.
@immutable
class ValuePath {
  const ValuePath({
    required this.kind,
    required this.price,
    required this.parity,
    required this.sustainability,
    required this.note,
  });

  final ValuePathKind kind;
  final double price;
  final int parity;

  /// 0–100. Higher means less new material.
  final int sustainability;
  final String note;

  double savingsAgainst(double newPrice) => newPrice - price;

  String get kindLabel =>
      kind == ValuePathKind.refurbished ? 'Refurbished' : 'Repair';
}

/// Refurbished and repair paths for products where the catalogue has one.
/// Kept separate from [swapSuggestionsProvider] so the Guardian's verified
/// product swap stays a single suggestion.
abstract final class ValueAlternatives {
  static List<ValuePath> forProduct(Product product) =>
      _paths[product.id] ?? const [];

  static const _paths = {
    'hp_pro': [
      ValuePath(
        kind: ValuePathKind.refurbished,
        price: 1299,
        parity: 92,
        sustainability: 84,
        note: 'Certified refurbished, full function, 6-month cover.',
      ),
      ValuePath(
        kind: ValuePathKind.repair,
        price: 499,
        parity: 88,
        sustainability: 96,
        note: 'Replace the ear pads and battery on a pair you already have.',
      ),
    ],
    'bp_atlas': [
      ValuePath(
        kind: ValuePathKind.refurbished,
        price: 1699,
        parity: 90,
        sustainability: 81,
        note: 'Same 30 L shell, inspected harness, 1-year cover.',
      ),
    ],
    'kb_loom': [
      ValuePath(
        kind: ValuePathKind.repair,
        price: 350,
        parity: 95,
        sustainability: 94,
        note: 'Switch and battery service instead of a new board.',
      ),
    ],
  };
}
