import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/theme/app_theme.dart';

// ============================================
// THEME MODE ENUM
// ============================================

enum AppThemeMode { light, dark, system }

extension AppThemeModeExtension on AppThemeMode {
  String get name {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }
}

// ============================================
// THEME NOTIFIER
// ============================================

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system);

  void setTheme(AppThemeMode themeMode) {
    state = themeMode;
  }

  void toggleTheme() {
    state =
        state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }
}

// ============================================
// THEME PROVIDER
// ============================================

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

// ============================================
// CURRENT THEME DATA PROVIDER
// ============================================

final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  if (themeMode == AppThemeMode.system) {
    return brightness == Brightness.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  return themeMode == AppThemeMode.dark
      ? AppTheme.darkTheme
      : AppTheme.lightTheme;
});

// ============================================
// IS DARK MODE PROVIDER
// ============================================

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  if (themeMode == AppThemeMode.system) {
    return brightness == Brightness.dark;
  }

  return themeMode == AppThemeMode.dark;
});
