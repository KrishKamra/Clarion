import 'package:flutter/painting.dart';

/// Clarion colour tokens — "Obsidian Titanium & Botanical Emerald".
///
/// A matte, near-neutral black canvas (no blue cast) with surfaces that read
/// as stacked sheets of vellum. Colour is spent sparingly: each accent carries
/// one meaning, so it can direct attention without decoration.
abstract final class AppColors {
  // ── Canvas & surfaces ─────────────────────────────────────────────────────
  /// Base Void: the app canvas — pure obsidian slate, no blue cast.
  static const Color canvas = Color(0xFF07080B);

  /// Card tier 1: matte content surfaces.
  static const Color surface = Color(0xFF0E1017);

  /// Card tier 2: highlighted or floating surfaces, sheets, snackbars.
  static const Color surfaceHigh = Color(0xFF141824);

  /// The 0.5px edge stroke on tier-2 surfaces: white at 8 %.
  static const Color edge = Color(0x14FFFFFF);

  /// Frosted vellum fill: white at 3 %.
  static const Color vellum = Color(0x08FFFFFF);

  /// Vellum under a finger or when selected: white at 5 %.
  static const Color vellumActive = Color(0x0DFFFFFF);

  /// Directional rim highlight on the top edge: white at 9 %.
  static const Color rim = Color(0x17FFFFFF);

  /// Brighter rim for floating chrome and focus: white at 12 %.
  static const Color rimBright = Color(0x1FFFFFFF);

  /// Dividers and inactive tracks: white at 6 %.
  static const Color hairline = Color(0x0FFFFFFF);

  // ── Accents (one meaning each) ────────────────────────────────────────────
  /// Iris: primary actions, focus, the active tab.
  static const Color iris = Color(0xFF4F46E5);
  static const Color irisGlow = Color(0xFF6366F1);

  /// Botanical emerald: optimal fit, within budget, a criterion won.
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldGlow = Color(0xFF34D399);

  /// Burnished amber: trade-offs, constraint caution, approaching the ceiling.
  static const Color amber = Color(0xFFF59E0B);

  /// Muted rose: anti-impulse friction — cooling off, over the ceiling.
  static const Color rose = Color(0xFFF43F5E);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Pure Titanium: headings and key metrics.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Slate Silver: explanations and specs.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Muted Slate: micro labels and inactive states.
  static const Color textTertiary = Color(0xFF475569);

  /// Text placed on a solid accent fill.
  static const Color onAccent = Color(0xFFFFFFFF);

  /// Semantic colour for a 0–100 personal fit score.
  static Color forFit(num score) {
    if (score >= 85) return emeraldGlow;
    if (score >= 70) return irisGlow;
    return amber;
  }

  /// Semantic colour for budget utilisation (1.0 = at the ceiling).
  static Color forBudgetRatio(double ratio) {
    if (ratio > 1.0) return rose;
    if (ratio >= 0.85) return amber;
    return emeraldGlow;
  }
}
