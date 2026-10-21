import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'progress_ring.dart';

/// Friction-by-design: an action that only commits after a deliberate,
/// sustained press.
///
/// While held, a warm fill sweeps across the button and a micro-progress
/// ring with a live mono timer counts down to commit. Letting go early
/// drains it back. Screen-reader users get the action directly via the
/// semantic tap, since a timed hold is not an accessible gesture.
class HoldButton extends StatefulWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.hint = 'Hold to delay',
    this.color = AppColors.rose,
    this.duration = const Duration(milliseconds: 1200),
    this.height = 52,
  });

  final String label;

  /// Second line at rest; replaced by the countdown while held.
  final String hint;
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
    if (_progress.status == AnimationStatus.forward) _progress.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const radius = AppRadii.mdAll;
    final seconds = widget.duration.inMilliseconds / 1000;

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
                  final remaining = (seconds * (1 - t)).clamp(0, seconds);
                  return Container(
                    height: widget.height,
                    color: AppColors.vellumActive,
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: t,
                          heightFactor: 1,
                          child: ColoredBox(
                            color: widget.color.withValues(alpha: 0.2),
                          ),
                        ),
                        Center(
                          child: _Face(
                            label: widget.label,
                            detail: holding
                                ? 'Keep holding · ${remaining.toStringAsFixed(1)}s'
                                : widget.hint,
                            progress: t,
                            color: holding
                                ? widget.color
                                : AppColors.textPrimary,
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

class _Face extends StatelessWidget {
  const _Face({
    required this.label,
    required this.detail,
    required this.progress,
    required this.color,
  });

  final String label;
  final String detail;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          progress > 0
              ? ProgressRing(
                  value: progress,
                  color: color,
                  size: 16,
                  strokeWidth: 2,
                  animate: false,
                )
              : Icon(Icons.hourglass_empty_rounded, size: 16, color: color),
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
                Text(
                  detail,
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
