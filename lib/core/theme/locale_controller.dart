import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language chosen in the Spending Profile: `null` follows the device.
/// Persisted, and held statically so it carries across the per-account
/// provider scopes, like [ThemeModeController].
class LocaleController extends Notifier<Locale?> {
  static const _key = 'locale';
  static Locale? _saved;

  /// Reads the saved choice; call once before `runApp`.
  static Future<void> load() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    _saved = saved == null ? null : Locale(saved);
  }

  @override
  Locale? build() => _saved;

  void select(Locale? locale) {
    state = _saved = locale;
    SharedPreferences.getInstance().then(
      (p) => locale == null
          ? p.remove(_key)
          : p.setString(_key, locale.languageCode),
    );
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
