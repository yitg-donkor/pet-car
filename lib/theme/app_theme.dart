import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Based on UI Analysis
  static const Color primaryPeach = Color(0xFFE8C4A8);
  static const Color accentCream = Color(0xFFFFF4E6);
  static const Color softBlue = Color(0xFFA7C8D0);
  static const Color sageGreen = Color(0xFF9BAA8E);
  static const Color warmBrown = Color(0xFF8B6B47);

  // Button Colors from UI
  static const Color lightButtonPeach = Color(0xFFE8C4A8);
  static const Color lightButtonOrange = Color(0xFFD9A77A);
  static const Color lightButtonGreen = Color(0xFF9BAA8E);

  static const Color darkButtonBurgundy = Color(0xFF7A5563);
  static const Color darkButtonPurple = Color(0xFF6B5566);
  static const Color darkButtonTeal = Color(0xFF5D7A72);

  // Semantic Colors
  static const Color success = Color(0xFF81B29A);
  static const Color warning = Color(0xFFE8B84E);
  static const Color error = Color(0xFFD17A7A);
  static const Color info = Color(0xFFA7C8D0);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAE6D2);
  static const Color lightSurface = Color(0xFFFFF4E6);
  static const Color lightCardBackground = Color(0xFFE8C4A8);
  static const Color lightTextPrimary = Color(0xFF3D3428);
  static const Color lightTextSecondary = Color(0xFF6B5D52);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF3C4043);
  static const Color darkSurface = Color(0xFF4A4D51);
  static const Color darkCardBackground = Color(0xFF52555A);
  static const Color darkTextPrimary = Color(0xFFFAFAE6);
  static const Color darkTextSecondary = Color(0xFFD4C5B9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.comicNeue().fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPeach,
      brightness: Brightness.light,
      primary: primaryPeach,
      secondary: softBlue,
      tertiary: sageGreen,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: lightTextPrimary,
      onSecondary: lightTextPrimary,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
      error: error,
    ),

    scaffoldBackgroundColor: lightBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.comicNeue(
        color: lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),

    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightButtonPeach,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.comicNeue(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: warmBrown,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: warmBrown,
        side: const BorderSide(color: warmBrown, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: warmBrown, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.comicNeue(
        color: lightTextSecondary.withOpacity(0.6),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPeach,
      foregroundColor: lightTextPrimary,
      elevation: 4,
      shape: CircleBorder(),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: accentCream,
      selectedItemColor: warmBrown,
      unselectedItemColor: lightTextSecondary.withOpacity(0.5),
      selectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: accentCream,
      selectedColor: primaryPeach,
      labelStyle: GoogleFonts.comicNeue(color: lightTextPrimary),
      secondaryLabelStyle: GoogleFonts.comicNeue(color: lightTextPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: lightSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.comicNeue(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: warmBrown,
      contentTextStyle: GoogleFonts.comicNeue(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(color: warmBrown),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return warmBrown;
        }
        return lightTextSecondary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color.fromARGB(255, 121, 98, 80);
        }
        return lightSurface;
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: warmBrown,
      inactiveTrackColor: lightSurface,
      thumbColor: warmBrown,
      overlayColor: warmBrown.withOpacity(0.2),
    ),

    dividerTheme: DividerThemeData(
      color: lightTextSecondary.withOpacity(0.2),
      thickness: 1,
      space: 16,
    ),

    iconTheme: IconThemeData(color: lightTextSecondary, size: 24),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.comicNeue(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.comicNeue(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      displaySmall: GoogleFonts.comicNeue(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      headlineLarge: GoogleFonts.comicNeue(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      headlineMedium: GoogleFonts.comicNeue(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      headlineSmall: GoogleFonts.comicNeue(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleMedium: GoogleFonts.comicNeue(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleSmall: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodySmall: GoogleFonts.comicNeue(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: lightTextSecondary,
      ),
      labelLarge: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      labelMedium: GoogleFonts.comicNeue(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: lightTextSecondary,
      ),
      labelSmall: GoogleFonts.comicNeue(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: lightTextSecondary,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.comicNeue().fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: darkButtonBurgundy,
      brightness: Brightness.dark,
      primary: darkButtonBurgundy,
      secondary: darkButtonPurple,
      tertiary: darkButtonTeal,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: darkTextPrimary,
      onSecondary: darkTextPrimary,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
      error: error,
    ),

    scaffoldBackgroundColor: darkBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.comicNeue(
        color: darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),

    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkButtonBurgundy,
        foregroundColor: accentCream,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.comicNeue(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkTextSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrimary,
        side: BorderSide(color: darkTextSecondary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: darkTextSecondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.comicNeue(
        color: darkTextSecondary.withOpacity(0.5),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkButtonBurgundy,
      foregroundColor: accentCream,
      elevation: 6,
      shape: CircleBorder(),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCardBackground,
      selectedItemColor: primaryPeach,
      unselectedItemColor: darkTextSecondary.withOpacity(0.5),
      selectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: darkSurface,
      selectedColor: darkButtonBurgundy,
      labelStyle: GoogleFonts.comicNeue(color: darkTextPrimary),
      secondaryLabelStyle: GoogleFonts.comicNeue(color: accentCream),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.comicNeue(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardBackground,
      contentTextStyle: GoogleFonts.comicNeue(color: darkTextPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: darkButtonBurgundy,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkButtonBurgundy;
        }
        return darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color.fromARGB(255, 227, 211, 223).withOpacity(0.5);
        }
        return darkSurface;
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: darkButtonBurgundy,
      inactiveTrackColor: darkSurface,
      thumbColor: darkButtonBurgundy,
      overlayColor: darkButtonBurgundy.withOpacity(0.2),
    ),

    dividerTheme: DividerThemeData(
      color: darkTextSecondary.withOpacity(0.2),
      thickness: 1,
      space: 16,
    ),

    iconTheme: IconThemeData(color: darkTextSecondary, size: 24),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.comicNeue(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.comicNeue(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      displaySmall: GoogleFonts.comicNeue(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineLarge: GoogleFonts.comicNeue(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.comicNeue(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      headlineSmall: GoogleFonts.comicNeue(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      titleLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      titleMedium: GoogleFonts.comicNeue(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      titleSmall: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodySmall: GoogleFonts.comicNeue(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      labelLarge: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      labelMedium: GoogleFonts.comicNeue(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: darkTextSecondary,
      ),
      labelSmall: GoogleFonts.comicNeue(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: darkTextSecondary,
      ),
    ),
  );
}
