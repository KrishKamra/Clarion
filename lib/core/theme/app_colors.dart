import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

/// Clarion colour tokens — "Inkwell".
///
/// Three ingredients and three meanings:
///  * **Ink** — the canvas and the type: navy-black like fountain-pen ink in
///    light, a deep ink canvas in dark. Most of the screen is this.
///  * **Plum** — the one colour for acting: buttons, links, focus, the
///    active tab. The magenta of a real lens coating.
///  * **Champagne** — the one metal: brass paled until it can't be mistaken
///    for caution, for the lens coating on rims, the ring and the splash.
///  * **Sea, ochre, brick** — good, caution, over. Chosen together so they
///    stay apart under red-green and blue-yellow colour blindness, and kept
///    off every stock Tailwind shade.
///
/// Tokens resolve against [brightness], which `ClarionApp` sets before the
/// tree builds — call sites read `AppColors.x` in either mode.
abstract final class AppColors {
  static Brightness brightness = Brightness.dark;
  static bool get isDark => brightness == Brightness.dark;

  static Color _pick(int dark, int light) => Color(isDark ? dark : light);

  // ── Canvas & surfaces (ink) ───────────────────────────────────────────────
  /// Base: the app canvas.
  static Color get canvas => _pick(0xFF0A0C14, 0xFFEEF0F5);

  /// Card tier 1: matte content surfaces.
  static Color get surface => _pick(0xFF11141F, 0xFFFFFFFF);

  /// Card tier 2: highlighted or floating surfaces, sheets, snackbars.
  static Color get surfaceHigh => _pick(0xFF181C2A, 0xFFFFFFFF);

  /// The 0.5px edge stroke on tier-2 surfaces.
  static Color get edge => _pick(0x14FFFFFF, 0x1F151B33);

  /// Frosted vellum fill for inputs and quiet panels.
  static Color get vellum => _pick(0x08FFFFFF, 0xB3FFFFFF);

  /// Vellum under a finger or when selected.
  static Color get vellumActive => _pick(0x0DFFFFFF, 0xFFFFFFFF);

  /// Directional rim highlight on the top edge.
  static Color get rim => _pick(0x17FFFFFF, 0x14151B33);

  /// Brighter rim for floating chrome and focus.
  static Color get rimBright => _pick(0x1FFFFFFF, 0x1F151B33);

  /// Dividers and inactive tracks.
  static Color get hairline => _pick(0x0FFFFFFF, 0x17151B33);

  // ── Action (plum) ─────────────────────────────────────────────────────────
  /// Plum: primary actions, links, focus, the active tab. Clears 4.5:1 as
  /// text on the canvas and on cards in both modes.
  static Color get action => _pick(0xFFCFA6DC, 0xFF6A3C82);

  /// The lit top-left edge of a plum fill.
  static Color get actionLit => _pick(0xFFDDBDE8, 0xFF7E4A97);

  /// Text and icons set on a plum (or any accent) fill.
  static Color get onAction => _pick(0xFF0A0C14, 0xFFFFFFFF);

  // ── Metal (champagne) ─────────────────────────────────────────────────────
  /// The lens coating's warm end. Decoration only, never a meaning.
  static Color get champagne => _pick(0xFFEAE0CF, 0xFFA39275);

  // ── Meanings ──────────────────────────────────────────────────────────────
  /// Sea: optimal fit, within budget, a criterion won.
  static Color get good => _pick(0xFF7CC3CF, 0xFF1B6F86);

  /// The lit edge of a sea fill.
  static Color get goodLit => _pick(0xFF9AD3DC, 0xFF2A8299);

  /// Ochre: trade-offs, constraint caution, approaching the ceiling.
  static Color get caution => _pick(0xFFD9BE70, 0xFF8C6A12);

  /// Brick: anti-impulse friction — cooling off, over the ceiling.
  static Color get over => _pick(0xFFDE8A84, 0xFF8E3A3A);

  // ── Text (ink) ────────────────────────────────────────────────────────────
  /// Headings and key metrics.
  static Color get textPrimary => _pick(0xFFECEEF5, 0xFF151B33);

  /// Explanations and specs.
  static Color get textSecondary => _pick(0xFFA8AEC2, 0xFF4A5170);

  /// Micro labels and inactive states — still ≥ 4.5:1 on the canvas and on
  /// raised cards.
  static Color get textTertiary => _pick(0xFF848BA1, 0xFF5E6683);

  // ── Brand mark ────────────────────────────────────────────────────────────
  /// The lens ring in `assets/brand/clarion_logo.svg`, top-left to
  /// bottom-right: champagne where the light catches it, into plum. Fixed
  /// in both themes, like the mark itself.
  static const List<Color> lensRing = [
    Color(0xFFEAE0CF),
    Color(0xFFB07CC4),
    Color(0xFF6A3C82),
  ];

  /// Semantic colour for a 0–100 personal fit score.
  static Color forFit(num score) {
    if (score >= 85) return good;
    if (score >= 70) return action;
    return caution;
  }

  /// Semantic colour for budget utilisation (1.0 = at the ceiling).
  static Color forBudgetRatio(double ratio) {
    if (ratio > 1.0) return over;
    if (ratio >= 0.85) return caution;
    return good;
  }
}
