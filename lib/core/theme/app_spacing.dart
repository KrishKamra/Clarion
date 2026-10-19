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
  static const double huge = 48;

  /// Horizontal gutter used by every top-level screen.
  static const double gutter = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: gutter,
  );

  /// Height of the floating navigation bar (excluding safe-area inset).
  static const double navBarHeight = 68;

  /// Space between the floating bar and the bottom edge of the screen.
  static const double navBarMargin = 12;

  /// Scroll padding a tab body needs so its last item clears the floating bar.
  static double navBarClearance(BuildContext context) =>
      navBarHeight + navBarMargin * 2 + MediaQuery.paddingOf(context).bottom;
}

/// Corner radii.
abstract final class AppRadii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Elevation is expressed through glow rather than drop shadow on a dark
/// canvas; these are the standard blur radii for coloured glows.
abstract final class AppElevation {
  static const double glowSoft = 18;
  static const double glowMedium = 28;
  static const double glowStrong = 40;
}

/// Motion durations and curves.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration dial = Duration(milliseconds: 1100);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve spring = Curves.elasticOut;
}
