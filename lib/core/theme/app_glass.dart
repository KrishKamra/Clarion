import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Glassmorphism primitives shared by every frosted surface.
///
/// Two tiers exist on purpose:
///  * **True glass** ([blur]) – a real `BackdropFilter`. Reserved for
///    persistent overlays (app bars, the navigation bar, sheets, dialogs).
///  * **Faux glass** ([cardDecoration]) – a translucent gradient fill plus a
///    directional sheen border. Visually close, but costs nothing to
///    composite, so it is safe for repeating items inside scroll views.
abstract final class AppGlass {
  static const double defaultBlur = 16;
  static const double defaultOpacity = 0.07;
  static const double defaultRadius = AppRadii.lg;

  /// Gaussian blur filter used for true-glass surfaces.
  static ui.ImageFilter blur([double sigma = defaultBlur]) =>
      ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  /// Top-left → bottom-right border sheen: bright where "light" hits the
  /// glass edge, fading to nearly invisible on the far corner.
  static LinearGradient borderGradient({double intensity = 1}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22 * intensity),
          Colors.white.withValues(alpha: 0.06 * intensity),
          Colors.white.withValues(alpha: 0.02 * intensity),
        ],
        stops: const [0, 0.45, 1],
      );

  /// Translucent body fill with a soft inner gradient.
  static LinearGradient fillGradient({
    double opacity = defaultOpacity,
    Color? tint,
  }) {
    final base = tint ?? Colors.white;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        base.withValues(alpha: opacity * 1.35),
        base.withValues(alpha: opacity * 0.55),
      ],
    );
  }

  /// Cheap faux-glass decoration for list items. Pair with
  /// [GlassBorderPainter] (via `GlassContainer(blur: 0)`) for the sheen edge,
  /// or use alone where a flat hairline border is enough.
  static BoxDecoration cardDecoration({
    double opacity = defaultOpacity,
    double radius = defaultRadius,
    Color? tint,
  }) => BoxDecoration(
    gradient: fillGradient(opacity: opacity, tint: tint),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.glassBorderFaint),
  );

  /// Soft coloured glow shadow used in place of material elevation.
  static List<BoxShadow> glow(
    Color color, {
    double blurRadius = AppElevation.glowMedium,
    double opacity = 0.45,
    Offset offset = const Offset(0, 8),
  }) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: blurRadius,
      offset: offset,
      spreadRadius: -6,
    ),
  ];
}

/// Paints a 1px gradient stroke around a rounded rect.
///
/// Flutter's [Border] only supports solid colours; this painter gives glass
/// surfaces their characteristic directional edge highlight.
class GlassBorderPainter extends CustomPainter {
  const GlassBorderPainter({
    required this.radius,
    required this.gradient,
    this.strokeWidth = 1,
  });

  final double radius;
  final Gradient gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GlassBorderPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.gradient != gradient ||
      oldDelegate.strokeWidth != strokeWidth;
}
