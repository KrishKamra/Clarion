import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Five stars filled to [rating], in amber. Read out as "Rated 4.5 out of
/// 5" rather than five separate glyphs.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 14});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.ratedOutOfFive(rating.toStringAsFixed(1)),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - 0.5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: AppColors.amber,
            ),
        ],
      ),
    );
  }
}

/// Five tappable stars for choosing a rating, each a full-size touch target
/// announced as "3 stars", with the chosen one marked selected.
class StarPicker extends StatelessWidget {
  const StarPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Semantics(
            button: true,
            selected: value == i,
            label: context.l10n.starCount(i),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => onChanged(i),
              radius: 24,
              child: SizedBox.square(
                dimension: 48,
                child: Icon(
                  i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 32,
                  color: i <= value ? AppColors.amber : AppColors.textTertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
