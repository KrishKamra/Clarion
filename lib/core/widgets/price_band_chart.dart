import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/product_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

/// Interactive 30-day price band: the low–high range as a quiet field, the
/// moving average as a dashed rule, and the daily series drawn over it.
///
/// Drag (or tap) across the chart to scrub: a cursor snaps to each day and
/// the readout shows that day's price against today's, ticking with a
/// selection haptic as it moves. Release to return to today.
class PriceBandChart extends StatefulWidget {
  const PriceBandChart({
    super.key,
    required this.points,
    required this.average,
    this.height = 112,
    this.color,
  });

  final List<PricePoint> points;
  final double average;
  final double height;
  final Color? color;

  @override
  State<PriceBandChart> createState() => _PriceBandChartState();
}

class _PriceBandChartState extends State<PriceBandChart> {
  int? _selected;

  void _scrub(double dx, double width) {
    final n = widget.points.length;
    final i = (dx / width * (n - 1)).round().clamp(0, n - 1);
    if (i == _selected) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = i);
  }

  void _release() {
    if (_selected != null) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.points.last;
    final shown = _selected == null ? today : widget.points[_selected!];
    final delta = shown.price - today.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Readout(
          label: _selected == null ? 'TODAY' : Fmt.shortDate(shown.date),
          price: shown.price,
          delta: _selected == null ? null : delta,
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (d) =>
                _scrub(d.localPosition.dx, c.maxWidth),
            onHorizontalDragUpdate: (d) =>
                _scrub(d.localPosition.dx, c.maxWidth),
            onHorizontalDragEnd: (_) => _release(),
            onHorizontalDragCancel: _release,
            onTapDown: (d) => _scrub(d.localPosition.dx, c.maxWidth),
            onTapUp: (_) => _release(),
            onTapCancel: _release,
            child: RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.reveal,
                curve: AppMotion.standard,
                builder: (context, t, _) => CustomPaint(
                  size: Size(c.maxWidth, widget.height),
                  painter: _BandPainter(
                    prices: [for (final p in widget.points) p.price],
                    average: widget.average,
                    color: widget.color ?? AppColors.emeraldGlow,
                    progress: t,
                    selected: _selected,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.label, required this.price, this.delta});

  final String label;
  final double price;
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final d = delta;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 56,
          child: Text(label.toUpperCase(), style: AppTypography.overline),
        ),
        Text(Fmt.inr(price), style: AppTypography.metric),
        const Spacer(),
        if (d != null && d.abs() >= 1)
          Text(
            '${Fmt.inr(d.abs())} ${d > 0 ? 'above' : 'below'} today',
            style: AppTypography.metricSmall.copyWith(
              color: d > 0 ? AppColors.emeraldGlow : AppColors.amber,
            ),
          )
        else
          Text(
            'Drag to scrub',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}

class _BandPainter extends CustomPainter {
  _BandPainter({
    required this.prices,
    required this.average,
    required this.color,
    required this.progress,
    required this.selected,
  });

  final List<double> prices;
  final double average;
  final Color color;
  final double progress;
  final int? selected;

  static const double _pad = 12;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final lo = prices.reduce((a, b) => a < b ? a : b);
    final hi = prices.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : hi - lo;
    final usable = size.height - _pad * 2;
    double y(double v) => _pad + usable * (1 - (v - lo) / span);
    Offset at(int i) =>
        Offset(size.width * i / (prices.length - 1), y(prices[i]));

    // Band field between the 30-day low and high.
    final band = Rect.fromLTRB(0, y(hi), size.width, y(lo));
    canvas.drawRect(band, Paint()..color = AppColors.vellum);
    final edge = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1;
    canvas
      ..drawLine(band.topLeft, band.topRight, edge)
      ..drawLine(band.bottomLeft, band.bottomRight, edge);

    // 30-day moving average.
    final avgY = y(average);
    final dash = Paint()
      ..color = AppColors.textTertiary
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, avgY), Offset(x + 3, avgY), dash);
    }

    // Series, smoothed through midpoints.
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < prices.length; i++) {
      final p0 = at(i - 1);
      final p1 = at(i);
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(at(prices.length - 1).dx, at(prices.length - 1).dy);

    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
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

    if (progress < 1) return;
    _dot(canvas, at(prices.length - 1), color);

    final s = selected;
    if (s != null) {
      final p = at(s);
      canvas.drawLine(
        Offset(p.dx, 0),
        Offset(p.dx, size.height),
        Paint()
          ..color = AppColors.textSecondary.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
      _dot(canvas, p, AppColors.textPrimary);
    }
  }

  void _dot(Canvas canvas, Offset at, Color c) {
    canvas
      ..drawCircle(at, 9, Paint()..color = c.withValues(alpha: 0.14))
      ..drawCircle(at, 3.5, Paint()..color = c)
      ..drawCircle(
        at,
        3.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.canvas,
      );
  }

  @override
  bool shouldRepaint(_BandPainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      old.prices != prices ||
      old.average != average ||
      old.color != color;
}
