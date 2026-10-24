import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Appearance chosen in the Spending Profile: follow the system, or pin
/// light or dark. Persisted so the choice survives a restart, and held
/// statically so it carries across the per-account provider scopes.
class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  static ThemeMode _saved = ThemeMode.system;

  /// Reads the saved choice; call once before `runApp`.
  static Future<void> load() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    _saved = ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }

  @override
  ThemeMode build() => _saved;

  void select(ThemeMode mode) {
    state = _saved = mode;
    SharedPreferences.getInstance().then((p) => p.setString(_key, mode.name));
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
