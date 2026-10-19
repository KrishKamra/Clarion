import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Minimal animated circular progress ring.
///
/// Values above 1.0 render a full ring – callers convey overflow through
/// [color] (e.g. coral when over budget).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 22,
    this.strokeWidth = 3,
    this.trackColor,
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      builder: (context, v, child) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(
          value: v,
          color: color,
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? Colors.white.withValues(alpha: 0.1),
        ),
        child: SizedBox.square(dimension: size, child: child),
      ),
      child: child == null ? null : Center(child: child),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = trackColor);
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
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
