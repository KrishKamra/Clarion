import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';

/// Minimal animated circular progress ring.
///
/// Values above 1.0 render a full ring — callers convey overflow through
/// [color]. Set [backlit] to pool a little light behind it.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 22,
    this.strokeWidth = 2.5,
    this.backlit = false,
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool backlit;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget ring = TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: AppMotion.reveal,
      curve: AppMotion.standard,
      builder: (context, v, child) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(value: v, color: color, strokeWidth: strokeWidth),
        child: child,
      ),
      child: SizedBox.square(
        dimension: size,
        child: child == null ? null : Center(child: child),
      ),
    );

    if (backlit) {
      ring = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppDecorations.backlight(color, intensity: 0.22),
        ),
        child: ring,
      );
    }
    return RepaintBoundary(child: ring);
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = AppColors.hairline);
    if (value <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
