import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/dynamic_pill.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../auth/application/auth_service.dart';

/// Card displayed on the Spending Profile screen showing email verification
/// status and providing options to resend verification links or refresh status.
class EmailVerificationCard extends ConsumerStatefulWidget {
  const EmailVerificationCard({super.key, required this.user});

  final User user;

  @override
  ConsumerState<EmailVerificationCard> createState() =>
      _EmailVerificationCardState();
}

class _EmailVerificationCardState extends ConsumerState<EmailVerificationCard>
    with WidgetsBindingObserver {
  bool _busy = false;

  /// Starts from the session's user, then follows each reload: the session
  /// `User` object never changes after sign-in, so it can't be the source.
  late bool _verified = widget.user.emailVerified;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// People verify by tapping the link in their mail app, then switch back.
  /// Coming back is the moment to check, so they never have to ask.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_verified && !_busy) {
      _refreshQuietly();
    }
  }

  Future<void> _refreshQuietly() async {
    try {
      await AuthService.reloadUser();
    } catch (_) {
      return; // Offline or signed out: the button still works later.
    }
    if (!mounted || !AuthService.isEmailVerified) return;
    setState(() => _verified = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Email verified. Thank you!')),
      );
  }

  Future<void> _resendEmail() async {
    setState(() => _busy = true);
    try {
      await AuthService.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Verification email sent to ${widget.user.email ?? 'your email'}. Check your inbox.',
              ),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                e is AuthFailure
                    ? e.message
                    : 'Could not send verification email.',
              ),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _busy = true);
    try {
      await AuthService.reloadUser();
      if (mounted) {
        final verified = AuthService.isEmailVerified;
        setState(() => _verified = verified);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                verified ? 'Email verified successfully!' : 'Email not verified yet. Please click the link sent to your inbox.',
              ),
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Could not refresh verification status.'),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verified = _verified;
    final email = widget.user.email ?? 'Account Email';

    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'EMAIL VERIFICATION',
                  style: AppTypography.overline,
                ),
              ),
              DynamicPill(
                label: verified ? 'Verified' : 'Unverified',
                icon: verified
                    ? Icons.verified_user_rounded
                    : Icons.mark_email_unread_outlined,
                color: verified ? AppColors.emeraldGlow : AppColors.amber,
                selected: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            verified
                ? 'Your email address ($email) is verified and secure.'
                : 'Your email address ($email) is not verified yet. Verification secures your account and enables price watch alerts.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (!verified) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ClarionButton(
                    label: 'Resend email',
                    tone: ButtonTone.secondary,
                    isLoading: _busy,
                    onPressed: _busy ? null : _resendEmail,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClarionButton(
                    label: 'I’ve verified',
                    isLoading: _busy,
                    onPressed: _busy ? null : _checkStatus,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
