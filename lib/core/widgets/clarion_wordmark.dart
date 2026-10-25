import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_typography.dart';

/// The word "Clarion" in the brand's display type. The sign-in lockup and the
/// app header both use this, so the name looks the same wherever it appears.
class ClarionName extends StatelessWidget {
  const ClarionName({super.key, required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Clarion',
      style: AppTypography.display.copyWith(
        fontSize: fontSize,
        letterSpacing: -fontSize * 0.035,
        height: 1,
      ),
    );
  }
}

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
            ClarionName(fontSize: size),
          ],
        ],
      ),
    );
  }
}
