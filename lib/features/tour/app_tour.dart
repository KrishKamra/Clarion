import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/clarion_button.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/tour_target.dart';
import '../cart/application/cart_controller.dart';
import '../home/application/intent_controller.dart';
import '../navigation/navigation_controller.dart';

/// Accent for a step's icon (resolved at build so it follows light/dark).
enum TourAccent { iris, emerald, amber }

/// Whether a step just explains something, or asks the user to tap it.
enum TourAction { info, tap }

/// How a tap step knows the tap "worked" before moving on.
enum TourWait { delay, cartAdd }

/// One step of the hands-on tour.
@immutable
class TourStep {
  const TourStep({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    this.target,
    this.tab,
    this.action = TourAction.info,
    this.instruction,
    this.cta,
    this.popToRoot = false,
    this.maxHole,
    this.scrollAlignment,
    this.wait = TourWait.delay,
    this.waitMs = 450,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final TourAccent accent;

  /// A widget (marked with `TourTargetBox`) to spotlight.
  final TourTarget? target;

  /// A navigation-capsule button to spotlight.
  final AppTab? tab;

  final TourAction action;

  /// What to tell the user to do, for [TourAction.tap] steps.
  final String? instruction;

  /// Label of the button on info steps (default "Next").
  final String? cta;

  /// Close any pushed screens (e.g. the product page) when this step begins.
  final bool popToRoot;

  /// Cap on the spotlight's height, for tall targets.
  final double? maxHole;

  /// If set, scroll the target into view (0 = top, 1 = bottom).
  final double? scrollAlignment;

  final TourWait wait;

  /// For [TourWait.delay]: how long to let the app react before moving on.
  final int waitMs;
}

/// The tour: the user taps each thing themselves, in the order a decision
/// flows through the app.
const List<TourStep> tourSteps = [
  TourStep(
    eyebrow: 'Welcome',
    title: 'A quick hands-on tour',
    body:
        'You will tap a few things yourself so you can see what each one '
        'does. It takes about a minute, and we will tidy up after.',
    icon: Icons.auto_awesome_rounded,
    accent: TourAccent.iris,
    cta: 'Begin tour',
    popToRoot: true,
  ),
  TourStep(
    eyebrow: 'Horizon',
    title: 'Start with a goal',
    body:
        'Clarion begins with what you want to do, not an endless feed. A goal '
        'can carry a price limit, like the ₹2.5k here, and everything below '
        'is re-ranked around it.',
    icon: Icons.blur_on_rounded,
    accent: TourAccent.iris,
    target: TourTarget.suggestion,
    action: TourAction.tap,
    instruction: 'Tap the highlighted goal',
    waitMs: 500,
  ),
  TourStep(
    eyebrow: 'Fit stream',
    title: 'Ranked for you',
    body:
        'Each pick has a Fit score out of 100 that blends your goal, your '
        'budget and the product itself. The best match comes first.',
    icon: Icons.stacked_bar_chart_rounded,
    accent: TourAccent.iris,
    target: TourTarget.firstProduct,
    action: TourAction.tap,
    instruction: 'Tap the top product to open it',
    scrollAlignment: 0.45,
    waitMs: 900,
  ),
  TourStep(
    eyebrow: 'Product page',
    title: 'Every point explained',
    body:
        'This ledger is the Fit score, line by line. Each reason adds or '
        'removes points and they sum exactly to the score, so nothing is a '
        'black box.',
    icon: Icons.fact_check_outlined,
    accent: TourAccent.iris,
    target: TourTarget.ledger,
    maxHole: 170,
    scrollAlignment: 0.12,
  ),
  TourStep(
    eyebrow: 'Cooling Off',
    title: 'Pause before you buy',
    body:
        'Press and hold this button to park a product for 24 hours. If the '
        'urge passes, you let it go and the money counts as saved. You can '
        'try it later.',
    icon: Icons.hourglass_bottom_rounded,
    accent: TourAccent.amber,
    target: TourTarget.coolOff,
  ),
  TourStep(
    eyebrow: 'Intent Cart',
    title: 'Add it to your cart',
    body:
        'This puts it in your Intent Cart, checked against your monthly '
        'ceiling. We will remove it again when the tour ends.',
    icon: Icons.add_shopping_cart_rounded,
    accent: TourAccent.iris,
    target: TourTarget.addToCart,
    action: TourAction.tap,
    instruction: 'Tap Add to Intent Cart',
    wait: TourWait.cartAdd,
  ),
  TourStep(
    eyebrow: 'Guardian',
    title: 'Open the Guardian',
    body:
        'Your cart sits against your ceiling here, on a bar that moves from '
        'Safe to Caution to Over. Go over and it suggests cheaper swaps.',
    icon: Icons.shield_rounded,
    accent: TourAccent.emerald,
    tab: AppTab.cart,
    action: TourAction.tap,
    instruction: 'Tap Guardian',
    popToRoot: true,
    waitMs: 400,
  ),
  TourStep(
    eyebrow: 'Compare',
    title: 'See only what differs',
    body:
        'Put two products head to head. Identical specs are hidden, each '
        'row names a winner, and starring a priority makes it count double.',
    icon: Icons.compare_arrows_rounded,
    accent: TourAccent.iris,
    tab: AppTab.compare,
    action: TourAction.tap,
    instruction: 'Tap Compare',
    waitMs: 400,
  ),
  TourStep(
    eyebrow: 'Profile',
    title: 'Your month at a glance',
    body:
        'Your ceiling ring, anything cooling off, a six-month trend and '
        'where the money went. You can change your ceiling, switch light or '
        'dark, and replay this tour here.',
    icon: Icons.donut_large_rounded,
    accent: TourAccent.iris,
    tab: AppTab.profile,
    action: TourAction.tap,
    instruction: 'Tap Profile',
    waitMs: 400,
  ),
  TourStep(
    eyebrow: 'Done',
    title: 'You are ready',
    body:
        'Set a goal, understand the fit, pause or add, and let the Guardian '
        'watch your ceiling. We will clear the sample item from your cart '
        'now.',
    icon: Icons.check_rounded,
    accent: TourAccent.emerald,
    cta: 'Start exploring',
  ),
];

/// Lets the tour close pushed screens (the product page) without needing a
/// global navigator key. `ClarionApp` registers it with its `MaterialApp`.
final tourNavigatorObserverProvider = Provider<NavigatorObserver>(
  (ref) => NavigatorObserver(),
);

/// The current tour step, or `null` when the tour is not running.
class AppTourController extends Notifier<int?> {
  Set<String> _cartAtStart = {};

  @override
  int? build() => null;

  void start() {
    _cartAtStart = {for (final i in ref.read(cartProvider)) i.productId};
    // Start from a clean Horizon so the goal suggestions are showing.
    ref.read(intentProvider.notifier).clear();
    ref.read(navigationProvider.notifier).select(AppTab.horizon);
    _go(0);
  }

  void next() {
    final i = state;
    if (i == null) return;
    i + 1 >= tourSteps.length ? finish() : _go(i + 1);
  }

  /// Ends the tour: tidies up anything it added and returns to Horizon.
  void finish() {
    final cart = ref.read(cartProvider.notifier);
    for (final item in [...ref.read(cartProvider)]) {
      if (!_cartAtStart.contains(item.productId)) cart.remove(item.productId);
    }
    ref.read(intentProvider.notifier).clear();
    state = null;
    _popToRoot();
    ref.read(navigationProvider.notifier).select(AppTab.horizon);
  }

  void _go(int index) {
    state = index;
    if (tourSteps[index].popToRoot) _popToRoot();
  }

  void _popToRoot() => ref
      .read(tourNavigatorObserverProvider)
      .navigator
      ?.popUntil((route) => route.isFirst);
}

final appTourProvider = NotifierProvider<AppTourController, int?>(
  AppTourController.new,
);

/// Sits above every screen (installed through `MaterialApp.builder`). Renders
/// nothing while the tour is not running.
class AppTourOverlay extends ConsumerWidget {
  const AppTourOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(appTourProvider);
    if (index == null) return const SizedBox.shrink();
    // Material gives the card text a proper default style; without an
    // ancestor Material, Flutter draws its yellow "missing Material" underline.
    return Material(
      type: MaterialType.transparency,
      child: _TourLayer(key: ValueKey(index), index: index),
    );
  }
}

class _TourLayer extends ConsumerStatefulWidget {
  const _TourLayer({super.key, required this.index});

  final int index;

  @override
  ConsumerState<_TourLayer> createState() => _TourLayerState();
}

class _TourLayerState extends ConsumerState<_TourLayer>
    with SingleTickerProviderStateMixin {
  static const _giveUp = Duration(milliseconds: 2500);
  static const _scrollDelay = Duration(milliseconds: 500);
  static const _capsuleInset = 5.0;

  late final Ticker _ticker;
  Duration _now = Duration.zero;
  Rect? _target;
  bool _scrolled = false;

  bool _waiting = false;
  Duration _waitStart = Duration.zero;
  int _cartAtHit = 0;

  TourStep get _step => tourSteps[widget.index];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    _now = elapsed;
    final step = _step;
    final id = step.target;

    if (id != null) {
      _target = TourTargets.rectOf(id);
      final align = step.scrollAlignment;
      if (_target != null &&
          align != null &&
          !_scrolled &&
          elapsed > _scrollDelay) {
        _scrolled = true;
        final context = TourTargets.contextOf(id);
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            alignment: align,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }

    if (_waiting) {
      final since = elapsed - _waitStart;
      final done = switch (step.wait) {
        TourWait.delay => since >= Duration(milliseconds: step.waitMs),
        TourWait.cartAdd =>
          ref.read(cartProvider).length > _cartAtHit &&
              since > const Duration(milliseconds: 300),
      };
      if (done) {
        ref.read(appTourProvider.notifier).next();
        return;
      }
      if (since > const Duration(seconds: 6)) _waiting = false; // try again
    }

    setState(() {});
  }

  /// The user tapped inside the spotlight; the app underneath handles the tap
  /// itself, we just wait for it to take effect.
  void _onHit() {
    if (_waiting) return;
    _waiting = true;
    _waitStart = _now;
    _cartAtHit = ref.read(cartProvider).length;
  }

  @override
  Widget build(BuildContext context) {
    final step = _step;
    final controller = ref.read(appTourProvider.notifier);
    final padding = MediaQuery.paddingOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final screen = Offset.zero & Size(w, h);
        final dim = AppColors.isDark
            ? const Color(0xC7000000)
            : const Color(0x990F172A);

        // ── What to spotlight ─────────────────────────────────────────────
        Rect? spot;
        var pill = false;
        if (step.tab != null) {
          // Mirrors FloatingNavCapsule's geometry.
          final slot =
              (w - AppSpacing.xxl * 2 - _capsuleInset * 2) /
              AppTab.values.length;
          final capsuleTop =
              h -
              AppSpacing.navBarMargin -
              padding.bottom -
              AppSpacing.navBarHeight;
          spot = Rect.fromLTWH(
            AppSpacing.xxl + _capsuleInset + slot * step.tab!.index,
            capsuleTop + _capsuleInset,
            slot,
            AppSpacing.navBarHeight - _capsuleInset * 2,
          );
          pill = true;
        } else if (step.target != null &&
            _target != null &&
            _target!.overlaps(screen)) {
          var r = _target!;
          final cap = step.maxHole;
          if (cap != null && r.height > cap) {
            r = Rect.fromLTWH(r.left, r.top, r.width, cap);
          }
          spot = r.inflate(6).intersect(screen);
        }

        final wantsTarget = step.target != null || step.tab != null;
        final searching = wantsTarget && spot == null && _now < _giveUp;
        final interactive = step.action == TourAction.tap && spot != null;

        // ── Brief states ──────────────────────────────────────────────────
        if (_waiting && step.wait == TourWait.cartAdd) {
          // Let the app (and its mindful-check sheet) run untouched.
          return const SizedBox.shrink();
        }
        if (_waiting || searching) {
          return Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: CustomPaint(
                  painter: _ScrimPainter(
                    color: dim,
                    hole: _waiting ? spot : null,
                    pill: pill,
                  ),
                ),
              ),
              const Positioned.fill(child: _Block()),
            ],
          );
        }

        // ── The scrim, with the spotlight cut out ─────────────────────────
        final children = <Widget>[
          IgnorePointer(
            child: CustomPaint(
              painter: _ScrimPainter(color: dim, hole: spot, pill: pill),
            ),
          ),
        ];
        if (spot == null) {
          children.add(const Positioned.fill(child: _Block()));
        } else {
          final hole = spot;
          children.addAll([
            Positioned.fromRect(
              rect: Rect.fromLTRB(0, 0, w, hole.top),
              child: const _Block(),
            ),
            Positioned.fromRect(
              rect: Rect.fromLTRB(0, hole.bottom, w, h),
              child: const _Block(),
            ),
            Positioned.fromRect(
              rect: Rect.fromLTRB(0, hole.top, hole.left, hole.bottom),
              child: const _Block(),
            ),
            Positioned.fromRect(
              rect: Rect.fromLTRB(hole.right, hole.top, w, hole.bottom),
              child: const _Block(),
            ),
            Positioned.fromRect(
              rect: hole,
              child: IgnorePointer(
                child: _GlowRing(phase: _now.inMilliseconds / 260, pill: pill),
              ),
            ),
            // Inside the spotlight: tap steps let the touch through to the
            // real control (the Listener only observes); info steps block it.
            Positioned.fromRect(
              rect: hole,
              child: interactive
                  ? Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerUp: (_) => _onHit(),
                      child: const SizedBox.expand(),
                    )
                  : const _Block(),
            ),
          ]);
        }

        // ── The card ──────────────────────────────────────────────────────
        final card = TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.fast,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 10),
              child: child,
            ),
          ),
          child: _TourCard(
            step: step,
            index: widget.index,
            interactive: interactive,
            onNext: controller.next,
            onSkip: controller.finish,
          ),
        );

        const gutter = AppSpacing.gutter;
        const need = 300.0;
        if (spot == null) {
          children.add(
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  padding.top + AppSpacing.xxl,
                  gutter,
                  padding.bottom + AppSpacing.xxl,
                ),
                child: Center(child: SingleChildScrollView(child: card)),
              ),
            ),
          );
        } else {
          final below = h - spot.bottom - padding.bottom;
          final above = spot.top - padding.top;
          final placeBelow = below >= need || (above < need && below >= above);
          children.add(
            placeBelow
                ? Positioned(
                    left: gutter,
                    right: gutter,
                    top: spot.bottom + AppSpacing.lg,
                    bottom: padding.bottom + AppSpacing.sm,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(child: card),
                    ),
                  )
                : Positioned(
                    left: gutter,
                    right: gutter,
                    top: padding.top + AppSpacing.sm,
                    bottom: h - spot.top + AppSpacing.lg,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(reverse: true, child: card),
                    ),
                  ),
          );
        }

        return Stack(fit: StackFit.expand, children: children);
      },
    );
  }
}

/// Swallows touches so the app underneath can't be used mid-tour.
class _Block extends StatelessWidget {
  const _Block();

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {},
    child: const SizedBox.expand(),
  );
}

class _ScrimPainter extends CustomPainter {
  const _ScrimPainter({
    required this.color,
    required this.hole,
    required this.pill,
  });

  final Color color;
  final Rect? hole;
  final bool pill;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()..addRect(Offset.zero & size);
    final h = hole;
    if (h != null) {
      final radius = Radius.circular(pill ? h.height / 2 : AppRadii.lg);
      path = Path.combine(
        PathOperation.difference,
        path,
        Path()..addRRect(RRect.fromRectAndRadius(h, radius)),
      );
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.color != color || old.hole != hole || old.pill != pill;
}

/// A softly pulsing ring that marks the thing to tap.
class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.phase, required this.pill});

  final double phase;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.5 + 0.5 * math.sin(phase);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: pill ? AppRadii.pillAll : AppRadii.lgAll,
        border: Border.all(
          color: AppColors.irisGlow.withValues(alpha: 0.65 + 0.35 * pulse),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.irisGlow.withValues(alpha: 0.25 + 0.3 * pulse),
            blurRadius: 14 + 8 * pulse,
          ),
        ],
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.index,
    required this.interactive,
    required this.onNext,
    required this.onSkip,
  });

  final TourStep step;
  final int index;

  /// Waiting for the user to tap the highlighted control.
  final bool interactive;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  Color get _accent => switch (step.accent) {
    TourAccent.iris => AppColors.irisGlow,
    TourAccent.emerald => AppColors.emeraldGlow,
    TourAccent.amber => AppColors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final last = index == tourSteps.length - 1;
    final accent = _accent;

    final skip = Pressable(
      onTap: onSkip,
      semanticLabel: 'Skip tour',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Text(
          'Skip',
          style: AppTypography.label.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.rimBright),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Icon(step.icon, color: accent, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1} / ${tourSteps.length} · '
                              '${step.eyebrow}'
                          .toUpperCase(),
                      style: AppTypography.overline,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(step.title, style: AppTypography.titleSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(step.body, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < tourSteps.length; i++) ...[
                AnimatedContainer(
                  duration: AppMotion.fast,
                  width: i == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index ? accent : AppColors.rimBright,
                    borderRadius: AppRadii.pillAll,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (interactive) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: AppRadii.mdAll,
                border: Border.all(color: accent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: accent, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      step.instruction ?? 'Tap the highlighted control',
                      style: AppTypography.label,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(alignment: Alignment.centerLeft, child: skip),
          ] else
            Row(
              children: [
                if (!last) ...[skip, const SizedBox(width: AppSpacing.xs)],
                Expanded(
                  child: ClarionButton(
                    label: step.cta ?? 'Next',
                    height: 44,
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
