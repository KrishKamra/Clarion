import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/feedback/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/locale_controller.dart';
import '../../core/widgets/obsidian_canvas.dart';
import '../../l10n/app_localizations.dart';

/// What the launch is still waiting on. The filament under the name tracks
/// these honestly — it never runs ahead of the work.
enum BootStage {
  /// Firebase has not yet said who is signed in.
  starting,

  /// Signed in; the account's database is opening.
  opening,

  /// Everything the first screen needs is loaded.
  ready,
}

/// Cold-start arrival: the lens pulls focus.
///
/// It opens on exactly what the native splash shows — the lens alone on the
/// canvas — so the hand-off is invisible. Then three focus rings converge
/// and lock onto the lens, a glint runs round the rim, the lens rises and
/// the name tracks in beneath it under a sweep of light. A hairline filament
/// reports real progress through [stage].
///
/// When the app is [BootStage.ready] (and the arrival has played) the lens
/// opens like an aperture: a hole grows from its centre and the app is seen
/// through it, then [onDone] removes the splash. Under reduced motion it
/// shows the settled lockup and simply fades.
///
/// It sits above `MaterialApp`, so it brings its own [Directionality] and
/// looks up strings directly rather than through `context.l10n`.
class ClarionSplash extends StatefulWidget {
  const ClarionSplash({super.key, required this.stage, required this.onDone});

  final BootStage stage;
  final VoidCallback onDone;

  @override
  State<ClarionSplash> createState() => _ClarionSplashState();
}

class _ClarionSplashState extends State<ClarionSplash>
    with TickerProviderStateMixin {
  late final AnimationController _arrival = AnimationController(
    vsync: this,
    duration: AppMotion.arrival,
  )..addListener(_onArrivalTick);

  /// Displayed progress, eased toward the stage's target.
  late final AnimationController _progress = AnimationController(vsync: this);

  /// Light travelling along the filament while there is work to wait on.
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: AppMotion.arrival,
  );

  late final AnimationController _aperture = AnimationController(
    vsync: this,
    duration: AppMotion.aperture,
  );

  bool _reduced = false;
  bool _locked = false;
  bool _exiting = false;

  /// The moment the converging rings meet the lens.
  static const _lockAt = 0.34;

  static double _target(BootStage stage) => switch (stage) {
    BootStage.starting => 0.3,
    BootStage.opening => 0.72,
    BootStage.ready => 1,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _arrival.value = 1;
      _shimmer.stop();
    } else {
      if (_arrival.isDismissed) _arrival.forward().then((_) => _maybeExit());
      if (!_shimmer.isAnimating) _shimmer.repeat();
    }
    _advance();
    _maybeExit();
  }

  @override
  void didUpdateWidget(ClarionSplash old) {
    super.didUpdateWidget(old);
    if (old.stage != widget.stage) {
      _advance();
      _maybeExit();
    }
  }

  @override
  void dispose() {
    _arrival.dispose();
    _progress.dispose();
    _shimmer.dispose();
    _aperture.dispose();
    super.dispose();
  }

  void _onArrivalTick() {
    if (_locked || _arrival.value < _lockAt) return;
    _locked = true;
    AppHaptics.select();
  }

  void _advance() {
    final target = _target(widget.stage);
    if (_progress.value >= target) return;
    _progress.animateTo(
      target,
      duration: _reduced ? Duration.zero : AppMotion.reveal,
      curve: AppMotion.standard,
    );
  }

  Future<void> _maybeExit() async {
    if (_exiting || widget.stage != BootStage.ready) return;
    if (!_arrival.isCompleted) return;
    _exiting = true;
    // Let the filament visibly finish before the lens opens.
    if (!_reduced) {
      await _progress.animateTo(
        1,
        duration: AppMotion.medium,
        curve: AppMotion.standard,
      );
    }
    _shimmer.stop();
    if (!mounted) return;
    await _aperture.animateTo(
      1,
      duration: _reduced ? AppMotion.fast : AppMotion.aperture,
    );
    if (mounted) widget.onDone();
  }

  AppLocalizations get _strings {
    final locale =
        LocaleController.saved ??
        WidgetsBinding.instance.platformDispatcher.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    return lookupAppLocalizations(supported ? locale : const Locale('en'));
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Semantics(
        label: strings.splashSemantics,
        liveRegion: true,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _arrival,
            _progress,
            _shimmer,
            _aperture,
          ]),
          builder: (context, _) => LayoutBuilder(
            builder: (context, box) => _frame(box.biggest, strings),
          ),
        ),
      ),
    );
  }

  Widget _frame(Size size, AppLocalizations strings) {
    final t = _arrival.value;
    final exit = _aperture.value;
    double phase(double a, double b, [Curve curve = AppMotion.standard]) =>
        curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

    // The lens starts at the native splash's size and place, then rises to
    // sit above the name as one centred lockup.
    const startLens = 88.0;
    const endLens = 76.0;
    final rise = phase(0.36, 0.78, Curves.easeInOutCubic);
    final lens = ui.lerpDouble(startLens, endLens, rise)!;
    final centre = size.center(Offset(0, -84 * rise));

    // Exit: the lens's own ring becomes the aperture. The iris opens inside
    // it first, then the ring sweeps out past the corners of the screen.
    // Ring geometry matches the SVG (r 26, stroke 4.5 on a 64 grid), so the
    // painted ring lands exactly on the drawn one.
    final ringR0 = lens / 2 * (26 / 32);
    final ringW0 = lens * (4.5 / 64);
    final farthest = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((c) => (c - centre).distance).reduce(math.max);
    final open = Curves.easeInCubic.transform(exit);
    final ringR = ui.lerpDouble(ringR0, farthest + ringW0 * 4, open)!;
    final ringW = ringW0 * (1 + 2 * exit);
    final iris = Curves.easeOutCubic.transform((exit / 0.28).clamp(0.0, 1.0));
    final hole = _reduced ? 0.0 : (ringR - ringW / 2) * iris;
    final lensScale = _reduced ? 1.0 : ringR / ringR0;
    final fadeOut = _reduced
        ? 1 - exit
        : 1 - Curves.easeOut.transform((exit / 0.4).clamp(0.0, 1.0));

    final word = phase(0.5, 0.88);
    final tagline = phase(0.66, 0.94);
    final filament = phase(0.74, 1);

    final splash = Stack(
      fit: StackFit.expand,
      children: [
        const ObsidianCanvas(glowIntensity: 0, child: SizedBox.expand()),
        // Light gathers behind the lens as it locks focus.
        Positioned.fromRect(
          rect: Rect.fromCircle(center: centre, radius: size.shortestSide),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppDecorations.backlight(
                AppColors.iris,
                intensity: 0.22 * phase(0.2, 0.7),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _FocusPainter(
              centre: centre,
              lensRadius: lens / 2,
              arrival: t,
              lockAt: _lockAt,
            ),
          ),
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: centre,
            width: lens * lensScale,
            height: lens * lensScale,
          ),
          // Hands the ring over to the aperture rim as the iris opens.
          child: Opacity(
            opacity: _reduced ? 1 : 1 - iris,
            child: SvgPicture.asset('assets/brand/clarion_logo.svg'),
          ),
        ),
        Positioned(
          left: AppSpacing.gutter,
          right: AppSpacing.gutter,
          top: centre.dy + endLens / 2 + AppSpacing.xxl,
          child: Opacity(
            opacity: fadeOut,
            child: Column(
              children: [
                _Name(progress: word),
                const SizedBox(height: AppSpacing.sm),
                Opacity(
                  opacity: tagline,
                  child: Transform.translate(
                    offset: Offset(0, 6 * (1 - tagline)),
                    child: Text(
                      strings.splashTagline,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                Opacity(
                  opacity: filament,
                  child: _Filament(
                    progress: _progress.value,
                    shimmer: _shimmer.value,
                    status: switch (widget.stage) {
                      BootStage.starting => strings.splashStarting,
                      BootStage.opening => strings.splashOpening,
                      BootStage.ready => strings.splashReady,
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return IgnorePointer(
      ignoring: exit > 0,
      child: Opacity(
        opacity: _reduced ? 1 - exit : 1,
        child: _reduced || exit == 0
            ? splash
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipPath(
                    clipper: _ApertureClipper(centre, hole),
                    child: splash,
                  ),
                  CustomPaint(
                    painter: _ApertureRimPainter(
                      centre: centre,
                      radius: ringR,
                      strokeWidth: ringW,
                      opacity:
                          1 -
                          Curves.easeIn.transform(
                            ((exit - 0.55) / 0.45).clamp(0.0, 1.0),
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// "Clarion", tracking in from wide to the lockup's tight setting while a
/// band of light sweeps across it left to right.
class _Name extends StatelessWidget {
  const _Name({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    final style = AppTypography.display.copyWith(
      fontSize: size,
      height: 1,
      letterSpacing: ui.lerpDouble(size * 0.28, -size * 0.035, progress),
    );
    // Mask: revealed on the left, a bright leading edge, hidden beyond.
    final edge = progress * 1.3 - 0.15;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: const [Colors.white, Colors.white, Colors.transparent],
        stops: [0, edge.clamp(0.0, 1.0), (edge + 0.15).clamp(0.0, 1.0)],
      ).createShader(bounds),
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.irisGlow.withValues(alpha: 0.9 * (1 - progress)),
            Colors.transparent,
          ],
          stops: [
            (edge - 0.12).clamp(0.0, 1.0),
            edge.clamp(0.0, 1.0),
            (edge + 0.12).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: Text(
          'Clarion',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: style,
        ),
      ),
    );
  }
}

/// A hairline that fills iris to emerald with the real boot progress, with
/// a mote of light running along it while there is still work to wait on,
/// and the current step beneath in the instrument-panel mono.
class _Filament extends StatelessWidget {
  const _Filament({
    required this.progress,
    required this.shimmer,
    required this.status,
  });

  final double progress;
  final double shimmer;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 132,
          height: 2,
          child: CustomPaint(
            painter: _FilamentPainter(progress: progress, shimmer: shimmer),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedSwitcher(
          duration: AppMotion.fast,
          switchInCurve: AppMotion.standard,
          child: Text(
            status.toUpperCase(),
            key: ValueKey(status),
            style: AppTypography.overline,
          ),
        ),
      ],
    );
  }
}

class _FilamentPainter extends CustomPainter {
  _FilamentPainter({required this.progress, required this.shimmer});

  final double progress;
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final track = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(track, Paint()..color = AppColors.hairline);

    final filled = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    if (filled.width <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(filled, radius),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, 0), [
          AppColors.irisGlow,
          AppColors.emeraldGlow,
        ]),
    );

    if (progress >= 1) return;
    final x = filled.width * shimmer;
    final glint = Rect.fromCenter(
      center: Offset(x, size.height / 2),
      width: 28,
      height: size.height,
    );
    canvas
      ..save()
      ..clipRRect(RRect.fromRectAndRadius(filled, radius))
      ..drawRect(
        glint,
        Paint()
          ..shader = ui.Gradient.linear(
            glint.centerLeft,
            glint.centerRight,
            [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.8),
              Colors.transparent,
            ],
            const [0, 0.5, 1],
          ),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_FilamentPainter old) =>
      old.progress != progress || old.shimmer != shimmer;
}

/// Three hairline focus rings that converge on the lens and vanish as they
/// lock, then a glint that runs once round the rim.
class _FocusPainter extends CustomPainter {
  _FocusPainter({
    required this.centre,
    required this.lensRadius,
    required this.arrival,
    required this.lockAt,
  });

  final Offset centre;
  final double lensRadius;
  final double arrival;
  final double lockAt;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final start = i * 0.07;
      final p = ((arrival - start) / (lockAt - start)).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final eased = Curves.easeOutCubic.transform(p);
      final r = lensRadius * (3.2 - 2.2 * eased) + i * 6 * (1 - eased);
      // Fades in, then out as the ring meets the rim.
      final alpha = math.sin(p * math.pi) * (0.42 - i * 0.1);
      canvas.drawCircle(
        centre,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = SweepGradient(
            colors: [
              AppColors.irisGlow.withValues(alpha: alpha),
              AppColors.emeraldGlow.withValues(alpha: alpha),
              AppColors.irisGlow.withValues(alpha: alpha),
            ],
            transform: GradientRotation(i * 1.3),
          ).createShader(Rect.fromCircle(center: centre, radius: r)),
      );
    }

    // Glint: a short bright arc running round the rim after the lock.
    final g = ((arrival - lockAt) / 0.32).clamp(0.0, 1.0);
    if (g <= 0 || g >= 1) return;
    final eased = Curves.easeInOutCubic.transform(g);
    final rim = lensRadius * (26 / 32);
    final start = -math.pi * 0.75 + eased * math.pi * 2;
    final rect = Rect.fromCircle(center: centre, radius: rim);
    canvas.drawArc(
      rect,
      start,
      0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = lensRadius * 0.08
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + 0.9,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.85 * math.sin(g * math.pi)),
          ],
          tileMode: TileMode.clamp,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FocusPainter old) =>
      old.arrival != arrival ||
      old.centre != centre ||
      old.lensRadius != lensRadius;
}

/// Everything except a circle: the splash with the aperture cut out of it.
class _ApertureClipper extends CustomClipper<Path> {
  _ApertureClipper(this.centre, this.radius);

  final Offset centre;
  final double radius;

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addOval(Rect.fromCircle(center: centre, radius: radius));

  @override
  bool shouldReclip(_ApertureClipper old) =>
      old.centre != centre || old.radius != radius;
}

/// The lens's iris-to-emerald ring, carried out as the edge of the aperture.
class _ApertureRimPainter extends CustomPainter {
  _ApertureRimPainter({
    required this.centre,
    required this.radius,
    required this.strokeWidth,
    required this.opacity,
  });

  final Offset centre;
  final double radius;
  final double strokeWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: centre, radius: radius);
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            for (final c in AppColors.lensRing) c.withValues(alpha: opacity),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ApertureRimPainter old) =>
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.opacity != opacity ||
      old.centre != centre;
}
