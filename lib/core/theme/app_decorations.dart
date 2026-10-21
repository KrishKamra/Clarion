import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Material recipes shared by every Clarion surface.
///
/// Four materials, each with a known cost:
///  * **Matte** (tier 1) — opaque `#0E1017` with a 3 % ambient wash.
///  * **Floating** (tier 2) — `#141824` with a 0.5px edge and a specular
///    sheen in the top-left corner, for the one surface that should lift.
///  * **Vellum** — translucent white at 3 % for inputs and quiet panels.
///  * **Frost** — a real backdrop blur, reserved for fixed spatial chrome
///    (nav capsule, pinned headers, sheets, the decision bar).
///
/// The first three cost nothing to composite and are safe in fast lists.
/// All four share the directional rim light painted by [RimLightPainter].
abstract final class AppDecorations {
  /// Backdrop blur for frosted chrome.
  static ui.ImageFilter frost([double sigma = 24]) =>
      ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  /// Fill beneath frosted chrome so text stays legible over any content.
  static const Color frostFill = Color(0xB80E1017); // surface @ 72 %

  /// Directional specular rim: light falls from the top-left, so the edge
  /// is brightest there and all but vanishes at the bottom-right.
  static const LinearGradient rimLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x05FFFFFF)], // 15 % → 2 %
  );

  /// Softer rim for vellum and flush surfaces.
  static const LinearGradient rimLightSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x17FFFFFF), Color(0x03FFFFFF)], // 9 % → 1 %
  );

  /// Tier 1: #0E1017 lifted by a 3 % ambient wash at the top.
  static const LinearGradient matteWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF15171E), AppColors.surface],
    stops: [0, 0.65],
  );

  /// Tier 2: #141824 with a specular sheen pooled in the top-left corner.
  static const LinearGradient floatingSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF202330), AppColors.surfaceHigh],
    stops: [0, 0.55],
  );

  static BoxDecoration matte({
    BorderRadius borderRadius = AppRadii.lgAll,
    Color? tint,
  }) => BoxDecoration(
    borderRadius: borderRadius,
    gradient: tint == null ? matteWash : _tintWash(tint, AppColors.surface),
  );

  static BoxDecoration floating({
    BorderRadius borderRadius = AppRadii.lgAll,
    Color? tint,
  }) => BoxDecoration(
    borderRadius: borderRadius,
    border: Border.all(color: AppColors.edge, width: 0.5),
    gradient: tint == null
        ? floatingSheen
        : _tintWash(tint, AppColors.surfaceHigh),
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
      gradient: tint == null ? null : _tintWash(tint, fill),
    );
  }

  /// A contextual wash of [tint] from the top-left — the only place a card
  /// carries colour, used to flag a single insight.
  static LinearGradient _tintWash(Color tint, Color over) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.alphaBlend(tint.withValues(alpha: 0.10), over), over],
    stops: const [0, 0.7],
  );

  /// Ambient backlight halo: a radial pool of light behind a key decision
  /// node. Painted as a gradient (never a blur), so it costs one draw call.
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

/// Strokes a hairline gradient around a rounded rect — Flutter's [Border]
/// only takes solid colours, and the specular rim needs to fall off.
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
