import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';

/// Seed data standing in for the decision-engine backend.
///
/// Fit factor points intentionally sum to each product's fit score
/// (base relevance + matches − trade-offs) so the explainability card is
/// arithmetically honest.
abstract final class MockCatalog {
  static final List<Product> products = [
    Product(
      id: 'bp_atlas',
      brand: 'Northpeak',
      title: 'Atlas 30L Commuter Daypack',
      category: 'Bags',
      price: 2299,
      averagePrice30d: 2540,
      fitScore: 92,
      fitTagline: 'Within ₹2,500 budget • High durability rating',
      icon: Icons.backpack_rounded,
      palette: const [Color(0xFF4F46E5), Color(0xFF06B6D4)],
      rating: 4.6,
      reviewCount: 2184,
      storeDistanceKm: 1.8,
      alternativeId: 'bp_metro',
      alternativeParity: 89,
      intentTags: const {
        'college',
        'backpack',
        'bag',
        'edc',
        'minimalist',
        'laptop',
        'study',
        'setup',
        'commute',
      },
      specs: const [
        ProductSpec(
          key: 'capacity',
          label: 'Capacity',
          display: '30 L',
          value: 30,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '1.2 kg',
          value: 1.2,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'laptop',
          label: 'Laptop sleeve',
          display: '16"',
          value: 16,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'water',
          label: 'Water resistance',
          display: 'IPX4',
          value: 4,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'warranty',
          label: 'Warranty',
          display: '2 years',
          value: 2,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'material',
          label: 'Material',
          display: 'Recycled 600D PET',
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "college setup" and daily commute',
          points: 28,
        ),
        FitFactor(
          title: 'Fits budget',
          detail: '₹2,299 vs your ₹2,500 target',
          points: 25,
        ),
        FitFactor(
          title: 'Spec match',
          detail: '30L capacity meets college requirement',
          points: 35,
        ),
        FitFactor(
          title: 'Durability',
          detail: '4.6★ across 2,184 verified reviews',
          points: 12,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: '1.2 kg is slightly above your lightweight preference',
          points: -8,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 11, average: 2540, current: 2299),
    ),
    Product(
      id: 'bp_metro',
      brand: 'Terrain',
      title: 'Metro 28L Everyday Backpack',
      category: 'Bags',
      price: 1899,
      averagePrice30d: 1950,
      fitScore: 86,
      fitTagline: '₹400 cheaper • Lightest in class at 0.95 kg',
      icon: Icons.work_outline_rounded,
      palette: const [Color(0xFF0EA5E9), Color(0xFF8B5CF6)],
      rating: 4.3,
      reviewCount: 964,
      storeDistanceKm: 3.4,
      intentTags: const {
        'college',
        'backpack',
        'bag',
        'minimalist',
        'laptop',
        'study',
        'commute',
      },
      specs: const [
        ProductSpec(
          key: 'capacity',
          label: 'Capacity',
          display: '28 L',
          value: 28,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '0.95 kg',
          value: 0.95,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'laptop',
          label: 'Laptop sleeve',
          display: '15.6"',
          value: 15.6,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'water',
          label: 'Water resistance',
          display: 'IPX3',
          value: 3,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'warranty',
          label: 'Warranty',
          display: '1 year',
          value: 1,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'material',
          label: 'Material',
          display: 'Recycled 600D PET',
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "college setup"',
          points: 28,
        ),
        FitFactor(
          title: 'Fits budget',
          detail: '₹1,899 leaves ₹601 under your target',
          points: 30,
        ),
        FitFactor(
          title: 'Lightweight',
          detail: '0.95 kg meets your lightweight preference',
          points: 22,
        ),
        FitFactor(
          title: 'Spec match',
          detail: '28L fits a 15.6" laptop plus books',
          points: 14,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: 'Only 1-year warranty',
          points: -8,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 12, average: 1950, current: 1899),
    ),
    Product(
      id: 'hp_q30',
      brand: 'Arcus Audio',
      title: 'Q30 Hybrid ANC Headphones',
      category: 'Audio',
      price: 1899,
      averagePrice30d: 2099,
      fitScore: 88,
      fitTagline: '−35 dB ANC for library focus • 40h battery',
      icon: Icons.headphones_rounded,
      palette: const [Color(0xFF7C3AED), Color(0xFFDB2777)],
      rating: 4.5,
      reviewCount: 5310,
      storeDistanceKm: 4.2,
      alternativeId: 'hp_flow',
      alternativeParity: 94,
      intentTags: const {
        'noise',
        'canceling',
        'cancelling',
        'anc',
        'study',
        'focus',
        'headphones',
        'audio',
        'college',
        'setup',
      },
      specs: const [
        ProductSpec(
          key: 'anc',
          label: 'Noise reduction',
          display: '−35 dB',
          value: 35,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'battery',
          label: 'Battery',
          display: '40 h',
          value: 40,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '265 g',
          value: 265,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'latency',
          label: 'Latency',
          display: '120 ms',
          value: 120,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(key: 'codec', label: 'Hi-res codec', display: 'LDAC'),
        ProductSpec(
          key: 'warranty',
          label: 'Warranty',
          display: '1 year',
          value: 1,
          polarity: SpecPolarity.higherIsBetter,
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "noise-canceling for study"',
          points: 30,
        ),
        FitFactor(
          title: 'Spec match',
          detail: '−35 dB ANC blocks dorm & library noise',
          points: 30,
        ),
        FitFactor(
          title: 'Battery life',
          detail: '40 h covers a full study week',
          points: 20,
        ),
        FitFactor(
          title: 'Fits budget',
          detail: '₹1,899 vs your ₹2,000 audio target',
          points: 12,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: '265 g is heavier than the 240 g class average',
          points: -4,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 21, average: 2099, current: 1899),
    ),
    Product(
      id: 'hp_flow',
      brand: 'Sonique',
      title: 'Flow ANC Wireless Headphones',
      category: 'Audio',
      price: 1499,
      averagePrice30d: 1649,
      fitScore: 86,
      fitTagline: 'Verified alternative • 94% feature parity',
      icon: Icons.headset_rounded,
      palette: const [Color(0xFF0891B2), Color(0xFF6366F1)],
      rating: 4.4,
      reviewCount: 3876,
      storeDistanceKm: 2.6,
      intentTags: const {
        'noise',
        'canceling',
        'cancelling',
        'anc',
        'study',
        'focus',
        'headphones',
        'audio',
        'college',
      },
      specs: const [
        ProductSpec(
          key: 'anc',
          label: 'Noise reduction',
          display: '−32 dB',
          value: 32,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'battery',
          label: 'Battery',
          display: '45 h',
          value: 45,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '240 g',
          value: 240,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'latency',
          label: 'Latency',
          display: '150 ms',
          value: 150,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(key: 'codec', label: 'Hi-res codec', display: 'AAC'),
        ProductSpec(
          key: 'warranty',
          label: 'Warranty',
          display: '1 year',
          value: 1,
          polarity: SpecPolarity.higherIsBetter,
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "noise-canceling for study"',
          points: 30,
        ),
        FitFactor(
          title: 'Spec match',
          detail: '−32 dB ANC is within 3 dB of premium models',
          points: 27,
        ),
        FitFactor(
          title: 'Battery life',
          detail: '45 h — best in its class',
          points: 22,
        ),
        FitFactor(
          title: 'Fits budget',
          detail: '₹1,499 leaves ₹501 under your audio target',
          points: 15,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: '150 ms latency is noticeable for video calls',
          points: -8,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 22, average: 1649, current: 1499),
    ),
    Product(
      id: 'sling_field',
      brand: 'Fieldnote',
      title: 'Minimal EDC Sling 6L',
      category: 'Bags',
      price: 1249,
      averagePrice30d: 1469,
      fitScore: 90,
      fitTagline: '15% below 30-day average • 420 g',
      icon: Icons.shopping_bag_outlined,
      palette: const [Color(0xFF059669), Color(0xFF0EA5E9)],
      rating: 4.7,
      reviewCount: 1422,
      storeDistanceKm: 1.1,
      intentTags: const {
        'edc',
        'minimalist',
        'sling',
        'bag',
        'backpack',
        'commute',
      },
      specs: const [
        ProductSpec(
          key: 'capacity',
          label: 'Capacity',
          display: '6 L',
          value: 6,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '420 g',
          value: 0.42,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'water',
          label: 'Water resistance',
          display: 'IPX4',
          value: 4,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'warranty',
          label: 'Warranty',
          display: 'Lifetime',
          value: 99,
          polarity: SpecPolarity.higherIsBetter,
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "minimalist EDC"',
          points: 30,
        ),
        FitFactor(
          title: 'Spec match',
          detail: 'Organised pockets for phone, keys, wallet',
          points: 30,
        ),
        FitFactor(
          title: 'Price memory',
          detail: '15% below its 30-day average',
          points: 22,
        ),
        FitFactor(
          title: 'Durability',
          detail: 'Lifetime warranty, 4.7★',
          points: 12,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: 'No laptop sleeve',
          points: -4,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 31, average: 1469, current: 1249),
    ),
    Product(
      id: 'lamp_halo',
      brand: 'Lumen & Co',
      title: 'Halo Eye-Care Desk Lamp',
      category: 'Study',
      price: 899,
      averagePrice30d: 949,
      fitScore: 84,
      fitTagline: 'Flicker-free • Warm mode for late study',
      icon: Icons.light_rounded,
      palette: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
      rating: 4.4,
      reviewCount: 2780,
      storeDistanceKm: 0.9,
      intentTags: const {'study', 'desk', 'lamp', 'light', 'college', 'setup'},
      specs: const [
        ProductSpec(
          key: 'brightness',
          label: 'Brightness',
          display: '800 lm',
          value: 800,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(key: 'temp', label: 'Colour temp', display: '2700–6500 K'),
        ProductSpec(
          key: 'power',
          label: 'Power draw',
          display: '10 W',
          value: 10,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'warranty',
          label: 'Warranty',
          display: '1 year',
          value: 1,
          polarity: SpecPolarity.higherIsBetter,
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "college setup"',
          points: 30,
        ),
        FitFactor(
          title: 'Eye care',
          detail: 'Flicker-free, certified low blue light',
          points: 28,
        ),
        FitFactor(title: 'Fits budget', detail: 'Under ₹1,000', points: 18),
        FitFactor(
          title: 'Spec match',
          detail: 'Adjustable warmth for late study',
          points: 12,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: 'Wired only — needs a wall socket',
          points: -4,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 41, average: 949, current: 899),
    ),
    Product(
      id: 'org_kova',
      brand: 'Kova',
      title: 'Desk Cable Organiser Kit',
      category: 'Study',
      price: 599,
      averagePrice30d: 649,
      fitScore: 74,
      fitTagline: 'Tidy setup • Nice-to-have, not essential',
      icon: Icons.cable_rounded,
      palette: const [Color(0xFF64748B), Color(0xFF6366F1)],
      rating: 4.1,
      reviewCount: 611,
      intentTags: const {'desk', 'setup', 'minimalist', 'college'},
      specs: const [
        ProductSpec(
          key: 'pieces',
          label: 'Pieces',
          display: '42',
          value: 42,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'material',
          label: 'Material',
          display: 'Silicone + velcro',
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "desk setup"',
          points: 30,
        ),
        FitFactor(title: 'Fits budget', detail: 'Under ₹600', points: 20),
        FitFactor(
          title: 'Spec match',
          detail: '42 pieces cover a full desk',
          points: 18,
        ),
        FitFactor(
          title: 'Reviews',
          detail: '4.1★ across 611 reviews',
          points: 12,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: 'Low necessity — a common impulse add-on',
          points: -6,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 51, average: 649, current: 599),
    ),
    Product(
      id: 'kb_loom',
      brand: 'Loom',
      title: 'Loom 75 Quiet Mechanical Keyboard',
      category: 'Study',
      price: 2799,
      averagePrice30d: 2999,
      fitScore: 79,
      fitTagline: 'Silent switches • Over your ₹2,500 target',
      icon: Icons.keyboard_rounded,
      palette: const [Color(0xFF334155), Color(0xFF8B5CF6)],
      rating: 4.5,
      reviewCount: 1890,
      intentTags: const {'desk', 'setup', 'study', 'keyboard', 'college'},
      specs: const [
        ProductSpec(
          key: 'noise',
          label: 'Typing noise',
          display: '38 dB',
          value: 38,
          polarity: SpecPolarity.lowerIsBetter,
        ),
        ProductSpec(
          key: 'battery',
          label: 'Battery',
          display: '200 h',
          value: 200,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '780 g',
          value: 780,
          polarity: SpecPolarity.lowerIsBetter,
        ),
      ],
      fitFactors: const [
        FitFactor(
          title: 'Intent relevance',
          detail: 'Matches "study setup"',
          points: 30,
        ),
        FitFactor(
          title: 'Quiet typing',
          detail: 'Silent switches suit shared rooms',
          points: 26,
        ),
        FitFactor(title: 'Battery life', detail: '200 h wireless', points: 15),
        FitFactor(
          title: 'Durability',
          detail: '4.5★ across 1,890 reviews',
          points: 14,
        ),
        FitFactor(
          title: 'Trade-off',
          detail: '₹299 over your ₹2,500 target',
          points: -6,
          kind: FitFactorKind.tradeoff,
        ),
      ],
      priceHistory: _history(seed: 61, average: 2999, current: 2799),
    ),
  ];

  static final Map<String, Product> _byId = {for (final p in products) p.id: p};

  static Product byId(String id) {
    final product = _byId[id];
    if (product == null) throw ArgumentError.value(id, 'id', 'Unknown product');
    return product;
  }

  /// Products ranked by fit, best first.
  static List<Product> get rankedByFit =>
      [...products]..sort((a, b) => b.fitScore.compareTo(a.fitScore));

  /// The strongest price-memory signal in the catalogue.
  static Product get priceMemoryPick => products.reduce(
    (a, b) => a.discountVsAverage >= b.discountVsAverage ? a : b,
  );

  /// Pre-curated head-to-head comparisons.
  static const List<ComparePair> comparePairs = [
    ComparePair(
      label: 'Study headphones',
      leftId: 'hp_q30',
      rightId: 'hp_flow',
      priorityKeys: ['price', 'weight', 'battery'],
    ),
    ComparePair(
      label: 'College backpacks',
      leftId: 'bp_atlas',
      rightId: 'bp_metro',
      priorityKeys: ['price', 'weight', 'capacity'],
    ),
  ];

  /// Deterministically synthesises a 30-day price series whose mean equals
  /// [average] and whose final point equals [current].
  static List<double> _history({
    required int seed,
    required double average,
    required double current,
  }) {
    const days = 30;
    final rnd = math.Random(seed);
    final raw = List<double>.generate(days - 1, (i) {
      final wave = math.sin(i / 4.5 + seed) * average * 0.035;
      final noise = (rnd.nextDouble() - 0.5) * average * 0.03;
      return average + wave + noise;
    });
    final sum = raw.fold<double>(0, (a, b) => a + b);
    final shift = (average * days - current - sum) / (days - 1);
    return [for (final v in raw) v + shift, current];
  }
}

/// Two products pitted against each other in the compare matrix.
@immutable
class ComparePair {
  const ComparePair({
    required this.label,
    required this.leftId,
    required this.rightId,
    required this.priorityKeys,
  });

  final String label;
  final String leftId;
  final String rightId;

  /// Spec keys the user can elevate as priorities (`price` is virtual).
  final List<String> priorityKeys;
}
