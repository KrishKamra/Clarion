import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/clarion_sheet.dart';
import '../../../../core/widgets/dynamic_pill.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../data/models/regret_checkin_model.dart';
import '../../application/regret_controller.dart';

/// Launches the post-purchase Regret Check-in modal sheet.
Future<void> showRegretCheckinSheet(
  BuildContext context, {
  required String productTitle,
  required double amount,
  int? spendId,
}) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: 'Mindful Reflection',
    title: 'Regret Check-in',
    builder: (context) => _RegretCheckinForm(
      productTitle: productTitle,
      amount: amount,
      spendId: spendId,
    ),
  );
}

class _RegretCheckinForm extends ConsumerStatefulWidget {
  const _RegretCheckinForm({
    required this.productTitle,
    required this.amount,
    this.spendId,
  });

  final String productTitle;
  final double amount;
  final int? spendId;

  @override
  ConsumerState<_RegretCheckinForm> createState() => _RegretCheckinFormState();
}

class _RegretCheckinFormState extends ConsumerState<_RegretCheckinForm> {
  late RegretRating _rating;
  RegretTag? _tag;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final existing = ref
        .read(regretControllerProvider.notifier)
        .getCheckin(widget.productTitle);
    _rating = existing?.rating ?? RegretRating.worthIt;
    _tag = existing?.tag;
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(regretControllerProvider.notifier)
        .recordCheckin(
          spendId: widget.spendId,
          productTitle: widget.productTitle,
          amount: widget.amount,
          rating: _rating,
          tag: _tag,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    Navigator.of(context).pop();

    final message = switch (_rating) {
      RegretRating.worthIt =>
        'Reflection saved: ${widget.productTitle} was worth it!',
      RegretRating.neutral => 'Reflection saved for ${widget.productTitle}.',
      RegretRating.regretted =>
        'Regret recorded for ${widget.productTitle}. Kept in mind for future decisions.',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TactileCard(
          material: CardMaterial.vellum,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productTitle,
                style: AppTypography.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Settled purchase · ${Fmt.inr(widget.amount)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('WAS THIS PURCHASE WORTH IT?', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final r in RegretRating.values) ...[
              Expanded(
                child: _RatingButton(
                  rating: r,
                  selected: _rating == r,
                  onTap: () => setState(() => _rating = r),
                ),
              ),
              if (r != RegretRating.values.last)
                const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('WHY DO YOU FEEL THIS WAY?', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final tag in RegretTag.values)
              DynamicPill(
                label: tag.label,
                size: PillSize.regular,
                color: tag.isNegative ? AppColors.rose : AppColors.emeraldGlow,
                selected: _tag == tag,
                onTap: () => setState(() {
                  _tag = _tag == tag ? null : tag;
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('REFLECTION NOTE (OPTIONAL)', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _noteController,
          maxLines: 2,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: 'e.g. Used daily for work, or impulse buy during sale...',
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: AppColors.vellum,
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: OutlineInputBorder(
              borderRadius: AppRadii.lgAll,
              borderSide: BorderSide(color: AppColors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.lgAll,
              borderSide: BorderSide(color: AppColors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.lgAll,
              borderSide: BorderSide(color: AppColors.irisGlow),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ClarionButton(label: 'Save Reflection', onPressed: _save),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.rating,
    required this.selected,
    required this.onTap,
  });

  final RegretRating rating;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = switch (rating) {
      RegretRating.worthIt => AppColors.emeraldGlow,
      RegretRating.neutral => AppColors.irisGlow,
      RegretRating.regretted => AppColors.rose,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.15)
              : AppColors.vellum,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: selected ? activeColor : AppColors.hairline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(rating.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              rating.label,
              style: AppTypography.caption.copyWith(
                color: selected ? activeColor : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
