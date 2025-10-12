import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:pet_care/models/user_profile.dart';
import 'package:pet_care/providers/auth_providers.dart';

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
// THEME NOTIFIER WITH PERSISTENCE
// ============================================

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier(AppThemeMode initialTheme) : super(initialTheme);

  void setTheme(AppThemeMode themeMode) {
    state = themeMode;
  }

  void toggleTheme() {
    state =
        state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }
}

// ============================================
// LOAD SAVED THEME FROM USER PROFILE
// ============================================

Future<AppThemeMode> _loadSavedThemeFromProfile(
  UserProfile? userProfile,
) async {
  if (userProfile != null) {
    try {
      final savedTheme = AppThemeModeExtension.fromString(
        userProfile.appSettings.theme,
      );
      return savedTheme;
    } catch (e) {
      print('Error parsing theme: $e');
    }
  }
  return AppThemeMode.system;
}

// ============================================
// THEME PROVIDER (UPDATED)
// ============================================

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier(AppThemeMode.system);
});

// ============================================
// INITIALIZE THEME FROM USER PROFILE
// ============================================

final initializeThemeProvider = FutureProvider<void>((ref) async {
  try {
    // Watch user profile provider
    final userProfileAsync = ref.watch(userProfileProviderProvider);

    // Wait for user profile data
    final userProfile = await userProfileAsync.when(
      data: (profile) async => profile,
      loading: () async {
        // Wait a bit for profile to load
        await Future.delayed(const Duration(milliseconds: 500));
        return null;
      },
      error: (e, st) async {
        print('Error loading user profile: $e');
        return null;
      },
    );

    // Load saved theme
    final savedTheme = await _loadSavedThemeFromProfile(userProfile);
    ref.read(themeProvider.notifier).setTheme(savedTheme);
  } catch (e) {
    print('Error in initializeThemeProvider: $e');
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
