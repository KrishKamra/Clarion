import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_wordmark.dart';
import '../../../core/widgets/obsidian_canvas.dart';
import '../../../core/widgets/pressable.dart';
import '../application/auth_service.dart';

/// Email/password and Google sign-in. `AuthGate` swaps to the app as soon as
/// Firebase reports a user, so this screen never navigates on success.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@') || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
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
      setState(() => _error = 'Enter your email first.');
      return;
    }
    _run(() async {
      await AuthService.sendPasswordReset(email);
      if (mounted) setState(() => _notice = 'Reset link sent to $email.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = _error ?? _notice;

    return ObsidianCanvas(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: ClarionWordmark(size: 28),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    Text(
                      _creating ? 'Create your account' : 'Welcome back',
                      style: AppTypography.display,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your cart, budget and cooling-off holds stay with '
                      'your account.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _Field(
                      controller: _email,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _password,
                      hint: 'Password',
                      obscure: true,
                      autofillHints: [
                        _creating
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        message,
                        style: AppTypography.caption.copyWith(
                          color: _error != null
                              ? AppColors.rose
                              : AppColors.emeraldGlow,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    ClarionButton(
                      label: _creating ? 'Create account' : 'Sign in',
                      isLoading: _busy,
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClarionButton(
                      label: 'Continue with Google',
                      tone: ButtonTone.secondary,
                      onPressed: _busy
                          ? null
                          : () => _run(AuthService.signInWithGoogle),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _Link(
                          label: _creating
                              ? 'I have an account'
                              : 'Create an account',
                          onTap: () => setState(() {
                            _creating = !_creating;
                            _error = _notice = null;
                          }),
                        ),
                        if (!_creating)
                          _Link(
                            label: 'Forgot password?',
                            onTap: _busy ? null : _resetPassword,
                          ),
                      ],
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
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.autofillHints,
    required this.textInputAction,
    this.keyboardType,
    this.obscure = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final List<String> autofillHints;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: RimLightPainter(
        borderRadius: AppRadii.mdAll,
        gradient: AppDecorations.rimLightSoft,
      ),
      child: DecoratedBox(
        decoration: AppDecorations.vellum(
          borderRadius: AppRadii.mdAll,
          active: true,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            autocorrect: false,
            enableSuggestions: !obscure,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.irisGlow),
        ),
      ),
    );
  }
}
