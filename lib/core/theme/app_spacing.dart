import 'package:flutter/widgets.dart';

/// 4px-based spacing scale.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double section = 40;

  /// Horizontal gutter shared by every top-level screen.
  static const double gutter = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: gutter,
  );

  /// Height of the floating navigation island (excluding safe-area inset).
  static const double navBarHeight = 62;

  /// Gap between the island and the bottom edge of the screen.
  static const double navBarMargin = 14;

  /// Scroll padding a tab body needs so its last item clears the island.
  static double navBarClearance(BuildContext context) =>
      navBarHeight + navBarMargin * 2 + MediaQuery.paddingOf(context).bottom;
}

/// Corner radii. Concentric surfaces step down by their padding so nested
/// curves stay parallel.
abstract final class AppRadii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Motion tokens. Interface transitions live in the 220–280ms band on cubic
/// curves — quick, settled, never rubbery. Only one-off data reveals (a dial
/// sweeping to its score) run longer.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 280);
  static const Duration reveal = Duration(milliseconds: 640);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.fastOutSlowIn;
}
