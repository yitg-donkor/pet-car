import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Based on UI Analysis
  // Enhanced Brand Colors
  static const Color primaryPeach = Color(0xFFE8C4A8);
  static const Color accentCream = Color(0xFFFFF4E6);
  static const Color softBlue = Color(0xFF7FB3C4); // More saturated
  static const Color sageGreen = Color(0xFF8A9B7E); // Deeper green
  static const Color warmBrown = Color(
    0xFF7A5843,
  ); // Darker for better contrast

  // Improved button colors
  static const Color lightButtonPeach = Color(0xFFE0B89A);
  static const Color lightButtonOrange = Color(0xFFD09970);
  static const Color lightButtonGreen = Color(0xFF8A9B7E);

  // Better semantic colors
  static const Color success = Color(0xFF6DA884);
  static const Color warning = Color(0xFFE8B84E);
  static const Color error = Color(0xFFD17A7A);
  static const Color info = Color(0xFF7FB3C4);

  // Refined light theme colors
  static const Color lightBackground = Color(0xFFFFF8F0); // Warmer, less peachy
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color lightCardBackground = Color(0xFFF5E8DC);
  static const Color lightTextPrimary = Color(
    0xFF2D2520,
  ); // Darker for contrast
  static const Color lightTextSecondary = Color(
    0xFF5D534A,
  ); // Improved contrast

  // Dark theme colors (keeping your existing ones)
  static const Color darkBackground = Color(0xFF1C1E21);
  static const Color darkSurface = Color(0xFF2D3033);
  static const Color darkCardBackground = Color(0xFF3D4145);
  static const Color darkTextPrimary = Color(0xFFFFFBF5);
  static const Color darkTextSecondary = Color(0xFFD4C5B9);
  static const Color darkButtonBurgundy = Color(0xFF9D7B8A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.comicNeue().fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPeach,
      brightness: Brightness.light,
      primary: Color(0xFFD09970), // Darker peach for better contrast
      secondary: softBlue,
      tertiary: sageGreen,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white, // White text on primary
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
      error: error,
      surfaceVariant: Color(0xFFF5E8DC),
      outline: Color(0xFFD0BCAA),
    ),

    scaffoldBackgroundColor: lightBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Transparent for gradient
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.comicNeue(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD09970),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.15),
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
        borderSide: BorderSide(color: Color(0xFFD0BCAA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Color(0xFFD0BCAA), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: warmBrown, width: 2),
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

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFD09970),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFFD09970), // Darker peach
      unselectedItemColor: Color(0xFF9B8A7E), // Muted brown-gray
      selectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFFF5E8DC),
      selectedColor: Color(0xFFD09970),
      labelStyle: GoogleFonts.comicNeue(color: lightTextPrimary),
      secondaryLabelStyle: GoogleFonts.comicNeue(color: Colors.white),
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
        return Color(0xFFD0BCAA);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return warmBrown.withOpacity(0.5);
        }
        return Color(0xFFE8DDD0);
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: warmBrown,
      inactiveTrackColor: Color(0xFFE8DDD0),
      thumbColor: warmBrown,
      overlayColor: warmBrown.withOpacity(0.2),
    ),

    dividerTheme: DividerThemeData(
      color: Color(0xFFD0BCAA),
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
      primary: Color(
        0xFF9D7B8A,
      ), // Lighter, more saturated burgundy for better visibility
      secondary: Color(0xFF8B9DC3), // Lighter blue for accents
      tertiary: Color(0xFF7FA390), // Lighter teal
      surface: Color(0xFF2D3033), // Slightly lighter than background for depth
      background: Color(0xFF1C1E21), // Darker background for better contrast
      onPrimary: Color(0xFFFFFBF5), // Very light cream for primary text
      onSecondary: Color(0xFFFFFBF5),
      onSurface: Color(0xFFFAFAE6), // Light cream for surface text
      onBackground: Color(0xFFFAFAE6),
      error: Color(0xFFE88B8B), // Lighter error color
    ),

    scaffoldBackgroundColor: Color(0xFF1C1E21), // Darker background

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2D3033), // Match surface color
      foregroundColor: Color(0xFFFFFBF5), // Very light text
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.comicNeue(
        color: Color(0xFFFFFBF5),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFFFBF5)),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF2D3033), // Lighter than background
      elevation: 2, // Add subtle elevation
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF9D7B8A), // Lighter burgundy
        foregroundColor: Color(0xFFFFFBF5), // Light cream text
        elevation: 2,
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
        foregroundColor: Color(0xFFD4C5B9), // Lighter secondary text
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFFFFFBF5),
        side: BorderSide(color: Color(0xFF9D7B8A), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2D3033),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Color(0xFF404448), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Color(0xFF9D7B8A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Color(0xFFE88B8B), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.comicNeue(
        color: Color(0xFFD4C5B9).withOpacity(0.5),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF9D7B8A),
      foregroundColor: Color(0xFFFFFBF5),
      elevation: 6,
      shape: CircleBorder(),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF252729), // Darker than surface
      selectedItemColor: Color(0xFFFFD89C), // Warm golden yellow for selected
      unselectedItemColor: Color(0xFF6B7075), // Muted gray for unselected
      selectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF2D3033),
      selectedColor: Color(0xFF9D7B8A),
      labelStyle: GoogleFonts.comicNeue(color: Color(0xFFFAFAE6)),
      secondaryLabelStyle: GoogleFonts.comicNeue(color: Color(0xFFFFFBF5)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF2D3033),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.comicNeue(
        color: Color(0xFFFFFBF5),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF3D4145),
      contentTextStyle: GoogleFonts.comicNeue(color: Color(0xFFFAFAE6)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Color(0xFF9D7B8A),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Color(0xFF9D7B8A);
        }
        return Color(0xFF6B7075);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Color(0xFF9D7B8A).withOpacity(0.5);
        }
        return Color(0xFF404448);
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: Color(0xFF9D7B8A),
      inactiveTrackColor: Color(0xFF404448),
      thumbColor: Color(0xFF9D7B8A),
      overlayColor: Color(0xFF9D7B8A).withOpacity(0.2),
    ),

    dividerTheme: DividerThemeData(
      color: Color(0xFF404448),
      thickness: 1,
      space: 16,
    ),

    iconTheme: IconThemeData(color: Color(0xFFD4C5B9), size: 24),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.comicNeue(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFBF5),
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.comicNeue(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFBF5),
      ),
      displaySmall: GoogleFonts.comicNeue(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFBF5),
      ),
      headlineLarge: GoogleFonts.comicNeue(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFBF5),
      ),
      headlineMedium: GoogleFonts.comicNeue(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFBF5),
      ),
      headlineSmall: GoogleFonts.comicNeue(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFBF5),
      ),
      titleLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFAFAE6),
      ),
      titleMedium: GoogleFonts.comicNeue(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFAFAE6),
      ),
      titleSmall: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFAFAE6),
      ),
      bodyLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFFFAFAE6),
      ),
      bodyMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFFFAFAE6),
      ),
      bodySmall: GoogleFonts.comicNeue(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: Color(0xFFD4C5B9),
      ),
      labelLarge: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFAFAE6),
      ),
      labelMedium: GoogleFonts.comicNeue(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFD4C5B9),
      ),
      labelSmall: GoogleFonts.comicNeue(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFFD4C5B9),
      ),
    ),
  );
}
