import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Appearance chosen in the Spending Profile: follow the system, or pin
/// light or dark. Persisted so the choice survives a restart.
class ThemeModeController extends Notifier<ThemeMode> {
  ThemeModeController([this._initial = ThemeMode.system]);

  final ThemeMode _initial;

  static const _key = 'theme_mode';

  /// Reads the saved choice; call once before `runApp`.
  static Future<ThemeMode> load() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    return ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }

  @override
  ThemeMode build() => _initial;

  void select(ThemeMode mode) {
    state = mode;
    SharedPreferences.getInstance().then((p) => p.setString(_key, mode.name));
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
