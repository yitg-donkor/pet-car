import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String toStorageString() {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
}

// ============================================
// SHARED PREFERENCES SERVICE
// ============================================

class ThemePreferencesService {
  static const String _themeKey = 'app_theme_mode';
  SharedPreferences? _prefs;

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<AppThemeMode> getThemeMode() async {
    try {
      await _ensureInitialized();
      final themeString = _prefs?.getString(_themeKey) ?? 'system';
      return AppThemeModeExtension.fromString(themeString);
    } catch (e) {
      print('Error loading theme preference: $e');
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      await _ensureInitialized();
      await _prefs?.setString(_themeKey, themeMode.toStorageString());
      print('Theme saved: ${themeMode.name}');
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  Future<void> clearThemePreference() async {
    try {
      await _ensureInitialized();
      await _prefs?.remove(_themeKey);
    } catch (e) {
      print('Error clearing theme preference: $e');
    }
  }
}

// ============================================
// THEME PREFERENCES SERVICE PROVIDER
// ============================================

final themePreferencesServiceProvider = Provider<ThemePreferencesService>((
  ref,
) {
  return ThemePreferencesService();
});

// ============================================
// THEME NOTIFIER WITH SHARED PREFERENCES
// ============================================

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final ThemePreferencesService _preferencesService;

  ThemeNotifier(this._preferencesService, AppThemeMode initialTheme)
    : super(initialTheme);

  Future<void> setTheme(AppThemeMode themeMode) async {
    state = themeMode;
    await _preferencesService.setThemeMode(themeMode);
  }

  Future<void> toggleTheme() async {
    final newTheme =
        state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setTheme(newTheme);
  }
}

// ============================================
// LOAD THEME FROM SHARED PREFERENCES
// ============================================

final loadThemeFromPreferencesProvider = FutureProvider<AppThemeMode>((
  ref,
) async {
  try {
    final preferencesService = ref.watch(themePreferencesServiceProvider);
    final savedTheme = await preferencesService.getThemeMode();
    print('Theme loaded from SharedPreferences: ${savedTheme.name}');
    return savedTheme;
  } catch (e) {
    print('Error loading theme from SharedPreferences: $e');
    return AppThemeMode.system;
  }
});

// ============================================
// THEME PROVIDER
// ============================================

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  final preferencesService = ref.watch(themePreferencesServiceProvider);
  return ThemeNotifier(preferencesService, AppThemeMode.system);
});

// ============================================
// INITIALIZE THEME FROM SHARED PREFERENCES
// ============================================

final initializeThemeProvider = FutureProvider<void>((ref) async {
  try {
    // Load theme from SharedPreferences
    final savedTheme = await ref.watch(loadThemeFromPreferencesProvider.future);

    // Set it to the theme provider
    await ref.read(themeProvider.notifier).setTheme(savedTheme);

    print('✅ Theme initialized: ${savedTheme.name}');
  } catch (e) {
    print('❌ Error in initializeThemeProvider: $e');
  }
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
