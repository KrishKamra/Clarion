import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Primary destinations hosted by the main scaffold.
enum AppTab { home, compare, cart, profile }

/// Active tab of the persistent navigation shell. Exposed as state so any
/// screen (e.g. the PDP's "View cart") can redirect the shell.
class NavigationController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) => state = tab;
}

final navigationProvider = NotifierProvider<NavigationController, AppTab>(
  NavigationController.new,
);
