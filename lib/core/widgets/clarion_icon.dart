import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Clarion's own glyphs, for the four primary destinations.
enum ClarionGlyph {
  /// Intent Horizon: a light rising on the horizon.
  horizon,

  /// Compare: two lenses overlapping.
  compare,

  /// Budget Guardian: the budget ring.
  guardian,

  /// Spending Profile: a figure whose head is a lens.
  profile,
}

/// A [ClarionGlyph], drawn on a 24-unit grid in 1.7-unit strokes with round
/// caps, like the rest of Clarion's line work.
///
/// Every glyph carries the logo's off-centre focal point. When [selected],
/// it grows into place and takes the action colour — the same focus lock
/// the splash plays, at the size of a tab — and the shape gains a faint
/// fill. That dot is the only colour in the tab bar.
class ClarionIcon extends StatelessWidget {
  const ClarionIcon(
    this.glyph, {
    super.key,
    required this.color,
    this.selected = false,
    this.size = 24,
  });

  final ClarionGlyph glyph;
  final Color color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: still ? Duration.zero : AppMotion.medium,
      curve: AppMotion.standard,
      builder: (context, focus, _) => CustomPaint(
        size: Size.square(size),
        painter: _GlyphPainter(
          glyph: glyph,
          color: color,
          focus: focus,
          focusColor: AppColors.action,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.glyph,
    required this.color,
    required this.focus,
    required this.focusColor,
  });

  final ClarionGlyph glyph;
  final Color color;

  /// 0 at rest, 1 when selected.
  final double focus;
  final Color focusColor;

  static const _stroke = 1.7;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final tint = Paint()..color = color.withValues(alpha: 0.12 * focus);

    final (body, strokes, dot) = _shape();
    if (focus > 0 && body != null) canvas.drawPath(body, tint);
    for (final p in strokes) {
      canvas.drawPath(p, line);
    }

    // The focal point: small and quiet at rest, full and plum when chosen.
    // On the guardian ring the resting dot shrinks to the stroke, so it
    // reads as part of the ring until it is chosen.
    final rest = glyph == ClarionGlyph.guardian ? _stroke / 2 : 1.05;
    final r = _lerp(rest, 1.75, focus);
    canvas.drawCircle(
      dot,
      r,
      Paint()..color = Color.lerp(color, focusColor, focus)!,
    );
  }

  /// The tinted area (if any), the stroked paths, and the focal point.
  (Path?, List<Path>, Offset) _shape() {
    switch (glyph) {
      case ClarionGlyph.horizon:
        final sun = Rect.fromCircle(
          center: const Offset(12, 16.5),
          radius: 6.5,
        );
        final arc = Path()..addArc(sun, math.pi, math.pi);
        final ground = Path()
          ..moveTo(3.5, 16.5)
          ..lineTo(20.5, 16.5);
        final body = Path()
          ..addArc(sun, math.pi, math.pi)
          ..close();
        return (body, [arc, ground], const Offset(13.9, 13.4));
      case ClarionGlyph.compare:
        final a = Path()
          ..addOval(
            Rect.fromCircle(center: const Offset(8.7, 12), radius: 5.6),
          );
        final b = Path()
          ..addOval(
            Rect.fromCircle(center: const Offset(15.3, 12), radius: 5.6),
          );
        // Only where the two lenses overlap is tinted: what they share.
        final body = Path.combine(PathOperation.intersect, a, b);
        return (body, [a, b], const Offset(12, 12));
      case ClarionGlyph.guardian:
        const centre = Offset(12, 12.5);
        const r = 7.5;
        const start = math.pi * 0.75;
        const sweep = math.pi * 1.5;
        final rect = Rect.fromCircle(center: centre, radius: r);
        final ring = Path()..addArc(rect, start, sweep);
        // The dot rides the ring where spending has reached.
        const at = start + sweep * 0.62;
        final dot = centre + Offset(math.cos(at), math.sin(at)) * r;
        // No fill: a ring encloses so much that a tint would outweigh it.
        return (null, [ring], dot);
      case ClarionGlyph.profile:
        final head = Path()
          ..addOval(
            Rect.fromCircle(center: const Offset(12, 8.4), radius: 3.9),
          );
        final shoulders = Path()
          ..moveTo(4.8, 20.2)
          ..cubicTo(5.6, 16.4, 8.6, 14.6, 12, 14.6)
          ..cubicTo(15.4, 14.6, 18.4, 16.4, 19.2, 20.2);
        return (head, [head, shoulders], const Offset(13.0, 7.7));
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.focus != focus ||
      old.focusColor != focusColor;
}
