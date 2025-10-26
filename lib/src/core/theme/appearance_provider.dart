// lib/src/core/theme/appearance_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePrefKey = 'app_theme_preference';

final appearanceProvider = StateNotifierProvider<AppearanceNotifier, ThemeMode>(
  (ref) {
    // We're not passing SharedPreferences here, it will be loaded async.
    return AppearanceNotifier();
  },
);

class AppearanceNotifier extends StateNotifier<ThemeMode> {
  AppearanceNotifier() : super(ThemeMode.system) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefKey) ?? ThemeMode.system.index;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, themeMode.index);
    state = themeMode;
  }
}
