import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Material recipes shared by every Clarion surface.
///
/// Three materials, each with a cost profile:
///  * **Raised** — opaque [AppColors.surface] with a faint top luminance
///    wash. Zero compositing cost; the default for anything in a list.
///  * **Vellum** — translucent white at 3 %. Equally cheap (no blur), lets
///    the canvas grain show through for inputs and quiet panels.
///  * **Frost** — a real backdrop blur. Reserved for fixed chrome that never
///    scrolls: the nav island, pinned headers, sheets and the decision drawer.
///
/// All three share the directional rim light painted by [RimLightPainter].
abstract final class AppDecorations {
  /// Backdrop blur for frosted chrome.
  static ui.ImageFilter frost([double sigma = 24]) =>
      ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  /// Fill used beneath frosted chrome so text stays legible over any content.
  static const Color frostFill = Color(0xB80F1117); // surface @ 72 %

  /// 1px edge light falling from above: bright on the top edge, fading out
  /// down the sides so the bottom edge all but disappears.
  static const LinearGradient rimLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.rimBright, Color(0x0AFFFFFF), Color(0x03FFFFFF)],
    stops: [0, 0.35, 1],
  );

  /// Softer rim for surfaces that sit flush in content.
  static const LinearGradient rimLightSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.rim, Color(0x06FFFFFF), Color(0x02FFFFFF)],
    stops: [0, 0.35, 1],
  );

  /// The 4 % luminance wash that gives raised cards their paper-like lift
  /// (#0F1117 with white at 4 % composited on top, fading to the surface).
  static const LinearGradient raisedWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF181A20), AppColors.surface],
    stops: [0, 0.6],
  );

  static BoxDecoration raised({
    BorderRadius borderRadius = AppRadii.lgAll,
    Color? tint,
  }) => BoxDecoration(
    borderRadius: borderRadius,
    gradient: tint == null
        ? raisedWash
        : _tintWash(tint, over: AppColors.surface),
  );

  static BoxDecoration vellum({
    BorderRadius borderRadius = AppRadii.lgAll,
    Color? tint,
    bool active = false,
  }) {
    final fill = active ? AppColors.vellumActive : AppColors.vellum;
    return BoxDecoration(
      color: tint == null ? fill : null,
      borderRadius: borderRadius,
      gradient: tint == null ? null : _tintWash(tint, over: fill),
    );
  }

  /// A contextual wash of [tint] from the top-left corner — the only place
  /// a card carries colour, used to flag a single insight.
  static LinearGradient _tintWash(Color tint, {required Color over}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.alphaBlend(tint.withValues(alpha: 0.10), over), over],
        stops: const [0, 0.7],
      );

  /// Ambient backlight: a radial pool of light behind a key metric. Painted
  /// as a gradient (never a blur), so it costs one draw call.
  static RadialGradient backlight(Color color, {double intensity = 0.18}) =>
      RadialGradient(
        colors: [
          color.withValues(alpha: intensity),
          color.withValues(alpha: intensity * 0.35),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      );

  /// Contact shadow for chrome that floats above content.
  static const List<BoxShadow> floatShadow = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 32,
      offset: Offset(0, 14),
      spreadRadius: -10,
    ),
  ];
}

/// Strokes a 1px gradient around a rounded rect — Flutter's [Border] only
/// takes solid colours, and the rim light needs to fall off directionally.
class RimLightPainter extends CustomPainter {
  const RimLightPainter({
    required this.borderRadius,
    this.gradient = AppDecorations.rimLight,
    this.strokeWidth = 1,
  });

  final BorderRadius borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect).deflate(strokeWidth / 2);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(RimLightPainter old) =>
      old.borderRadius != borderRadius ||
      old.gradient != gradient ||
      old.strokeWidth != strokeWidth;
}
