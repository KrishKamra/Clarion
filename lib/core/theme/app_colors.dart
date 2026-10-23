import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

/// Clarion colour tokens — "Obsidian Titanium & Botanical Emerald", with a
/// "Porcelain" light counterpart.
///
/// Dark is a matte, near-neutral black canvas (no blue cast) with surfaces
/// that read as stacked sheets of vellum; light is soft porcelain with white
/// cards. Colour is spent sparingly: each accent carries one meaning, so it
/// can direct attention without decoration. Light-mode accents are deepened
/// so text set in them clears WCAG AA on white.
///
/// Tokens resolve against [brightness], which `ClarionApp` sets before the
/// tree builds — call sites read `AppColors.x` in either mode.
abstract final class AppColors {
  static Brightness brightness = Brightness.dark;
  static bool get isDark => brightness == Brightness.dark;

  static Color _pick(int dark, int light) => Color(isDark ? dark : light);

  // ── Canvas & surfaces ─────────────────────────────────────────────────────
  /// Base Void: the app canvas.
  static Color get canvas => _pick(0xFF07080B, 0xFFF3F4F6);

  /// Card tier 1: matte content surfaces.
  static Color get surface => _pick(0xFF0E1017, 0xFFFFFFFF);

  /// Card tier 2: highlighted or floating surfaces, sheets, snackbars.
  static Color get surfaceHigh => _pick(0xFF141824, 0xFFFFFFFF);

  /// The 0.5px edge stroke on tier-2 surfaces.
  static Color get edge => _pick(0x14FFFFFF, 0x1F0F172A);

  /// Frosted vellum fill for inputs and quiet panels.
  static Color get vellum => _pick(0x08FFFFFF, 0xB3FFFFFF);

  /// Vellum under a finger or when selected.
  static Color get vellumActive => _pick(0x0DFFFFFF, 0xFFFFFFFF);

  /// Directional rim highlight on the top edge.
  static Color get rim => _pick(0x17FFFFFF, 0x140F172A);

  /// Brighter rim for floating chrome and focus.
  static Color get rimBright => _pick(0x1FFFFFFF, 0x1F0F172A);

  /// Dividers and inactive tracks.
  static Color get hairline => _pick(0x0FFFFFFF, 0x170F172A);

  // ── Accents (one meaning each) ────────────────────────────────────────────
  /// Iris: primary actions, focus, the active tab.
  static Color get iris => const Color(0xFF4F46E5);
  static Color get irisGlow => _pick(0xFF6366F1, 0xFF4F46E5);

  /// Botanical emerald: optimal fit, within budget, a criterion won.
  static Color get emerald => _pick(0xFF10B981, 0xFF059669);
  static Color get emeraldGlow => _pick(0xFF34D399, 0xFF047857);

  /// Burnished amber: trade-offs, constraint caution, approaching the ceiling.
  static Color get amber => _pick(0xFFF59E0B, 0xFFB45309);

  /// Muted rose: anti-impulse friction — cooling off, over the ceiling.
  static Color get rose => _pick(0xFFF43F5E, 0xFFE11D48);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Headings and key metrics.
  static Color get textPrimary => _pick(0xFFF8FAFC, 0xFF0B0F19);

  /// Explanations and specs.
  static Color get textSecondary => _pick(0xFFA3B0C2, 0xFF475569);

  /// Micro labels and inactive states — still ≥ 4.5:1 on the canvas.
  static Color get textTertiary => _pick(0xFF7D8899, 0xFF5B6678);

  /// Text placed on a solid accent fill.
  static Color get onAccent => const Color(0xFFFFFFFF);

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
