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
      averagePrice30d: 2290,
      fitScore: 94,
      rationale: 'Within ₹2,500 target • Top-tier ergonomic review score',
      icon: Icons.backpack_outlined,
      tone: const Color(0xFF6366F1),
      rating: 4.6,
      reviewCount: 2184,
      pickup: const PickupPoint('Vile Parle', 1.8),
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
      priceHistory: _history(seed: 11, average: 2290, current: 2199),
    ),
    Product(
      id: 'bp_metro',
      brand: 'Terrain',
      title: 'Metro 28L Everyday Backpack',
      category: 'Bags',
      price: 1749,
      averagePrice30d: 1720,
      fitScore: 86,
      rationale: 'Lightest in class at 0.95 kg • ₹751 under target',
      icon: Icons.work_outline_rounded,
      tone: const Color(0xFF38BDF8),
      rating: 4.3,
      reviewCount: 964,
      pickup: const PickupPoint('Andheri West', 3.4),
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
      priceHistory: _history(seed: 12, average: 1720, current: 1749),
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
      pickup: const PickupPoint('Dadar', 4.2),
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
      averagePrice30d: 1560,
      fitScore: 86,
      rationale: '94% spec parity with the Pro • ₹400 less',
      icon: Icons.headset_outlined,
      tone: const Color(0xFF22D3EE),
      rating: 4.4,
      reviewCount: 3876,
      pickup: const PickupPoint('Bandra West', 2.6),
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
      priceHistory: _history(seed: 22, average: 1560, current: 1499),
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
      pickup: const PickupPoint('Vile Parle East', 1.1),
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
      averagePrice30d: 829,
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
      priceHistory: _history(seed: 41, average: 829, current: 850),
    ),
    Product(
      id: 'org_kova',
      brand: 'Kova',
      title: 'Desk Cable Organiser Kit',
      category: 'Study',
      price: 350,
      averagePrice30d: 340,
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
      priceHistory: _history(seed: 51, average: 340, current: 350),
    ),
    Product(
      id: 'kb_loom',
      brand: 'Loom',
      title: 'Loom 75 Quiet Mechanical Keyboard',
      category: 'Study',
      price: 2799,
      averagePrice30d: 2690,
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
      priceHistory: _history(seed: 61, average: 2690, current: 2799),
    ),
    Product(
      id: 'mouse_glide',
      brand: 'Glidepoint',
      title: 'Glide Silent Wireless Mouse',
      category: 'Study',
      price: 1099,
      averagePrice30d: 1090,
      fitScore: 80,
      rationale: 'Silent clicks • 18-month battery on one AA',
      icon: Icons.mouse_outlined,
      tone: const Color(0xFF60A5FA),
      rating: 4.3,
      reviewCount: 2410,
      pickup: const PickupPoint('Andheri West', 3.4),
      intentTags: const {
        'mouse',
        'wireless',
        'silent',
        'desk',
        'setup',
        'work',
        'study',
        'college',
        'laptop',
      },
      specs: [
        _lower('noise', 'Click noise', '22 dB', 22),
        _higher('battery', 'Battery', '18 months', 18),
        _lower('weight', 'Weight', '82 g', 82),
        _higher('warranty', 'Warranty', '1 year', 1),
        _neutral('connect', 'Connection', 'Bluetooth + 2.4 GHz'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Quiet daily driver for a desk setup',
          weight: 28,
        ),
        TradeOffItem(
          title: 'Quiet Clicks',
          detail: 'Silent switches suit libraries and hostels',
          weight: 24,
        ),
        TradeOffItem(
          title: 'Endurance',
          detail: '18 months on a single AA',
          weight: 14,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.3★ across 2,410 owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Ergonomics Trade-off',
          detail: 'Standard shape, not a vertical grip',
          weight: 2,
        ),
      ],
      priceHistory: _history(seed: 71, average: 1090, current: 1099),
    ),
    Product(
      id: 'mouse_ergo',
      brand: 'Vertex',
      title: 'Vertex Ergonomic Vertical Mouse',
      category: 'Study',
      price: 1899,
      averagePrice30d: 1840,
      fitScore: 70,
      rationale: 'Vertical grip eases wrist strain • Long study sessions',
      icon: Icons.mouse_outlined,
      tone: const Color(0xFFF472B6),
      rating: 4.4,
      reviewCount: 1137,
      pickup: const PickupPoint('Dadar', 4.2),
      intentTags: const {
        'mouse',
        'wireless',
        'ergonomic',
        'vertical',
        'desk',
        'setup',
        'work',
        'study',
        'college',
      },
      specs: [
        _lower('noise', 'Click noise', '35 dB', 35),
        _higher('battery', 'Battery', '6 months', 6),
        _lower('weight', 'Weight', '135 g', 135),
        _higher('warranty', 'Warranty', '2 years', 2),
        _neutral('connect', 'Connection', 'Bluetooth + 2.4 GHz'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Built for long hours at a desk',
          weight: 26,
        ),
        TradeOffItem(
          title: 'Wrist Comfort',
          detail: '57° vertical angle reduces strain',
          weight: 26,
        ),
        TradeOffItem(title: 'Warranty', detail: '2-year cover', weight: 10),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.4★ across 1,137 owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Price Trade-off',
          detail: '₹800 more than a standard mouse',
          weight: -8,
        ),
        TradeOffItem(
          title: 'Learning Curve',
          detail: 'Takes a week to get used to',
          weight: -4,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Sits comfortably in a ₹5,000 month',
          weight: 8,
        ),
      ],
      priceHistory: _history(seed: 72, average: 1840, current: 1899),
    ),
    Product(
      id: 'bottle_thermo',
      brand: 'Frostline',
      title: 'Thermo 750 Insulated Bottle',
      category: 'Everyday',
      price: 899,
      averagePrice30d: 950,
      fitScore: 74,
      rationale: 'Cold 24 h, hot 12 h • Leak-proof lid',
      icon: Icons.local_drink_outlined,
      tone: const Color(0xFF2DD4BF),
      rating: 4.5,
      reviewCount: 3920,
      pickup: const PickupPoint('Vile Parle', 1.8),
      intentTags: const {
        'bottle',
        'hydration',
        'daily',
        'edc',
        'college',
        'commute',
        'durable',
        'travel',
        'gym',
      },
      specs: [
        _higher('capacity', 'Volume', '750 ml', 0.75),
        _lower('weight', 'Weight', '390 g', 390),
        _higher('cold', 'Keeps cold', '24 h', 24),
        _higher('warranty', 'Warranty', 'Lifetime', 99),
        _neutral('material', 'Body', '18/8 stainless steel'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'A daily carry that goes everywhere',
          weight: 26,
        ),
        TradeOffItem(
          title: 'Insulation',
          detail: '24 h cold, 12 h hot',
          weight: 26,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.5★ across 3,920 owners',
          weight: 14,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Under ₹1,000',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Weight Trade-off',
          detail: 'Heavier than a plastic bottle',
          weight: -4,
        ),
      ],
      priceHistory: _history(seed: 73, average: 950, current: 899),
    ),
    Product(
      id: 'notebook_dot',
      brand: 'Paperlane',
      title: 'Dotgrid A5 Notebook, Pack of 3',
      category: 'Study',
      price: 449,
      averagePrice30d: 430,
      fitScore: 66,
      rationale: 'Dot-grid pages • Lies flat for notes',
      icon: Icons.menu_book_outlined,
      tone: const Color(0xFFFB923C),
      rating: 4.2,
      reviewCount: 1560,
      intentTags: const {
        'notebook',
        'notes',
        'study',
        'college',
        'writing',
        'stationery',
        'setup',
        'desk',
      },
      specs: [
        _higher('pages', 'Pages', '3 × 160', 480),
        _neutral('paper', 'Paper', '100 gsm, fountain-pen safe'),
        _neutral('binding', 'Binding', 'Lay-flat thread-bound'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Notes for every class, in one pack',
          weight: 24,
        ),
        TradeOffItem(
          title: 'Paper Quality',
          detail: '100 gsm — no ghosting from gel pens',
          weight: 20,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Under ₹500',
          weight: 16,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.2★ across 1,560 owners',
          weight: 10,
        ),
        TradeOffItem(
          title: 'Necessity Trade-off',
          detail: 'A stack you may already own',
          weight: -4,
        ),
      ],
      priceHistory: _history(seed: 74, average: 430, current: 449),
    ),
    Product(
      id: 'pb_volt',
      brand: 'Voltaic',
      title: 'Volt 20K Fast-Charge Power Bank',
      category: 'Power',
      price: 1899,
      averagePrice30d: 1999,
      fitScore: 83,
      rationale: '20,000 mAh • 45 W USB-C PD for laptops',
      icon: Icons.battery_charging_full_rounded,
      tone: const Color(0xFFFACC15),
      rating: 4.4,
      reviewCount: 4725,
      pickup: const PickupPoint('Bandra West', 2.6),
      intentTags: const {
        'power',
        'bank',
        'powerbank',
        'charging',
        'travel',
        'commute',
        'college',
        'laptop',
        'daily',
        'edc',
      },
      specs: [
        _higher('capacity', 'Capacity', '20,000 mAh', 20000),
        _higher('output', 'Output', '45 W', 45),
        _lower('weight', 'Weight', '440 g', 440),
        _higher('warranty', 'Warranty', '1 year', 1),
        _neutral('ports', 'Ports', '2× USB-C, 1× USB-A'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Keeps phone and laptop alive on long commutes',
          weight: 28,
        ),
        TradeOffItem(
          title: 'Charging Power',
          detail: '45 W PD tops up a laptop',
          weight: 26,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.4★ across 4,725 owners',
          weight: 14,
        ),
        TradeOffItem(
          title: 'Price Memory',
          detail: '5% below its 30-day average',
          weight: 8,
        ),
        TradeOffItem(
          title: 'Weight Trade-off',
          detail: '440 g adds noticeable bulk',
          weight: -6,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Fits the month with room to spare',
          weight: 13,
        ),
      ],
      priceHistory: _history(seed: 75, average: 1999, current: 1899),
    ),
    Product(
      id: 'stand_lift',
      brand: 'Elevate',
      title: 'Elevate Aluminium Laptop Stand',
      category: 'Study',
      price: 1399,
      averagePrice30d: 1360,
      fitScore: 73,
      rationale: 'Adjustable height • Folds flat for the bag',
      icon: Icons.laptop_mac_outlined,
      tone: const Color(0xFFA3E635),
      rating: 4.5,
      reviewCount: 2088,
      pickup: const PickupPoint('Vile Parle East', 1.1),
      intentTags: const {
        'laptop',
        'stand',
        'ergonomic',
        'desk',
        'setup',
        'work',
        'study',
        'college',
        'posture',
      },
      specs: [
        _higher('height', 'Height range', '6 positions', 6),
        _lower('weight', 'Weight', '560 g', 560),
        _higher('load', 'Max load', '10 kg', 10),
        _higher('warranty', 'Warranty', '1 year', 1),
        _neutral('material', 'Body', 'Aluminium alloy'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Raises the screen for a healthier desk setup',
          weight: 26,
        ),
        TradeOffItem(
          title: 'Posture',
          detail: 'Eye-level screen cuts neck strain',
          weight: 24,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.5★ across 2,088 owners',
          weight: 14,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Under ₹1,500',
          weight: 10,
        ),
        TradeOffItem(
          title: 'Portability Trade-off',
          detail: '560 g is heavy for a daily carry',
          weight: -4,
        ),
        TradeOffItem(
          title: 'Price Trade-off',
          detail: 'Slightly above its usual price',
          weight: 3,
        ),
      ],
      priceHistory: _history(seed: 76, average: 1360, current: 1399),
    ),
    Product(
      id: 'earb_pulse',
      brand: 'Pulsewave',
      title: 'Pulse 2 Wireless Earbuds',
      category: 'Audio',
      price: 2499,
      averagePrice30d: 2650,
      fitScore: 79,
      rationale: '36 h with the case • IPX5 for the gym',
      icon: Icons.earbuds_outlined,
      tone: const Color(0xFFC084FC),
      rating: 4.2,
      reviewCount: 6240,
      pickup: const PickupPoint('Dadar', 4.2),
      intentTags: const {
        'earbuds',
        'wireless',
        'audio',
        'music',
        'commute',
        'gym',
        'calls',
        'daily',
      },
      specs: [
        _higher('battery', 'Battery', '36 h', 36),
        _lower('weight', 'Weight', '48 g', 48),
        _lower('latency', 'Latency', '60 ms', 60),
        _higher('water', 'Water resistance', 'IPX5', 5),
        _higher('warranty', 'Warranty', '1 year', 1),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Music and calls on the move',
          weight: 24,
        ),
        TradeOffItem(
          title: 'Endurance',
          detail: '36 h including the charging case',
          weight: 22,
        ),
        TradeOffItem(
          title: 'Low Latency',
          detail: '60 ms gaming mode keeps video in sync',
          weight: 14,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.2★ across 6,240 owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Budget Trade-off',
          detail: 'Takes half of a ₹5,000 month',
          weight: -6,
        ),
        TradeOffItem(
          title: 'Price Memory',
          detail: '6% below its 30-day average',
          weight: 13,
        ),
      ],
      priceHistory: _history(seed: 77, average: 2650, current: 2499),
    ),
    Product(
      id: 'cam_clear',
      brand: 'Clearview',
      title: 'Clearview 1080p Webcam',
      category: 'Study',
      price: 1799,
      averagePrice30d: 1850,
      fitScore: 75,
      rationale: '1080p at 60 fps • Privacy shutter',
      icon: Icons.videocam_outlined,
      tone: const Color(0xFF38BDF8),
      rating: 4.1,
      reviewCount: 903,
      intentTags: const {
        'webcam',
        'camera',
        'video',
        'calls',
        'work',
        'setup',
        'desk',
        'college',
        'online',
      },
      specs: [
        _higher('resolution', 'Resolution', '1080p / 60 fps', 1080),
        _higher('fov', 'Field of view', '90°', 90),
        _lower('weight', 'Weight', '150 g', 150),
        _higher('warranty', 'Warranty', '1 year', 1),
        _neutral('mic', 'Microphone', 'Dual noise-cancelling'),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Clear video for online classes and interviews',
          weight: 24,
        ),
        TradeOffItem(
          title: 'Image Quality',
          detail: 'Sharp 1080p even in a dim hostel room',
          weight: 22,
        ),
        TradeOffItem(title: 'Privacy', detail: 'Physical shutter', weight: 10),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.1★ across 903 owners',
          weight: 10,
        ),
        TradeOffItem(
          title: 'Few Reviews',
          detail: 'Fewer than 1,000 owners so far',
          weight: -4,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Fits comfortably',
          weight: 13,
        ),
      ],
      priceHistory: _history(seed: 78, average: 1850, current: 1799),
    ),
    Product(
      id: 'cushion_lumbar',
      brand: 'Restwell',
      title: 'Restwell Lumbar Support Cushion',
      category: 'Study',
      price: 1299,
      averagePrice30d: 1280,
      fitScore: 72,
      rationale: 'Memory foam • Fits any study chair',
      icon: Icons.event_seat_outlined,
      tone: const Color(0xFFFDA4AF),
      rating: 4.3,
      reviewCount: 1675,
      pickup: const PickupPoint('Andheri West', 3.4),
      intentTags: const {
        'cushion',
        'lumbar',
        'back',
        'ergonomic',
        'chair',
        'posture',
        'desk',
        'study',
        'setup',
        'college',
      },
      specs: [
        _neutral('foam', 'Foam', 'High-density memory foam'),
        _higher('warranty', 'Warranty', '1 year', 1),
        _lower('weight', 'Weight', '620 g', 620),
      ],
      tradeOffs: const [
        TradeOffItem(
          title: 'Intent Alignment',
          detail: 'Makes long study hours more comfortable',
          weight: 24,
        ),
        TradeOffItem(
          title: 'Back Support',
          detail: 'Contoured lumbar curve',
          weight: 22,
        ),
        TradeOffItem(
          title: 'Build Trust',
          detail: '4.3★ across 1,675 owners',
          weight: 12,
        ),
        TradeOffItem(
          title: 'Budget Envelope',
          detail: 'Fits comfortably',
          weight: 10,
        ),
        TradeOffItem(
          title: 'Necessity Trade-off',
          detail: 'Nice to have, not essential',
          weight: -4,
        ),
        TradeOffItem(
          title: 'Price Trade-off',
          detail: 'Slightly above its usual price',
          weight: 8,
        ),
      ],
      priceHistory: _history(seed: 79, average: 1280, current: 1299),
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
      label: 'Desk mice',
      leftId: 'mouse_glide',
      rightId: 'mouse_ergo',
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
  ///
  /// The path is a smooth wander that ends exactly at [current], plus a gentle
  /// lead-in that carries the mean to [average]. So a product trading below
  /// its average has been drifting down, one above has been drifting up, and
  /// one near its average hovers; today is not always the 30-day low.
  static List<PricePoint> _history({
    required int seed,
    required double average,
    required double current,
  }) {
    const days = 30;
    const last = days - 1;
    final rnd = math.Random(seed);
    final phaseA = rnd.nextDouble() * math.pi * 2;
    final phaseB = rnd.nextDouble() * math.pi * 2;
    final periodA = 6.0 + rnd.nextDouble() * 4;
    final periodB = 2.5 + rnd.nextDouble() * 2;

    double wave(int i) =>
        math.sin(i / periodA * math.pi * 2 / 2 + phaseA) * 0.6 +
        math.sin(i / periodB * math.pi * 2 / 2 + phaseB) * 0.4;

    // Wander that is exactly zero today.
    final amp = average * 0.045;
    final w = [for (var i = 0; i < days; i++) (wave(i) - wave(last)) * amp];

    // Lead-in weight: 1 at the start, easing to 0 today.
    final h = [
      for (var i = 0; i < days; i++) math.pow(1 - i / last, 1.5).toDouble(),
    ];

    final target =
        (average - current) * days - w.fold<double>(0, (a, b) => a + b);
    final scale = target / h.fold<double>(0, (a, b) => a + b);
    final prices = [
      for (var i = 0; i < days; i++) current + w[i] + scale * h[i],
    ];
    prices[last] = current;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 0; i < days; i++)
        PricePoint(today.subtract(Duration(days: last - i)), prices[i]),
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
