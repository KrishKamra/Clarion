import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 30-day price band: the low–high range as a quiet field, the average as a
/// dashed rule, and the daily series drawn over it ending in today's price.
///
/// The band answers "is this a good moment?" at a glance — where the final
/// dot sits inside the field is the whole story.
class PriceBandChart extends StatelessWidget {
  const PriceBandChart({
    super.key,
    required this.points,
    required this.average,
    this.height = 112,
    this.color = AppColors.emeraldGlow,
  });

  final List<double> points;
  final double average;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.reveal,
        curve: AppMotion.standard,
        builder: (context, t, _) => CustomPaint(
          size: Size(double.infinity, height),
          painter: _BandPainter(
            points: points,
            average: average,
            color: color,
            progress: t,
          ),
        ),
      ),
    );
  }
}

class _BandPainter extends CustomPainter {
  _BandPainter({
    required this.points,
    required this.average,
    required this.color,
    required this.progress,
  });

  final List<double> points;
  final double average;
  final Color color;
  final double progress;

  static const double _pad = 12;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final lo = points.reduce((a, b) => a < b ? a : b);
    final hi = points.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : hi - lo;
    final usable = size.height - _pad * 2;
    double y(double v) => _pad + usable * (1 - (v - lo) / span);
    Offset at(int i) =>
        Offset(size.width * i / (points.length - 1), y(points[i]));

    // Band field between the 30-day low and high.
    final band = Rect.fromLTRB(0, y(hi), size.width, y(lo));
    canvas.drawRect(band, Paint()..color = AppColors.vellum);
    final edge = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1;
    canvas
      ..drawLine(band.topLeft, band.topRight, edge)
      ..drawLine(band.bottomLeft, band.bottomRight, edge);

    // Average rule.
    final avgY = y(average);
    final dash = Paint()
      ..color = AppColors.textTertiary
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, avgY), Offset(x + 3, avgY), dash);
    }

    // Series.
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = at(i - 1);
      final p1 = at(i);
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(at(points.length - 1).dx, at(points.length - 1).dy);

    final metric = path.computeMetrics().first;
    final visible = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      visible,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, 0), [
          AppColors.textTertiary,
          color,
        ]),
    );

    if (progress >= 1) {
      final tip = at(points.length - 1);
      canvas
        ..drawCircle(tip, 9, Paint()..color = color.withValues(alpha: 0.14))
        ..drawCircle(tip, 3.5, Paint()..color = color)
        ..drawCircle(
          tip,
          3.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = AppColors.canvas,
        );
    }
  }

  @override
  bool shouldRepaint(_BandPainter old) =>
      old.progress != progress ||
      old.points != points ||
      old.average != average ||
      old.color != color;
}
