import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Sparkline of a 30-day price series with a dashed average reference line.
///
/// The line draws itself in on first build; the current price is marked by
/// a glowing terminal dot.
class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({
    super.key,
    required this.points,
    this.average,
    this.height = 96,
    this.color = AppColors.accent,
  });

  final List<double> points;
  final double? average;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1200),
        curve: AppMotion.emphasized,
        builder: (context, t, _) => CustomPaint(
          size: Size(double.infinity, height),
          painter: _TrendPainter(
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

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.average,
    required this.color,
    required this.progress,
  });

  final List<double> points;
  final double? average;
  final Color color;
  final double progress;

  static const double _vPad = 10;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    var lo = points.reduce((a, b) => a < b ? a : b);
    var hi = points.reduce((a, b) => a > b ? a : b);
    if (average != null) {
      lo = lo < average! ? lo : average!;
      hi = hi > average! ? hi : average!;
    }
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : hi - lo;
    final usableH = size.height - _vPad * 2;

    Offset at(int i) => Offset(
      size.width * i / (points.length - 1),
      _vPad + usableH * (1 - (points[i] - lo) / span),
    );

    // Smooth path via midpoint quadratic segments.
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
    final tip = metric.getTangentForOffset(metric.length * progress)?.position;

    // Area fill beneath the visible portion.
    if (tip != null) {
      final area = Path.from(visible)
        ..lineTo(tip.dx, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0),
          ]),
      );
    }

    // Average reference line.
    if (average != null) {
      final y = _vPad + usableH * (1 - (average! - lo) / span);
      final dash = Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..strokeWidth = 1;
      const dashW = 4.0, gap = 4.0;
      for (var x = 0.0; x < size.width; x += dashW + gap) {
        canvas.drawLine(Offset(x, y), Offset(x + dashW, y), dash);
      }
    }

    canvas.drawPath(
      visible,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, 0), [
          AppColors.primary,
          color,
        ]),
    );

    if (tip != null && progress > 0.98) {
      canvas.drawCircle(
        tip,
        7,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(tip, 4, Paint()..color = Colors.white);
      canvas.drawCircle(tip, 2.4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.progress != progress ||
      old.points != points ||
      old.average != average ||
      old.color != color;
}
