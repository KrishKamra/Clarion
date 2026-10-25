import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Tactile press behaviour shared by every custom control: a short settle
/// downward in scale and a light haptic tick on commit; on pointer devices, a
/// click cursor and a slight lift on hover.
///
/// Calmer than an ink ripple on dark surfaces, and it makes cards, capsules
/// and buttons feel like one physical family.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.98,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  /// Android's minimum touch target. Small controls (pills, steppers, text
  /// links) get a hit area this size; what they draw is unchanged.
  static const double minTarget = 48;

  /// Hover and press state of the nearest enclosing [Pressable], so a
  /// surface can answer with a glow without owning its own gestures.
  static ({bool hovered, bool pressed}) stateOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PressScope>();
    return (hovered: scope?.hovered ?? false, pressed: scope?.pressed ?? false);
  }

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  bool _hover = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    // One node per control, so it never merges with the text around it. A
    // label, when given, is what a screen reader says instead of the
    // child's text, not as well.
    return Semantics(
      container: true,
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _set(false);
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedScale(
            // Hover lifts by 60 % of the press depth, so the two read as one
            // continuous gesture.
            scale: _down
                ? widget.scale
                : _hover
                ? 1 + (1 - widget.scale) * 0.6
                : 1,
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            child: _PressScope(
              hovered: _hover,
              pressed: _down,
              child: _MinTapTarget(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gives a small control a [Pressable.minTarget] hit area, centred on what
/// it draws. Unlike `Align`, the child keeps its parent's constraints, so a
/// control stretched to full width stays full width.
class _MinTapTarget extends SingleChildRenderObjectWidget {
  const _MinTapTarget({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMinTapTarget();
}

class _RenderMinTapTarget extends RenderShiftedBox {
  _RenderMinTapTarget() : super(null);

  @override
  void performLayout() {
    final child = this.child!..layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(
        math.max(child.size.width, Pressable.minTarget),
        math.max(child.size.height, Pressable.minTarget),
      ),
    );
    (child.parentData! as BoxParentData).offset = Alignment.center.alongOffset(
      size - child.size as Offset,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), Pressable.minTarget);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(super.computeMaxIntrinsicWidth(height), Pressable.minTarget);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), Pressable.minTarget);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(super.computeMaxIntrinsicHeight(width), Pressable.minTarget);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child!.getDryLayout(constraints);
    return constraints.constrain(
      Size(
        math.max(child.width, Pressable.minTarget),
        math.max(child.height, Pressable.minTarget),
      ),
    );
  }

  /// A touch in the padding around the child still counts as a tap.
  @override
  bool hitTestSelf(Offset position) => true;
}

class _PressScope extends InheritedWidget {
  const _PressScope({
    required this.hovered,
    required this.pressed,
    required super.child,
  });

  final bool hovered;
  final bool pressed;

  @override
  bool updateShouldNotify(_PressScope old) =>
      old.hovered != hovered || old.pressed != pressed;
}

/// A soft coloured glow beneath a surface inside a [Pressable]: [rest] when
/// idle, blooming on hover and drawing in tight on press — light leaking
/// from under a pane of glass.
class PressGlow extends StatelessWidget {
  const PressGlow({
    super.key,
    required this.color,
    required this.borderRadius,
    required this.child,
    this.rest = 0,
  });

  final Color color;
  final BorderRadius borderRadius;
  final Widget child;

  /// Glow opacity at rest (0–1). Solid actions keep a little; cards none.
  final double rest;

  @override
  Widget build(BuildContext context) {
    final (:hovered, :pressed) = Pressable.stateOf(context);
    final strength = pressed
        ? rest * 0.6 + 0.1
        : hovered
        ? rest + 0.4
        : rest;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: strength * (AppColors.isDark ? 1 : 0.7),
            ),
            blurRadius: pressed ? 16 : 36,
            spreadRadius: -8,
            offset: Offset(0, pressed ? 4 : 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
