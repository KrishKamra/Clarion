import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Friction-by-design: an action that only commits after a deliberate,
/// sustained press.
///
/// A warm fill sweeps across the button while held; letting go early drains
/// it back. Screen-reader users get the action directly via the semantic
/// tap, since a timed hold is not an accessible gesture.
class HoldButton extends StatefulWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.holdingLabel = 'Keep holding…',
    this.subtitle,
    this.color = AppColors.amber,
    this.duration = const Duration(milliseconds: 1100),
    this.height = 52,
  });

  final String label;
  final String holdingLabel;
  final String? subtitle;
  final VoidCallback? onConfirmed;
  final Color color;
  final Duration duration;
  final double height;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: AppMotion.slow,
  )..addStatusListener(_onStatus);

  bool get _enabled => widget.onConfirmed != null;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.mediumImpact();
    widget.onConfirmed?.call();
    _progress.value = 0;
  }

  void _start() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
    _progress.forward();
  }

  void _cancel() {
    if (_progress.isAnimating && _progress.status == AnimationStatus.forward) {
      _progress.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const radius = AppRadii.mdAll;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: '${widget.label}. Press and hold to confirm.',
      excludeSemantics: true,
      onTap: widget.onConfirmed,
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: AnimatedOpacity(
          opacity: _enabled ? 1 : 0.4,
          duration: AppMotion.fast,
          child: CustomPaint(
            foregroundPainter: const RimLightPainter(borderRadius: radius),
            child: ClipRRect(
              borderRadius: radius,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final t = _progress.value;
                  final holding = t > 0;
                  return Container(
                    height: widget.height,
                    color: AppColors.vellumActive,
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: t,
                          heightFactor: 1,
                          child: ColoredBox(
                            color: widget.color.withValues(alpha: 0.22),
                          ),
                        ),
                        Center(
                          child: Transform.scale(
                            scale: 1 - 0.03 * t,
                            child: _Label(
                              label: holding
                                  ? widget.holdingLabel
                                  : widget.label,
                              subtitle: widget.subtitle,
                              color: holding
                                  ? widget.color
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, required this.color, this.subtitle});

  final String label;
  final String? subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty_rounded, size: 17, color: color),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.metricSmall.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
