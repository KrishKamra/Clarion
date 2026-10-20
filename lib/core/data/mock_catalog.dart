import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';

/// Seed data standing in for the decision-engine backend.
///
/// Fit factor points sum exactly to each product's fit score, so the
/// "Why This Fits You" breakdown is arithmetically honest.
abstract final class MockCatalog {
  static final List<Product> products = [
    Product(
      id: 'bp_atlas',
      brand: 'Northpeak',
      title: 'Atlas 30L Commuter Daypack',
      category: 'Bags',
      price: 2199,
      averagePrice30d: 2420,
      fitScore: 92,
      icon: Icons.backpack_outlined,
      tone: const Color(0xFF6366F1),
      rating: 4.6,
      reviewCount: 2184,
      pickup: const PickupPoint('Indiranagar', 1.8),
      alternativeId: 'bp_metro',
      alternativeParity: 89,
      intentTags: const {
        'college',
        'backpack',
        'bag',
        'edc',
        'daily',
        'laptop',
        'study',
        'setup',
        'commute',
      },
      specs: const [
        ProductSpec(
          key: 'capacity',
          label: 'Volume',
          display: '30 L',
          value: 30,
          polarity: SpecPolarity.higherIsBetter,
        ),
        ProductSpec(
          key: 'weight',
          label: 'Weight',
          display: '1.1 kg',
          value: 1.1,
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
          title: 'Intent Match',
          detail: '30L volume matches your college setup',
          points: 35,
        ),
        FitFactor(
          title: 'Budget Envelope',
          detail: '₹2,199 vs. ₹2,500 limit',
          points: 25,
        ),
        FitFactor(
          title: 'Commute Fit',
          detail: 'Padded 16" sleeve and IPX4 shell for daily transit',
          points: 28,
        ),
        FitFactor(
          title: 'Build Trust',
          detail: '4.6★ across 2,184 verified owners',
          points: 12,
        ),
        FitFactor(
          title: 'Weight Delta',
          detail: '1.1kg is slightly above your ultralight filter',
          points: -8,
        ),
      ],
      priceHistory: _history(seed: 11, average: 2420, current: 2199),
    ),
    Product(
      id: 'bp_metro',
      brand: 'Terrain',
      title: 'Metro 28L Everyday Backpack',
      category: 'Bags',
      price: 1749,
      averagePrice30d: 1820,
      fitScore: 86,
      icon: Icons.work_outline_rounded,
      tone: const Color(0xFF38BDF8),
      rating: 4.3,
      reviewCount: 964,
      pickup: const PickupPoint('Koramangala', 3.4),
      intentTags: const {
        'college',
        'backpack',
        'bag',
        'daily',
        'laptop',
        'study',
        'commute',
      },
      specs: const [
        ProductSpec(
          key: 'capacity',
          label: 'Volume',
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
          title: 'Intent Match',
          detail: '28L carries a 15.6" laptop and a day of classes',
          points: 30,
        ),
        FitFactor(
          title: 'Budget Envelope',
          detail: '₹1,749 leaves ₹751 under your ₹2,500 limit',
          points: 30,
        ),
        FitFactor(
          title: 'Ultralight',
          detail: '0.95 kg clears your ultralight filter',
          points: 22,
        ),
        FitFactor(
          title: 'Build Trust',
          detail: '4.3★ across 964 verified owners',
          points: 12,
        ),
        FitFactor(
          title: 'Warranty Delta',
          detail: '1-year cover vs. 2 years on comparable packs',
          points: -8,
        ),
      ],
      priceHistory: _history(seed: 12, average: 1820, current: 1749),
    ),
    Product(
      id: 'hp_q30',
      brand: 'Arcus Audio',
      title: 'Q30 Hybrid ANC Headphones',
      category: 'Audio',
      price: 1899,
      averagePrice30d: 2099,
      fitScore: 88,
      icon: Icons.headphones_outlined,
      tone: const Color(0xFFA78BFA),
      rating: 4.5,
      reviewCount: 5310,
      pickup: const PickupPoint('MG Road', 4.2),
      alternativeId: 'hp_flow',
      alternativeParity: 94,
      intentTags: const {
        'noise',
        'cancellation',
        'canceling',
        'cancelling',
        'anc',
        'active',
        'deep',
        'work',
        'focus',
        'study',
        'headphones',
        'audio',
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
          title: 'Intent Match',
          detail: '−35 dB hybrid ANC built for deep-work sessions',
          points: 30,
        ),
        FitFactor(
          title: 'Isolation',
          detail: 'Blocks open-office and café chatter',
          points: 30,
        ),
        FitFactor(
          title: 'Endurance',
          detail: '40 h battery covers a full work week',
          points: 20,
        ),
        FitFactor(
          title: 'Budget Envelope',
          detail: '₹1,899 vs. your ₹2,000 audio ceiling',
          points: 12,
        ),
        FitFactor(
          title: 'Weight Delta',
          detail: '265 g vs. a 240 g class average',
          points: -4,
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
      icon: Icons.headset_outlined,
      tone: const Color(0xFF22D3EE),
      rating: 4.4,
      reviewCount: 3876,
      pickup: const PickupPoint('HSR Layout', 2.6),
      intentTags: const {
        'noise',
        'cancellation',
        'canceling',
        'cancelling',
        'anc',
        'active',
        'deep',
        'work',
        'focus',
        'study',
        'headphones',
        'audio',
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
          title: 'Intent Match',
          detail: 'Active noise cancellation tuned for focus',
          points: 30,
        ),
        FitFactor(
          title: 'Isolation',
          detail: '−32 dB is within 3 dB of premium models',
          points: 27,
        ),
        FitFactor(
          title: 'Endurance',
          detail: '45 h — best in its class',
          points: 22,
        ),
        FitFactor(
          title: 'Budget Envelope',
          detail: '₹1,499 leaves ₹501 under your audio ceiling',
          points: 15,
        ),
        FitFactor(
          title: 'Latency Delta',
          detail: '150 ms is noticeable on video calls',
          points: -8,
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
      icon: Icons.shopping_bag_outlined,
      tone: const Color(0xFF34D399),
      rating: 4.7,
      reviewCount: 1422,
      pickup: const PickupPoint('Indiranagar', 1.1),
      intentTags: const {
        'edc',
        'daily',
        'minimalist',
        'sling',
        'bag',
        'commute',
      },
      specs: const [
        ProductSpec(
          key: 'capacity',
          label: 'Volume',
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
          title: 'Intent Match',
          detail: 'Built around a daily-carry loadout',
          points: 30,
        ),
        FitFactor(
          title: 'Organisation',
          detail: 'Dedicated pockets for phone, keys, wallet',
          points: 30,
        ),
        FitFactor(
          title: 'Price Memory',
          detail: '15% below its 30-day average',
          points: 22,
        ),
        FitFactor(
          title: 'Build Trust',
          detail: 'Lifetime warranty · 4.7★',
          points: 12,
        ),
        FitFactor(
          title: 'Capacity Delta',
          detail: 'No laptop sleeve for college days',
          points: -4,
        ),
      ],
      priceHistory: _history(seed: 31, average: 1469, current: 1249),
    ),
    Product(
      id: 'lamp_halo',
      brand: 'Lumen & Co',
      title: 'Halo Eye-Care Desk Lamp',
      category: 'Study',
      price: 850,
      averagePrice30d: 899,
      fitScore: 84,
      icon: Icons.light_outlined,
      tone: const Color(0xFFFBBF24),
      rating: 4.4,
      reviewCount: 2780,
      pickup: const PickupPoint('Domlur', 0.9),
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
          title: 'Intent Match',
          detail: 'Completes your late-study desk setup',
          points: 30,
        ),
        FitFactor(
          title: 'Eye Care',
          detail: 'Flicker-free, certified low blue light',
          points: 28,
        ),
        FitFactor(title: 'Budget Envelope', detail: 'Under ₹1,000', points: 18),
        FitFactor(
          title: 'Spec Match',
          detail: 'Adjustable warmth from 2700 K',
          points: 12,
        ),
        FitFactor(
          title: 'Power Delta',
          detail: 'Wired only — needs a wall socket',
          points: -4,
        ),
      ],
      priceHistory: _history(seed: 41, average: 899, current: 850),
    ),
    Product(
      id: 'org_kova',
      brand: 'Kova',
      title: 'Desk Cable Organiser Kit',
      category: 'Study',
      price: 350,
      averagePrice30d: 399,
      fitScore: 74,
      icon: Icons.cable_rounded,
      tone: const Color(0xFF94A3B8),
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
          title: 'Intent Match',
          detail: 'Tidies a minimal desk setup',
          points: 30,
        ),
        FitFactor(title: 'Budget Envelope', detail: 'Under ₹400', points: 20),
        FitFactor(
          title: 'Spec Match',
          detail: '42 pieces cover a full desk',
          points: 18,
        ),
        FitFactor(
          title: 'Build Trust',
          detail: '4.1★ across 611 owners',
          points: 12,
        ),
        FitFactor(
          title: 'Necessity Delta',
          detail: 'A common impulse add-on',
          points: -6,
        ),
      ],
      priceHistory: _history(seed: 51, average: 399, current: 350),
    ),
    Product(
      id: 'kb_loom',
      brand: 'Loom',
      title: 'Loom 75 Quiet Mechanical Keyboard',
      category: 'Study',
      price: 2799,
      averagePrice30d: 2999,
      fitScore: 79,
      icon: Icons.keyboard_outlined,
      tone: const Color(0xFF818CF8),
      rating: 4.5,
      reviewCount: 1890,
      intentTags: const {'desk', 'setup', 'study', 'keyboard', 'deep', 'work'},
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
          title: 'Intent Match',
          detail: 'Fits a deep-work desk setup',
          points: 30,
        ),
        FitFactor(
          title: 'Quiet Typing',
          detail: 'Silent switches suit shared rooms',
          points: 26,
        ),
        FitFactor(title: 'Endurance', detail: '200 h wireless', points: 15),
        FitFactor(
          title: 'Build Trust',
          detail: '4.5★ across 1,890 owners',
          points: 14,
        ),
        FitFactor(
          title: 'Budget Delta',
          detail: '₹299 over your ₹2,500 ceiling',
          points: -6,
        ),
      ],
      priceHistory: _history(seed: 61, average: 2999, current: 2799),
    ),
  ];

  /// Pre-curated head-to-head comparisons.
  static const List<ComparePair> comparePairs = [
    ComparePair(
      label: 'Deep-work audio',
      leftId: 'hp_q30',
      rightId: 'hp_flow',
      priorityKeys: ['price', 'weight', 'battery'],
    ),
    ComparePair(
      label: 'College daypacks',
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

/// Two products pitted against each other in the Decision Node.
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

  bool contains(String productId) =>
      leftId == productId || rightId == productId;

  String other(String productId) => productId == leftId ? rightId : leftId;
}
