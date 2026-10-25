import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/review_model.dart';
import '../../../l10n/l10n.dart';
import '../../orders/application/orders_controller.dart';
import '../application/reviews_controller.dart';
import 'write_review_sheet.dart';

/// Owner reviews on the decision canvas: how the ratings spread, then what
/// owners actually wrote, with how long they had owned it. Buyers can add
/// their own, marked as a verified purchase.
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(ratingSummaryProvider(productId));
    final reviews = ref.watch(productReviewsProvider(productId));
    final bought = ref.watch(
      purchasedProductIdsProvider.select((ids) => ids.contains(productId)),
    );
    final mine = ref.watch(
      myReviewsProvider.select((m) => m.containsKey(productId)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.ownerReviews),
        const SizedBox(height: AppSpacing.md),
        _Summary(summary: summary),
        if (bought && !mine) ...[
          const SizedBox(height: AppSpacing.md),
          ClarionButton(
            label: l10n.writeReview,
            icon: Icons.rate_review_outlined,
            tone: ButtonTone.secondary,
            onPressed: () => showWriteReviewSheet(context, productId),
          ),
        ],
        for (final r in reviews) ...[
          const SizedBox(height: AppSpacing.md),
          ReviewCard(
            review: r,
            onEdit: r.mine
                ? () => showWriteReviewSheet(context, productId)
                : null,
          ),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary});

  final RatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TactileCard(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                summary.average.toStringAsFixed(1),
                style: AppTypography.metricXL,
              ),
              const SizedBox(height: AppSpacing.xs),
              StarRating(rating: summary.average),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.ratingCount(summary.count),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  _Bar(star: star, share: summary.shareOf(star)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.star, required this.share});

  final int star;
  final double share;

  @override
  Widget build(BuildContext context) {
    final percent = (share * 100).round();
    return Semantics(
      label: context.l10n.starShare(star, percent),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              child: Text('$star', style: AppTypography.metricSmall),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadii.pillAll,
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 6,
                  backgroundColor: AppColors.hairline,
                  color: AppColors.amber,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 36,
              child: Text(
                '$percent%',
                textAlign: TextAlign.right,
                style: AppTypography.metricSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One review: who, how many stars, how long they had owned it, and what
/// they said. Long reviews open on tap.
class ReviewCard extends StatefulWidget {
  const ReviewCard({super.key, required this.review, this.onEdit});

  final Review review;
  final VoidCallback? onEdit;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = widget.review;
    final date = MaterialLocalizations.of(context).formatMediumDate(r.date);
    return TactileCard(
      material: r.mine ? CardMaterial.floating : CardMaterial.matte,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.mine ? l10n.yourReview : r.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
              ),
              if (r.verified)
                DynamicPill(
                  label: l10n.verifiedPurchase,
                  icon: Icons.verified_outlined,
                  color: AppColors.emeraldGlow,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StarRating(rating: r.rating.toDouble(), size: 13),
              Text(
                r.ownedFor.isEmpty ? date : l10n.ownedFor(r.ownedFor, date),
                style: AppTypography.caption,
              ),
            ],
          ),
          if (r.title != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(r.title!, style: AppTypography.titleSmall),
          ],
          const SizedBox(height: AppSpacing.xs),
          AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: Text(
              r.body,
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: AppTypography.bodySmall,
            ),
          ),
          if (widget.onEdit != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Pressable(
              onTap: widget.onEdit,
              semanticLabel: l10n.editReview,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  l10n.editReview,
                  style: AppTypography.label.copyWith(
                    color: AppColors.irisGlow,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
