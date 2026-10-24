import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_typography.dart';

/// Clarion mark (`assets/brand/clarion_logo.svg`): a glass lens with an
/// iris-to-emerald rim and an iris focal point. Shown alone as a monogram,
/// or beside the name in the grotesque. Its colours are fixed, so it reads
/// the same on light and dark.
class ClarionWordmark extends StatelessWidget {
  const ClarionWordmark({super.key, this.size = 18, this.showName = true});

  /// Height of the mark; the type scales from it.
  final double size;

  /// Set false for the monogram alone.
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Clarion',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/brand/clarion_logo.svg',
            width: size,
            height: size,
          ),
          if (showName) ...[
            SizedBox(width: size * 0.45),
            Text(
              'Clarion',
              style: AppTypography.title.copyWith(
                fontSize: size * 0.98,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
