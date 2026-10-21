import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/product_model.dart';
import 'models/trade_off_item.dart';

/// Seed data standing in for the decision-engine backend.
///
/// Authored to be internally honest: trade-off weights sum exactly to each
/// fit score, price histories average exactly to the stated 30-day mean,
/// and every alternative and compare pair resolves to a real product.
abstract final class MockCatalog {
  static final List<Product> products = [
    Product(
      id: 'bp_atlas',
      brand: 'Northpeak',
      title: 'Atlas 30L Commuter Daypack',
      category: 'Bags',
      price: 2199,
      averagePrice30d: 2420,
      fitScore: 94,
      rationale: 'Within ₹2,500 target • Top-tier ergonomic review score',
      icon: Icons.backpack_outlined,
      tone: const Color(0xFF6366F1),
      rating: 4.6,
      reviewCount: 2184,
      pickup: const PickupPoint('Indiranagar', 1.8),
      alternativeId: 'bp_metro',
      alternativeParity: 89,
      intentTags: const {
        'college',
        'setup',
        'backpack',
        'bag',
        'pack',
        'daypack',
        'laptop',
        'commute',
        'durable',
        'daily',
        'edc',
        'study',
      },
      specs: [
        _higher('capacity', 'Volume', '30 L', 30),
        _lower('weight', 'Weight', '1.1 kg', 1.1),
        _higher('laptop', 'Laptop sleeve', '16"', 16),
        _higher('water', 'Water resistance', 'IPX4', 4),
        _higher('warranty', 'Warranty', '2 years', 2),
        _neutral('material', 'Shell', 'Recycled 600D PET'),
        _neutral('straps', 'Harness', 'Load-lifter, sternum strap'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: '30L volume matches your college setup',
          weight: 35,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: '₹2,199 fits within your ₹2,500 ceiling',
          weight: 25,
        ),
        TradeOffItem(
          title: 'Commute Ergonomics',
          detail: 'Load-lifters and a padded 16" sleeve for daily transit',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.6★ across 2,184 verified owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Weight Trade-off',
          detail: '1.1kg is slightly above your ultralight preference',
          weight: -8,
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
      rationale: 'Lightest in class at 0.95 kg • ₹751 under target',
      icon: Icons.work_outline_rounded,
      tone: const Color(0xFF38BDF8),
      rating: 4.3,
      reviewCount: 964,
      pickup: const PickupPoint('Koramangala', 3.4),
      intentTags: const {
        'college',
        'setup',
        'backpack',
        'bag',
        'pack',
        'laptop',
        'commute',
        'daily',
        'study',
      },
      specs: [
        _higher('capacity', 'Volume', '28 L', 28),
        _lower('weight', 'Weight', '0.95 kg', 0.95),
        _higher('laptop', 'Laptop sleeve', '15.6"', 15.6),
        _higher('water', 'Water resistance', 'IPX3', 3),
        _higher('warranty', 'Warranty', '1 year', 1),
        _neutral('material', 'Shell', 'Recycled 600D PET'),
        _neutral('straps', 'Harness', 'Sternum strap'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: '28L carries a 15.6" laptop and a day of classes',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: '₹1,749 leaves ₹751 under your ₹2,500 ceiling',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Ultralight',
          detail: '0.95 kg clears your ultralight preference',
          weight: 22,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.3★ across 964 verified owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Warranty Trade-off',
          detail: '1-year cover vs. 2 years on comparable packs',
          weight: -8,
        ),
      ],
      priceHistory: _history(seed: 12, average: 1820, current: 1749),
    ),
    Product(
      id: 'hp_pro',
      brand: 'Arcus Audio',
      title: 'Q30 Pro Hybrid ANC Headphones',
      category: 'Audio',
      price: 1899,
      averagePrice30d: 2350,
      fitScore: 88,
      rationale: '−35 dB hybrid ANC • 40h battery for full focus weeks',
      icon: Icons.headphones_outlined,
      tone: const Color(0xFFA78BFA),
      rating: 4.5,
      reviewCount: 5310,
      pickup: const PickupPoint('MG Road', 4.2),
      alternativeId: 'hp_core',
      alternativeParity: 94,
      intentTags: const {
        'anc',
        'noise',
        'cancellation',
        'cancelling',
        'focus',
        'deep',
        'work',
        'study',
        'headphones',
        'audio',
        'college',
        'setup',
      },
      specs: [
        _higher('anc', 'Noise reduction', '−35 dB', 35),
        _higher('battery', 'Battery', '40 h', 40),
        _lower('weight', 'Weight', '265 g', 265),
        _lower('latency', 'Latency', '120 ms', 120),
        _neutral('codec', 'Hi-res codec', 'LDAC'),
        _higher('warranty', 'Warranty', '1 year', 1),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: '−35 dB hybrid ANC built for deep-focus sessions',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Isolation',
          detail: 'Blocks library chatter and open-office noise',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Endurance',
          detail: '40 h battery covers a full study week',
          weight: 20,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: '₹1,899 vs. your ₹2,000 audio ceiling',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Weight Trade-off',
          detail: '265 g vs. a 240 g class average',
          weight: -4,
        ),
      ],
      priceHistory: _history(seed: 21, average: 2350, current: 1899),
    ),
    Product(
      id: 'hp_core',
      brand: 'Arcus Audio',
      title: 'Q30 Core Edition ANC Headphones',
      category: 'Audio',
      price: 1499,
      averagePrice30d: 1649,
      fitScore: 86,
      rationale: '94% spec parity with the Pro • ₹400 less',
      icon: Icons.headset_outlined,
      tone: const Color(0xFF22D3EE),
      rating: 4.4,
      reviewCount: 3876,
      pickup: const PickupPoint('HSR Layout', 2.6),
      intentTags: const {
        'anc',
        'noise',
        'cancellation',
        'cancelling',
        'focus',
        'deep',
        'work',
        'study',
        'headphones',
        'audio',
        'college',
      },
      specs: [
        _higher('anc', 'Noise reduction', '−32 dB', 32),
        _higher('battery', 'Battery', '45 h', 45),
        _lower('weight', 'Weight', '240 g', 240),
        _lower('latency', 'Latency', '150 ms', 150),
        _neutral('codec', 'Hi-res codec', 'AAC'),
        _higher('warranty', 'Warranty', '1 year', 1),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Same ANC platform as the Pro, tuned for focus',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Isolation',
          detail: '−32 dB — within 3 dB of the Pro',
          weight: 27,
        ),
        TradeOffItem(
          title: 'Endurance',
          detail: '45 h — best in its class',
          weight: 22,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: '₹1,499 leaves ₹501 under your audio ceiling',
          weight: 15,
        ),
        TradeOffItem(
          title: 'Latency Trade-off',
          detail: '150 ms is noticeable on video calls',
          weight: -8,
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
      rationale: '15% below its 30-day average • Lifetime warranty',
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
        'durable',
      },
      specs: [
        _higher('capacity', 'Volume', '6 L', 6),
        _lower('weight', 'Weight', '420 g', 0.42),
        _higher('water', 'Water resistance', 'IPX4', 4),
        _higher('warranty', 'Warranty', 'Lifetime', 99),
        _neutral('material', 'Shell', 'X-Pac VX21'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Built around a daily-carry loadout',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Organisation',
          detail: 'Dedicated pockets for phone, keys and wallet',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Price Memory',
          detail: '15% below its 30-day average',
          weight: 22,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: 'Lifetime warranty · 4.7★',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Capacity Trade-off',
          detail: 'No laptop sleeve for college days',
          weight: -4,
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
      rationale: 'Flicker-free • Warm mode for late study',
      icon: Icons.light_outlined,
      tone: const Color(0xFFFBBF24),
      rating: 4.4,
      reviewCount: 2780,
      pickup: const PickupPoint('Domlur', 0.9),
      intentTags: const {'study', 'desk', 'lamp', 'light', 'college', 'setup'},
      specs: [
        _higher('brightness', 'Brightness', '800 lm', 800),
        _neutral('temp', 'Colour temperature', '2700–6500 K'),
        _lower('power', 'Power draw', '10 W', 10),
        _higher('warranty', 'Warranty', '1 year', 1),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Completes your late-study desk setup',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Eye Care',
          detail: 'Flicker-free, certified low blue light',
          weight: 28,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Under ₹1,000',
          weight: 18,
        ),
        TradeOffItem(
          title: 'Spec Match',
          detail: 'Adjustable warmth from 2700 K',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Power Trade-off',
          detail: 'Wired only — needs a wall socket',
          weight: -4,
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
      rationale: 'Tidy setup • Nice-to-have, not essential',
      icon: Icons.cable_rounded,
      tone: const Color(0xFF94A3B8),
      rating: 4.1,
      reviewCount: 611,
      intentTags: const {'desk', 'setup', 'minimalist', 'college'},
      specs: [
        _higher('pieces', 'Pieces', '42', 42),
        _neutral('material', 'Material', 'Silicone + velcro'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Tidies a minimal desk setup',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Under ₹400',
          weight: 20,
        ),
        TradeOffItem(
          title: 'Spec Match',
          detail: '42 pieces cover a full desk',
          weight: 18,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.1★ across 611 owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Necessity Trade-off',
          detail: 'A common impulse add-on',
          weight: -6,
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
      rationale: 'Silent switches • ₹299 over your ₹2,500 target',
      icon: Icons.keyboard_outlined,
      tone: const Color(0xFF818CF8),
      rating: 4.5,
      reviewCount: 1890,
      intentTags: const {'desk', 'setup', 'study', 'keyboard', 'focus', 'work'},
      specs: [
        _lower('noise', 'Typing noise', '38 dB', 38),
        _higher('battery', 'Battery', '200 h', 200),
        _lower('weight', 'Weight', '780 g', 780),
        _neutral('switches', 'Switches', 'Silent linear'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Fits a deep-focus desk setup',
          weight: 30,
        ),
        TradeOffItem(
          title: 'Quiet Typing',
          detail: 'Silent switches suit shared rooms',
          weight: 26,
        ),
        TradeOffItem(title: 'Endurance', detail: '200 h wireless', weight: 15),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.5★ across 1,890 owners',
          weight: 14,
        ),
        TradeOffItem(
          title: 'Budget Trade-off',
          detail: '₹299 over your ₹2,500 ceiling',
          weight: -6,
        ),
      ],
      priceHistory: _history(seed: 61, average: 2999, current: 2799),
    ),
  ];

  /// Pre-curated head-to-head comparisons.
  static const List<ComparePair> comparePairs = [
    ComparePair(
      label: 'Focus headphones',
      leftId: 'hp_pro',
      rightId: 'hp_core',
      priorityKeys: ['price', 'weight', 'battery'],
    ),
    ComparePair(
      label: 'College daypacks',
      leftId: 'bp_atlas',
      rightId: 'bp_metro',
      priorityKeys: ['price', 'weight', 'capacity'],
    ),
  ];

  static ProductSpec _higher(String k, String l, String d, double v) =>
      ProductSpec(
        key: k,
        label: l,
        display: d,
        value: v,
        polarity: SpecPolarity.higherIsBetter,
      );

  static ProductSpec _lower(String k, String l, String d, double v) =>
      ProductSpec(
        key: k,
        label: l,
        display: d,
        value: v,
        polarity: SpecPolarity.lowerIsBetter,
      );

  static ProductSpec _neutral(String k, String l, String d) =>
      ProductSpec(key: k, label: l, display: d);

  /// Deterministically synthesises 30 dated closing prices whose mean
  /// equals [average] and whose final point (today) equals [current].
  static List<PricePoint> _history({
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
    final prices = [for (final v in raw) v + shift, current];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 0; i < days; i++)
        PricePoint(today.subtract(Duration(days: days - 1 - i)), prices[i]),
    ];
  }
}

/// Two products pitted against each other in the Compare Matrix.
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
