import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The matte obsidian canvas every screen sits on.
///
/// Three layers, all rasterised once behind a [RepaintBoundary] so they cost
/// nothing while content scrolls above:
///  1. the flat canvas base,
///  2. a single, very faint ambient pool of [glow] at the top edge,
///  3. a deterministic film grain that keeps large dark areas from banding
///     and gives the surface a tactile, printed quality.
class ObsidianCanvas extends StatelessWidget {
  const ObsidianCanvas({
    super.key,
    required this.child,
    this.glow,
    this.glowIntensity = 0.10,
  });

  final Widget child;

  /// Defaults to iris.
  final Color? glow;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _CanvasPainter(
              glow: glow ?? AppColors.iris,
              intensity: glowIntensity,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({required this.glow, required this.intensity});

  final Color glow;
  final double intensity;

  /// Grain is generated once and only regrown if the canvas gets larger;
  /// points outside a smaller canvas are simply clipped.
  static Size _grainSize = Size.zero;
  static (Float32List, Float32List)? _grainPoints;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..clipRect(rect)
      ..drawRect(rect, Paint()..color = AppColors.canvas);

    // Ambient pool centred above the top edge, so light seems to spill down
    // onto the canvas rather than sit on it.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, -size.height * 0.12),
          size.longestSide * 0.6,
          [
            glow.withValues(alpha: intensity),
            glow.withValues(alpha: intensity * 0.3),
            glow.withValues(alpha: 0),
          ],
          const [0, 0.42, 1],
        ),
    );

    if (_grainPoints == null ||
        size.width > _grainSize.width ||
        size.height > _grainSize.height) {
      _grainSize = Size(
        math.max(size.width, _grainSize.width),
        math.max(size.height, _grainSize.height),
      );
      _grainPoints = _grain(_grainSize);
    }
    final (light, dark) = _grainPoints!;
    canvas
      ..drawRawPoints(
        ui.PointMode.points,
        light,
        Paint()
          ..color = Color(AppColors.isDark ? 0x09FFFFFF : 0x66FFFFFF)
          ..strokeWidth = 1,
      )
      ..drawRawPoints(
        ui.PointMode.points,
        dark,
        Paint()
          ..color = Color(AppColors.isDark ? 0x33000000 : 0x0A000000)
          ..strokeWidth = 1,
      );
  }

  static (Float32List, Float32List) _grain(Size size) {
    final rnd = math.Random(7);
    final count = (size.width * size.height / 90).round();
    Float32List scatter() {
      final points = Float32List(count * 2);
      for (var i = 0; i < points.length; i += 2) {
        points[i] = rnd.nextDouble() * size.width;
        points[i + 1] = rnd.nextDouble() * size.height;
      }
      return points;
    }

    return (scatter(), scatter());
  }

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.glow != glow || old.intensity != intensity;
}
