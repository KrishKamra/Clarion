import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_sheet.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../l10n/l10n.dart';
import '../application/reviews_controller.dart';

/// Write or edit the account's review of [productId].
Future<void> showWriteReviewSheet(BuildContext context, String productId) {
  final l10n = context.l10n;
  return showClarionSheet<void>(
    context: context,
    eyebrow: l10n.verifiedPurchase,
    title: l10n.writeReview,
    builder: (_) => _WriteReview(productId: productId),
  );
}

class _WriteReview extends ConsumerStatefulWidget {
  const _WriteReview({required this.productId});

  final String productId;

  @override
  ConsumerState<_WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends ConsumerState<_WriteReview> {
  /// Long enough to say something useful to the next buyer.
  static const int minLength = 20;

  late final _existing = ref.read(myReviewsProvider)[widget.productId];
  late int _rating = _existing?.rating ?? 0;
  late final _title = TextEditingController(text: _existing?.title);
  late final _body = TextEditingController(text: _existing?.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _valid => _rating > 0 && _body.text.trim().length >= minLength;

  void _save() {
    ref
        .read(myReviewsProvider.notifier)
        .save(
          widget.productId,
          rating: _rating,
          title: _title.text,
          body: _body.text,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final remaining = minLength - _body.text.trim().length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.yourRating, style: AppTypography.label),
        StarPicker(
          value: _rating,
          onChanged: (v) => setState(() => _rating = v),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          decoration: InputDecoration(labelText: l10n.reviewTitleLabel),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _body,
          textCapitalization: TextCapitalization.sentences,
          minLines: 3,
          maxLines: 6,
          maxLength: 600,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.reviewBodyLabel,
            hintText: l10n.reviewBodyHint,
            helperText: remaining > 0 ? l10n.reviewMoreChars(remaining) : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ClarionButton(label: l10n.postReview, onPressed: _valid ? _save : null),
        if (_existing != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Pressable(
              onTap: () {
                ref.read(myReviewsProvider.notifier).remove(widget.productId);
                Navigator.of(context).pop();
              },
              semanticLabel: l10n.deleteReview,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l10n.deleteReview,
                  style: AppTypography.label.copyWith(color: AppColors.rose),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
