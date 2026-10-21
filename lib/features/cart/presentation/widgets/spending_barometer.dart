import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_metric.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../application/budget_controller.dart';

/// Caution begins at this share of the ceiling (matches
/// `AppColors.forBudgetRatio`).
const double _cautionAt = 0.85;

/// One block of committed spend on the barometer.
class _Segment {
  const _Segment(this.label, this.amount, this.start);

  final String label;
  final double amount;

  /// Cumulative spend before this segment.
  final double start;

  double get end => start + amount;
}

/// The Spending Barometer: committed spend as one multi-segment bar laid
/// over three zones — Safe (emerald) → Caution (amber) → Over (rose).
///
/// Settled spend and every cart item are separate segments, each coloured
/// by the zone it pushes the month into. Touch or drag along the bar to
/// read what any segment contributes and where it lands you.
class SpendingBarometer extends StatefulWidget {
  const SpendingBarometer({
    super.key,
    required this.budget,
    required this.items,
  });

  final BudgetSnapshot budget;
  final List<CartItem> items;

  @override
  State<SpendingBarometer> createState() => _SpendingBarometerState();
}

class _SpendingBarometerState extends State<SpendingBarometer> {
  int? _selected;

  List<_Segment> get _segments {
    final out = <_Segment>[];
    var cursor = 0.0;
    void push(String label, double amount) {
      if (amount <= 0) return;
      out.add(_Segment(label, amount, cursor));
      cursor += amount;
    }

    push('Settled this month', widget.budget.spent);
    for (final item in widget.items) {
      push(item.product.title, item.subtotal);
    }
    return out;
  }

  double get _scale =>
      math.max(widget.budget.committed, widget.budget.limit * 1.15);

  void _touch(double dx, double width, List<_Segment> segments) {
    final value = dx / width * _scale;
    final i = segments.indexWhere((s) => value >= s.start && value < s.end);
    if (i < 0 || i == _selected) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = i);
  }

  void _release() {
    if (_selected != null) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.budget;
    final segments = _segments;
    final status = AppColors.forBudgetRatio(b.ratio);
    final selected = _selected != null && _selected! < segments.length
        ? segments[_selected!]
        : null;

    return TactileCard(
      material: CardMaterial.floating,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SPENDING BAROMETER', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedMetric(
                value: b.committed,
                format: Fmt.inr,
                style: AppTypography.metricXL,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  '/ ${Fmt.inr(b.limit)}',
                  maxLines: 1,
                  style: AppTypography.metric.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            b.isOver
                ? '${Fmt.inr(b.overBy)} over monthly limit'
                : b.ratio >= _cautionAt
                ? 'Caution zone · ${Fmt.inr(b.headroom)} left'
                : 'Safe zone · ${Fmt.inr(b.headroom)} of headroom',
            style: AppTypography.label.copyWith(color: status),
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, c) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) =>
                  _touch(d.localPosition.dx, c.maxWidth, segments),
              onHorizontalDragUpdate: (d) =>
                  _touch(d.localPosition.dx, c.maxWidth, segments),
              onHorizontalDragEnd: (_) => _release(),
              onHorizontalDragCancel: _release,
              onTapDown: (d) =>
                  _touch(d.localPosition.dx, c.maxWidth, segments),
              onTapUp: (_) => _release(),
              onTapCancel: _release,
              child: RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: AppMotion.reveal,
                  curve: AppMotion.standard,
                  builder: (context, reveal, _) => CustomPaint(
                    size: Size(c.maxWidth, 40),
                    painter: _BarometerPainter(
                      segments: segments,
                      limit: b.limit,
                      scale: _scale,
                      reveal: reveal,
                      selected: _selected,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: selected == null
                ? Text(
                    'Touch the bar to see what each item adds.',
                    key: const ValueKey('hint'),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  )
                : _Readout(
                    key: ValueKey(selected.label),
                    segment: selected,
                    limit: b.limit,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({super.key, required this.segment, required this.limit});

  final _Segment segment;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final landsAt = segment.end / limit;
    return Row(
      children: [
        Expanded(
          child: Text(
            segment.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '+${Fmt.inr(segment.amount)} → ${Fmt.percent(landsAt * 100)}',
          style: AppTypography.metricSmall.copyWith(
            color: AppColors.forBudgetRatio(landsAt),
          ),
        ),
      ],
    );
  }
}

class _BarometerPainter extends CustomPainter {
  _BarometerPainter({
    required this.segments,
    required this.limit,
    required this.scale,
    required this.reveal,
    required this.selected,
  });

  final List<_Segment> segments;
  final double limit;
  final double scale;

  /// 0–1 share of committed spend drawn so far (first-build reveal).
  final double reveal;
  final int? selected;

  static const double _barTop = 6;
  static const double _barH = 10;

  @override
  void paint(Canvas canvas, Size size) {
    double x(double v) => size.width * (v / scale).clamp(0.0, 1.0);
    final bar = Rect.fromLTWH(0, _barTop, size.width, _barH);
    final clip = RRect.fromRectAndRadius(bar, const Radius.circular(_barH));

    canvas
      ..save()
      ..clipRRect(clip);

    // Zone field: safe → caution → over, as quiet tints.
    final zones = [
      (0.0, limit * _cautionAt, AppColors.emeraldGlow),
      (limit * _cautionAt, limit, AppColors.amber),
      (limit, scale, AppColors.rose),
    ];
    for (final (from, to, color) in zones) {
      canvas.drawRect(
        Rect.fromLTRB(x(from), bar.top, x(to), bar.bottom),
        Paint()..color = color.withValues(alpha: 0.10),
      );
    }

    // Committed segments, each coloured by the zone it ends in.
    final drawnTo = (segments.isEmpty ? 0.0 : segments.last.end) * reveal;
    for (final (i, s) in segments.indexed) {
      if (s.start >= drawnTo) break;
      final end = math.min(s.end, drawnTo);
      final color = i == 0
          ? AppColors.textSecondary
          : AppColors.forBudgetRatio(s.end / limit);
      final dim = selected != null && selected != i;
      canvas.drawRect(
        Rect.fromLTRB(
          x(s.start),
          bar.top,
          math.max(x(s.start), x(end) - 2),
          bar.bottom,
        ),
        Paint()..color = color.withValues(alpha: dim ? 0.35 : 1),
      );
    }
    canvas.restore();

    // Ceiling tick with its label, plus the safe-zone marker.
    final ceilingX = x(limit);
    canvas.drawLine(
      Offset(ceilingX, 0),
      Offset(ceilingX, _barTop + _barH + 6),
      Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = 1.5,
    );
    const labelY = _barTop + _barH + 8;
    _label(canvas, 'SAFE', const Offset(0, labelY), AppColors.emeraldGlow);
    _label(
      canvas,
      'LIMIT',
      Offset(ceilingX, labelY),
      AppColors.textPrimary,
      centred: true,
    );
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at,
    Color color, {
    bool centred = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTypography.overline.copyWith(fontSize: 8.5, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centred ? at - Offset(tp.width / 2, 0) : at);
  }

  @override
  bool shouldRepaint(_BarometerPainter old) =>
      old.reveal != reveal ||
      old.selected != selected ||
      old.limit != limit ||
      old.scale != scale ||
      old.segments.length != segments.length ||
      (segments.isNotEmpty && old.segments.last.end != segments.last.end);
}
