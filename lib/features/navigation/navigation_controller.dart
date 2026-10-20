import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Primary destinations hosted by the main scaffold.
enum AppTab {
  /// Intent Horizon — state a goal, see what fits.
  horizon,

  /// Decision Node — pending holds and head-to-head comparisons.
  decisions,

  /// Smart Cart — the Budget Guardian.
  cart,

  /// Spending Memory — the envelope over time.
  memory,
}

/// Active tab of the persistent shell. Exposed as state so any screen
/// (e.g. the decision drawer's "View cart") can redirect the shell.
class NavigationController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.horizon;

  void select(AppTab tab) => state = tab;
}

final navigationProvider = NotifierProvider<NavigationController, AppTab>(
  NavigationController.new,
);
