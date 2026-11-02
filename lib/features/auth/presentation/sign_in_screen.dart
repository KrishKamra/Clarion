import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/feedback/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/aurora_backdrop.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_wordmark.dart';
import '../../../core/widgets/frosted_chrome.dart';
import '../../../core/widgets/pressable.dart';
import '../application/auth_service.dart';

/// Arrival: the brand lockup framed by its tagline, three promises, and a
/// frosted sign-in pane floating in a still light from above.
///
/// `AuthGate` swaps to the app as soon as Firebase reports a user, so this
/// screen never navigates on success.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  /// Staggers the lockup, promises, pane and footer in on arrival.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// A short, damped head-shake of the pane when something is wrong.
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _entrance.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _fail(String message) {
    setState(() => _error = message);
    AppHaptics.warn();
    _shake.forward(from: 0);
  }

  Future<void> _run(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) _fail(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@') || password.isEmpty) {
      _fail('Enter your email and password.');
      return;
    }
    _run(
      () => _creating
          ? AuthService.register(email, password)
          : AuthService.signIn(email, password),
    );
  }

  void _resetPassword() {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      _fail('Enter your email first.');
      return;
    }
    _run(() async {
      await AuthService.sendPasswordReset(email);
      if (mounted) setState(() => _notice = 'Reset link sent to $email.');
    });
  }

  void _setMode(bool creating) {
    if (creating == _creating) return;
    setState(() {
      _creating = creating;
      _error = _notice = null;
    });
  }

  /// Fades and rises [child] in during [start]–[end] of the entrance.
  Widget _reveal(double start, double end, Widget child) {
    final curve = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: AppMotion.standard),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
                vertical: AppSpacing.xxl,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _reveal(0, 0.55, const _Lockup()),
                    const SizedBox(height: AppSpacing.xl),
                    _reveal(0.15, 0.7, const _Promises()),
                    const SizedBox(height: AppSpacing.xxl),
                    _reveal(
                      0.3,
                      0.9,
                      AnimatedBuilder(
                        animation: _shake,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            math.sin(_shake.value * math.pi * 5) *
                                10 *
                                (1 - _shake.value),
                            0,
                          ),
                          child: child,
                        ),
                        child: _pane(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _reveal(
                      0.5,
                      1,
                      Text(
                        'No feeds. No dark patterns. Just better decisions.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pane() {
    final message = _error ?? _notice;
    return FrostedChrome(
      borderRadius: AppRadii.xlAll,
      sigma: 30,
      // No contact shadow: through translucent glass it reads as a grey
      // band, and the rim already defines the pane's edge.
      fill: AppColors.surface.withValues(alpha: AppColors.isDark ? 0.55 : 0.62),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModeSwitch(creating: _creating, onChanged: _setMode),
              const SizedBox(height: AppSpacing.xl),
              AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.standard,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...previous, ?current],
                ),
                child: Column(
                  key: ValueKey(_creating),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _creating ? 'Start deciding better' : 'Welcome back',
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _creating
                          ? 'Your cart, budget and holds stay with your '
                                'account.'
                          : 'Pick up right where you left off.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _GlassField(
                controller: _email,
                hint: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              _GlassField(
                controller: _password,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                autofillHints: [
                  _creating
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: AppMotion.standard,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_creating)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _Link(
                          label: 'Forgot password?',
                          onTap: _busy ? null : _resetPassword,
                        ),
                      ),
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: _Message(text: message, isError: _error != null),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ClarionButton(
                label: _creating ? 'Create account' : 'Continue',
                isLoading: _busy,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _OrDivider(),
              const SizedBox(height: AppSpacing.lg),
              ClarionButton(
                label: 'Continue with Google',
                tone: ButtonTone.secondary,
                leading: const _GoogleMark(),
                onPressed: _busy
                    ? null
                    : () => _run(AuthService.signInWithGoogle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tagline wraps the name: intent above, its outcome — in the brand
/// gradient — below, with the lens breathing in a pool of plum light.
class _Lockup extends StatefulWidget {
  const _Lockup();

  @override
  State<_Lockup> createState() => _LockupState();
}

class _LockupState extends State<_Lockup> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breath.value = 0.5;
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox.square(
          dimension: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _breath,
                builder: (context, _) => Transform.scale(
                  scale: 0.85 + 0.2 * Curves.easeInOut.transform(_breath.value),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppDecorations.backlight(
                        AppColors.action,
                        intensity: AppColors.isDark ? 0.42 : 0.3,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const ClarionWordmark(size: 46, showName: false),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'CLEAR INTENT.',
          style: AppTypography.overline.copyWith(
            letterSpacing: 3.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const ClarionName(fontSize: 46),
        const SizedBox(height: AppSpacing.sm),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppColors.action,
              AppColors.isDark ? AppColors.champagne : AppColors.actionLit,
            ],
          ).createShader(bounds),
          child: Text(
            'Conscious Commerce.',
            style: AppTypography.title.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Three promises as one quiet line. On the threshold of the app nothing is
/// a warning yet, so no accent colour is spent here.
class _Promises extends StatelessWidget {
  const _Promises();

  @override
  Widget build(BuildContext context) {
    final dot = Text(
      '  ·  ',
      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
    );
    final style = AppTypography.caption.copyWith(
      color: AppColors.textSecondary,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: AppSpacing.xs,
      children: [
        Text('Fit you can see', style: style),
        dot,
        Text('A budget that guards', style: style),
        dot,
        Text('Time to think', style: style),
      ],
    );
  }
}

/// Sign in / Sign up, with a plum pill that glides between the halves.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.creating, required this.onChanged});

  final bool creating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget half(String label, bool value) => Expanded(
      child: Pressable(
        haptic: false,
        semanticLabel: label,
        onTap: () {
          AppHaptics.select();
          onChanged(value);
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.medium,
            style: AppTypography.label.copyWith(
              fontWeight: FontWeight.w600,
              color: creating == value
                  ? AppColors.onAction
                  : AppColors.textSecondary,
            ),
            child: Text(label),
          ),
        ),
      ),
    );

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: AppDecorations.vellum(borderRadius: AppRadii.pillAll),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: AppMotion.slow,
            curve: AppMotion.emphasized,
            alignment: creating ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.pillAll,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.actionLit, AppColors.action],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.action.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(children: [half('Sign in', false), half('Sign up', true)]),
        ],
      ),
    );
  }
}

/// A vellum input that lights a plum edge and halo while focused, and
/// brightens its edge under a hovering pointer.
class _GlassField extends StatefulWidget {
  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.autofillHints,
    required this.textInputAction,
    this.keyboardType,
    this.obscure = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final List<String> autofillHints;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  final _focus = FocusNode();
  bool _hover = false;
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final accent = focused ? AppColors.action : AppColors.textTertiary;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        padding: const EdgeInsets.only(left: AppSpacing.lg, right: 6),
        decoration: BoxDecoration(
          color: AppColors.vellumActive,
          borderRadius: AppRadii.mdAll,
          border: Border.all(
            color: focused
                ? AppColors.action.withValues(alpha: 0.75)
                : _hover
                ? AppColors.rimBright
                : AppColors.hairline,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.action.withValues(alpha: focused ? 0.28 : 0),
              blurRadius: 20,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 19, color: accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                obscureText: _hidden,
                autocorrect: false,
                enableSuggestions: !widget.obscure,
                keyboardType: widget.keyboardType,
                autofillHints: widget.autofillHints,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (widget.obscure)
              Pressable(
                haptic: false,
                semanticLabel: _hidden ? 'Show password' : 'Hide password',
                onTap: () => setState(() => _hidden = !_hidden),
                child: SizedBox.square(
                  dimension: 40,
                  child: AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      key: ValueKey(_hidden),
                      size: 19,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.over : AppColors.good;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('OR', style: AppTypography.overline),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Google's "G" in its four colours, for the Google button.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  /// Google's four-colour "G", as its sign-in guidelines ask: drawn from
  /// vectors in a square, never typed, so it centres on the label and
  /// doesn't change with the app's fonts.
  static const _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>'
      '<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>'
      '<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>'
      '<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: 18, height: 18);
  }
}

/// A plum text action that underlines under a hovering pointer.
class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: Builder(
        builder: (context) {
          final hovered = Pressable.stateOf(context).hovered;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              label,
              style: AppTypography.label.copyWith(
                color: AppColors.action,
                decoration: hovered
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: AppColors.action,
              ),
            ),
          );
        },
      ),
    );
  }
}
