import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../budget/application/budget_controller.dart';

enum _BarometerView { month, cart }

/// Semicircular Budget Guardian gauge (green → amber → red).
///
/// Tap to flip between the whole month (settled + cart vs limit) and the
/// cart alone (cart vs what's left in the envelope). The needle animates to
/// every change, so a one-tap swap visibly pulls the reading back.
class BudgetBarometer extends StatefulWidget {
  const BudgetBarometer({super.key, required this.budget});

  final BudgetSnapshot budget;

  @override
  State<BudgetBarometer> createState() => _BudgetBarometerState();
}

class _BudgetBarometerState extends State<BudgetBarometer> {
  /// The gauge runs to 125 % of the limit so overspend stays visible.
  static const double _overflowRange = 1.25;

  _BarometerView _view = _BarometerView.month;

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _view = _view == _BarometerView.month
          ? _BarometerView.cart
          : _BarometerView.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.budget;
    final isMonth = _view == _BarometerView.month;
    final value = isMonth ? b.committed : b.cart;
    final limit = isMonth ? b.limit : math.max(b.envelopeBeforeCart, 1.0);
    final ratio = value / limit;
    final color = AppColors.forBudgetRatio(ratio);

    return GlassContainer.card(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      borderRadius: AppRadii.xl,
      onTap: _toggle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BUDGET BAROMETER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.overline,
                ),
              ),
              _ViewToggle(isMonth: isMonth),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return SizedBox(
                width: w,
                height: w * 0.56,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: (ratio / _overflowRange).clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (context, t, child) => CustomPaint(
                    painter: _GaugePainter(
                      progress: t.clamp(0.0, 1.0),
                      limitAt: 1 / _overflowRange,
                    ),
                    child: child,
                  ),
                  child: Align(
                    alignment: const Alignment(0, 0.75),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(end: value),
                          duration: const Duration(milliseconds: 700),
                          curve: AppMotion.standard,
                          builder: (context, v, _) => Text(
                            Fmt.inr(v),
                            style: AppTypography.numericLarge.copyWith(
                              fontSize: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isMonth
                              ? 'of ${Fmt.inr(limit)} monthly limit'
                              : 'in cart · ${Fmt.inr(limit)} left to spend',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _StatusPill(budget: b, color: color),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _Breakdown(budget: b),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isMonth});

  final bool isMonth;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool active) => AnimatedContainer(
      duration: AppMotion.medium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillAll,
        color: active ? Colors.white.withValues(alpha: 0.12) : null,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: active ? AppColors.textPrimary : AppColors.textTertiary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillAll,
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.glassBorderFaint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [seg('Month', isMonth), seg('Cart', !isMonth)],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.budget, required this.color});

  final BudgetSnapshot budget;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = budget.isOver
        ? '${Fmt.inr(budget.overBy)} over budget'
        : '${Fmt.inr(budget.headroom)} headroom';
    return AnimatedContainer(
      duration: AppMotion.medium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillAll,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            budget.isOver
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.label.copyWith(color: color, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.budget});

  final BudgetSnapshot budget;

  @override
  Widget build(BuildContext context) {
    final b = budget;
    final scale = math.max(b.committed, b.limit);
    final segments = <(String, double, Color)>[
      ('Settled', b.spent, AppColors.primary),
      ('In cart', b.cart, AppColors.secondary),
      if (b.isOver)
        ('Over', b.overBy, AppColors.fitLow)
      else
        ('Headroom', b.headroom, AppColors.fitHigh),
    ];
    // When over, the "in cart" bar shows only the portion that fits.
    final barSegments = <(double, Color)>[
      (b.spent, AppColors.primary),
      (b.isOver ? b.cart - b.overBy : b.cart, AppColors.secondary),
      (
        b.isOver ? b.overBy : b.headroom,
        b.isOver ? AppColors.fitLow : Colors.white.withValues(alpha: 0.08),
      ),
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadii.pillAll,
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (final (amount, color) in barSegments)
                  if (amount > 0)
                    Expanded(
                      flex: (amount / scale * 1000).round().clamp(1, 1000),
                      child: Container(
                        margin: const EdgeInsets.only(right: 2),
                        color: color,
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final (label, amount, color) in segments)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(label, style: AppTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(Fmt.inr(amount), style: AppTypography.numericSmall),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.limitAt});

  /// Needle position, 0–1 across the arc.
  final double progress;

  /// Arc fraction at which the limit sits.
  final double limitAt;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final radius = math.min(size.width / 2, size.height) - stroke;
    final center = Offset(size.width / 2, radius + stroke * 0.75);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final amberAt = limitAt * 0.85;
    final shader = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: const [
        AppColors.fitHigh,
        AppColors.fitHigh,
        AppColors.fitMid,
        AppColors.fitLow,
        AppColors.fitLow,
      ],
      stops: [0, amberAt - 0.08, amberAt + 0.04, limitAt + 0.02, 1],
    ).createShader(rect);

    // Dim full track.
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader
        ..colorFilter = ColorFilter.mode(
          Colors.black.withValues(alpha: 0.72),
          BlendMode.srcATop,
        ),
    );

    if (progress > 0) {
      final sweep = math.pi * progress;
      // Glow beneath the filled arc.
      canvas.drawArc(
        rect,
        math.pi,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = shader
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawArc(
        rect,
        math.pi,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = shader,
      );
    }

    // Limit tick.
    final limitAngle = math.pi + math.pi * limitAt;
    final dir = Offset(math.cos(limitAngle), math.sin(limitAngle));
    canvas.drawLine(
      center + dir * (radius - stroke * 0.95),
      center + dir * (radius + stroke * 0.95),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'LIMIT',
        style: AppTypography.overline.copyWith(
          fontSize: 8.5,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelPos = center + dir * (radius + stroke * 1.6);
    tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));

    // Needle knob.
    final knobAngle = math.pi + math.pi * progress;
    final knob =
        center + Offset(math.cos(knobAngle), math.sin(knobAngle)) * radius;
    canvas.drawCircle(
      knob,
      stroke * 0.75,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(knob, stroke * 0.62, Paint()..color = Colors.white);
    canvas.drawCircle(
      knob,
      stroke * 0.32,
      Paint()..color = AppColors.backgroundDeep,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.limitAt != limitAt;
}
