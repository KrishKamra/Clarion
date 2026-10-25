import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, per account, whether the "set your monthly ceiling" prompt has
/// already been shown, so a new account is asked exactly once.
abstract final class CeilingOnboarding {
  static String _key(String uid) => 'ceiling_prompted_$uid';

  static Future<bool> isDone(String uid) async =>
      (await SharedPreferences.getInstance()).getBool(_key(uid)) ?? false;

  static Future<void> markDone(String uid) async =>
      (await SharedPreferences.getInstance()).setBool(_key(uid), true);
}

/// Same idea for the first-run app tour: shown once per account, and
/// replayable any time from Profile.
abstract final class TourOnboarding {
  static String _key(String uid) => 'tour_seen_$uid';

  static Future<bool> isDone(String uid) async =>
      (await SharedPreferences.getInstance()).getBool(_key(uid)) ?? false;

  static Future<void> markDone(String uid) async =>
      (await SharedPreferences.getInstance()).setBool(_key(uid), true);
}
