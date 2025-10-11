import 'package:flutter/material.dart';

// ============================================
// APP THEMES
// ============================================

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);

  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: Color(0xFFE8F5E9),
      secondary: secondaryBlue,
      secondaryContainer: Color(0xFFE3F2FD),
      tertiary: secondaryOrange,
      tertiaryContainer: Color(0xFFFFE0B2),
      error: error,
      errorContainer: Color(0xFFFFEBEE),
      background: Color(0xFFF5F5F5),
      surface: Colors.white,
      surfaceVariant: Color(0xFFF5F5F5),
      outline: Color(0xFFE0E0E0),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF212121),
      onSurface: Color(0xFF212121),
      onSurfaceVariant: Color(0xFF757575),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF212121),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFF212121),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: Color(0xFF212121)),
    ),

    // Card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Color(0xFF9E9E9E),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE8F5E9),
      selectedColor: primaryGreen,
      labelStyle: const TextStyle(color: Color(0xFF212121)),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: Color(0xFF212121),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF323232),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreen,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryGreen;
        }
        return const Color(0xFF9E9E9E);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryGreen.withOpacity(0.5);
        }
        return const Color(0xFFE0E0E0);
      }),
    ),

    // Slider
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryGreen,
      inactiveTrackColor: Color(0xFFE0E0E0),
      thumbColor: primaryGreen,
      overlayColor: Color(0x29388E3C),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 16,
    ),

    // Icon
    iconTheme: const IconThemeData(color: Color(0xFF757575), size: 24),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFF212121),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFF212121),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFF757575),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF757575),
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9E9E9E),
      ),
    ),
  );

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryGreenLight,
      primaryContainer: Color(0xFF1B5E20),
      secondary: Color(0xFF64B5F6),
      secondaryContainer: Color(0xFF0D47A1),
      tertiary: Color(0xFFFFB74D),
      tertiaryContainer: Color(0xFFE65100),
      error: Color(0xFFEF5350),
      errorContainer: Color(0xFFB71C1C),
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      surfaceVariant: Color(0xFF2C2C2C),
      outline: Color(0xFF424242),
      onPrimary: Color(0xFF121212),
      onSecondary: Color(0xFF121212),
      onBackground: Color(0xFFE0E0E0),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFBDBDBD),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFE0E0E0),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
    ),

    // Card
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreenLight,
        foregroundColor: const Color(0xFF121212),
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreenLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreenLight,
        side: const BorderSide(color: primaryGreenLight, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreenLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF757575)),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreenLight,
      foregroundColor: Color(0xFF121212),
      elevation: 6,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryGreenLight,
      unselectedItemColor: Color(0xFF757575),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      selectedColor: primaryGreenLight,
      labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
      secondaryLabelStyle: const TextStyle(color: Color(0xFF121212)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      contentTextStyle: const TextStyle(color: Color(0xFFE0E0E0)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreenLight,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryGreenLight;
        }
        return const Color(0xFF757575);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryGreenLight.withOpacity(0.5);
        }
        return const Color(0xFF424242);
      }),
    ),

    // Slider
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryGreenLight,
      inactiveTrackColor: Color(0xFF424242),
      thumbColor: primaryGreenLight,
      overlayColor: Color(0x2981C784),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
      space: 16,
    ),

    // Icon
    iconTheme: const IconThemeData(color: Color(0xFFBDBDBD), size: 24),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFFE0E0E0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFFE0E0E0),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFFBDBDBD),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFBDBDBD),
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF757575),
      ),
    ),
  );
}
