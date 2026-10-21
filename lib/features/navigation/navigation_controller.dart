import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Primary destinations hosted by the main scaffold.
enum AppTab {
  /// Intent Horizon — state a goal, see what fits.
  horizon,

  /// Compare Matrix — differential, priority-weighted head-to-heads.
  compare,

  /// Smart Cart — the Budget Guardian.
  cart,

  /// Spending Profile — the envelope, cooling-off queue and history.
  profile,
}

/// Active tab of the persistent shell. Exposed as state so any screen
/// (e.g. the decision bar's "View cart") can redirect the shell.
class NavigationController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.horizon;

  void select(AppTab tab) => state = tab;
}

final navigationProvider = NotifierProvider<NavigationController, AppTab>(
  NavigationController.new,
);
