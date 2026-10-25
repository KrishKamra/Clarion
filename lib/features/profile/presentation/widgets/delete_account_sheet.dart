import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/clarion_sheet.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../auth/application/auth_service.dart';

/// Displays the confirmation modal sheet to permanently delete an account.
Future<void> showDeleteAccountSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: 'Danger Zone',
    title: 'Delete Account',
    builder: (context) => const _DeleteAccountForm(),
  );
}

class _DeleteAccountForm extends ConsumerStatefulWidget {
  const _DeleteAccountForm();

  @override
  ConsumerState<_DeleteAccountForm> createState() => _DeleteAccountFormState();
}

class _DeleteAccountFormState extends ConsumerState<_DeleteAccountForm> {
  bool _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      await AuthService.deleteAccount(db: db);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Account permanently deleted.')),
          );
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _busy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not delete account. Please try again.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TactileCard(
          material: CardMaterial.vellum,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.rose, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action is permanent and cannot be undone.',
                      style: AppTypography.label.copyWith(
                        color: AppColors.rose,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Deleting your account will permanently wipe your monthly envelope history, cart, 24h cooling-off holds, price watchlist, and post-purchase reflections.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: AppTypography.caption.copyWith(color: AppColors.rose),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ClarionButton(
          label: 'Delete account permanently',
          isLoading: _busy,
          onPressed: _busy ? null : _delete,
        ),
        const SizedBox(height: AppSpacing.md),
        ClarionButton(
          label: 'Keep my account',
          tone: ButtonTone.secondary,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
