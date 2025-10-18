import 'package:flutter/material.dart';

// ============================================
// APP THEMES
// ============================================

class AppTheme {
  // Brand Colors
  static const Color primaryGold = Color(0xFFF8B400);
  static const Color primaryGoldDark = Color(0xFFC89000);
  static const Color primaryGoldLight = Color(0xFFF9D976);

  static const Color secondaryBlue = Color(0xFFA7C7E7);
  static const Color secondaryBlueDark = Color(0xFF7CB9E8);
  static const Color tertiaryGold = Color(0xFFFFC46B);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFFA7C7E7);

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme from seed
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFAE6D2),
      brightness: Brightness.light,
      primary: const Color(0xFFF8B400),
      secondary: const Color(0xFFA7C7E7),
      tertiary: const Color(0xFFF9D976),
      background: Colors.white,
      surface: const Color(0xFFFAFAE6),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: const Color(0xFF2E2E2E),
      onSurface: const Color(0xFF2E2E2E),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFFFAE6D2),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8B400),
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: Colors.white),
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
        backgroundColor: Color(0xFFF8B400),
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
        foregroundColor: primaryGold,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGold,
        side: const BorderSide(color: primaryGold, width: 2),
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
        borderSide: const BorderSide(color: primaryGold, width: 2),
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
      backgroundColor: primaryGold,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFFF8B400),
      unselectedItemColor: Color(0xFF9E9E9E),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFFFF4DC),
      selectedColor: primaryGold,
      labelStyle: const TextStyle(color: Color(0xFF2E2E2E)),
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
        color: Color(0xFF2E2E2E),
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
      color: primaryGold,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryGold;
        }
        return const Color(0xFF9E9E9E);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0xFFFFF4DC);
        }
        return const Color(0xFFE0E0E0);
      }),
    ),

    // Slider
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryGold,
      inactiveTrackColor: Color(0xFFE0E0E0),
      thumbColor: primaryGold,
      overlayColor: Color(0x29F8B400),
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
        color: Color(0xFF2E2E2E),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E2E2E),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E2E2E),
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E2E2E),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFF2E2E2E),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFF2E2E2E),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFF757575),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
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

    // Color Scheme from seed
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF8B400),
      brightness: Brightness.dark,
      primary: const Color(0xFFF8B400),
      secondary: const Color(0xFF7CB9E8),
      tertiary: const Color(0xFFFFC46B),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: const Color(0xFFEDEDED),
      onSurface: const Color(0xFFEDEDED),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFEDEDED),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFFEDEDED),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: Color(0xFFEDEDED)),
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
        backgroundColor: Color(0xFFF8B400),
        foregroundColor: Colors.black,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGoldLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGoldLight,
        side: const BorderSide(color: primaryGoldLight, width: 2),
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
        borderSide: const BorderSide(color: primaryGoldLight, width: 2),
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
      backgroundColor: primaryGold,
      foregroundColor: Colors.black,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFFF8B400),
      unselectedItemColor: Color(0xFF757575),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      selectedColor: primaryGold,
      labelStyle: const TextStyle(color: Color(0xFFEDEDED)),
      secondaryLabelStyle: const TextStyle(color: Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: Color(0xFFEDEDED),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      contentTextStyle: const TextStyle(color: Color(0xFFEDEDED)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGold,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryGold;
        }
        return const Color(0xFF757575);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0xFF3D3020);
        }
        return const Color(0xFF424242);
      }),
    ),

    // Slider
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryGold,
      inactiveTrackColor: Color(0xFF424242),
      thumbColor: primaryGold,
      overlayColor: Color(0x29F8B400),
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
        color: Color(0xFFEDEDED),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFEDEDED),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFEDEDED),
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFEDEDED),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDEDED),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDEDED),
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDEDED),
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDEDED),
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDEDED),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFFEDEDED),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFFEDEDED),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFFBDBDBD),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDEDED),
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
