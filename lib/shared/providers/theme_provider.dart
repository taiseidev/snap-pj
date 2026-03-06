import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { dark, light, system }

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
        (ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.dark) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value != null) {
        state = AppThemeMode.values.firstWhere(
          (e) => e.name == value,
          orElse: () => AppThemeMode.dark,
        );
      }
    } catch (_) {
      // SharedPreferences not available (e.g. in tests)
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }
}

extension AppThemeModeX on AppThemeMode {
  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.dark:
        return 'ダーク';
      case AppThemeMode.light:
        return 'ライト';
      case AppThemeMode.system:
        return 'システム設定に従う';
    }
  }
}
