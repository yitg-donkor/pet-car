import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================================================
  // BRAND COLORS
  // ============================================================
  // Sky-blue / navy palette based on the redesign mockups:
  // bright cyan-blue header with white wave, teal-green for positive
  // status ("Fed", "All good", completed checks), amber for "Due",
  // and deep navy for ink/text + pressed states. Same brand colors
  // are shared across light and dark themes to match the mockups,
  // where the header stays sky-blue in both variants.

  static const Color primaryPeach = Color(0xFF41C1E8);
  static const Color accentCream = Color(0xFFF3FAFD);
  static const Color softBlue = Color(0xFFCDEFFB);
  static const Color sageGreen = Color(0xFF2FB79E);
  static const Color warmBrown = Color(0xFF16323F);

  // ============================================================
  // BUTTON COLORS
  // ============================================================

  static const Color lightButtonPeach = Color(0xFF41C1E8);
  static const Color lightButtonOrange = Color(0xFFF2A93B);
  static const Color lightButtonGreen = Color(0xFF2FB79E);

  // Dark theme button colors.
  // Variable names are preserved so existing references do not break.
  static const Color darkButtonBurgundy = Color(0xFF41C1E8);
  static const Color darkButtonPurple = Color(0xFF8176D6);
  static const Color darkButtonTeal = Color(0xFF2FB79E);

  // ============================================================
  // SEMANTIC COLORS
  // ============================================================

  static const Color success = Color(0xFF2FB79E);
  static const Color warning = Color(0xFFF2A93B);
  static const Color error = Color(0xFFE06F6F);
  static const Color info = Color(0xFF41C1E8);

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================
  // Pale, airy page background with white cards, matching the
  // "Good morning, Sarah" / pet card mockups.

  static const Color lightBackground = Color(0xFFEAF6FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFF3FAFD);
  static const Color lightTextPrimary = Color(0xFF122430);
  static const Color lightTextSecondary = Color(0xFF55717F);

  // ============================================================
  // DARK THEME COLORS
  // ============================================================
  // Deep navy background with slate-blue cards, matching the
  // dark "Reminders" mockup — same sky-blue header carries over.

  static const Color darkBackground = Color(0xFF0A1B29);
  static const Color darkSurface = Color(0xFF12283B);
  static const Color darkCardBackground = Color(0xFF1B3349);
  static const Color darkTextPrimary = Color(0xFFEFF7FB);
  static const Color darkTextSecondary = Color(0xFF7CA3BE);

  // ============================================================
  // TYPOGRAPHY
  // ============================================================
  // Nunito (weight 900) for display/headline text — rounded, bold,
  // matches the mockup's heavy heading weight ("Good morning, Sarah",
  // "Reminders"). DM Sans for body/UI text — clean geometric sans
  // used for everything else (labels, buttons, card text, hints).

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.dmSans().fontFamily,

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

    // ============================================================
    // APP BAR
    // ============================================================
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        color: lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),

    // ============================================================
    // CARDS
    // ============================================================
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ============================================================
    // ELEVATED BUTTON
    // ============================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightButtonPeach,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ============================================================
    // TEXT BUTTON
    // ============================================================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: warmBrown,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ============================================================
    // OUTLINED BUTTON
    // ============================================================
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: warmBrown,
        side: const BorderSide(color: warmBrown, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    // ============================================================
    // INPUT FIELDS
    // ============================================================
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

      hintStyle: GoogleFonts.dmSans(
        color: lightTextSecondary.withOpacity(0.6),
      ),
    ),

    // ============================================================
    // FLOATING ACTION BUTTON
    // ============================================================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPeach,
      foregroundColor: lightTextPrimary,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // ============================================================
    // BOTTOM NAVIGATION
    // ============================================================
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: accentCream,
      selectedItemColor: warmBrown,
      unselectedItemColor: lightTextSecondary.withOpacity(0.5),

      selectedLabelStyle: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),

      unselectedLabelStyle: GoogleFonts.dmSans(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),

      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),

    // ============================================================
    // CHIPS
    // ============================================================
    chipTheme: ChipThemeData(
      backgroundColor: accentCream,
      selectedColor: primaryPeach,

      labelStyle: GoogleFonts.dmSans(color: lightTextPrimary),

      secondaryLabelStyle: GoogleFonts.dmSans(color: lightTextPrimary),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      elevation: 0,
    ),

    // ============================================================
    // DIALOG
    // ============================================================
    dialogTheme: DialogThemeData(
      backgroundColor: lightSurface,
      elevation: 8,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      titleTextStyle: GoogleFonts.nunito(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),

    // ============================================================
    // SNACKBAR
    // ============================================================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: warmBrown,

      contentTextStyle: GoogleFonts.dmSans(color: Colors.white),

      behavior: SnackBarBehavior.floating,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ============================================================
    // PROGRESS INDICATOR
    // ============================================================
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: warmBrown),

    // ============================================================
    // SWITCH
    // ============================================================
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return warmBrown;
        }

        return lightTextSecondary;
      }),

      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xFF9DDCF0);
        }

        return lightSurface;
      }),
    ),

    // ============================================================
    // SLIDER
    // ============================================================
    sliderTheme: SliderThemeData(
      activeTrackColor: warmBrown,
      inactiveTrackColor: lightSurface,
      thumbColor: warmBrown,
      overlayColor: warmBrown.withOpacity(0.2),
    ),

    // ============================================================
    // DIVIDER
    // ============================================================
    dividerTheme: DividerThemeData(
      color: lightTextSecondary.withOpacity(0.2),
      thickness: 1,
      space: 16,
    ),

    // ============================================================
    // ICONS
    // ============================================================
    iconTheme: IconThemeData(color: lightTextSecondary, size: 24),

    // ============================================================
    // TEXT THEME
    // ============================================================
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: lightTextPrimary,
        letterSpacing: -0.5,
      ),

      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: lightTextPrimary,
      ),

      displaySmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: lightTextPrimary,
      ),

      headlineLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: lightTextPrimary,
      ),

      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: lightTextPrimary,
      ),

      headlineSmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: lightTextPrimary,
      ),

      titleLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),

      titleMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),

      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),

      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),

      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),

      bodySmall: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: lightTextSecondary,
      ),

      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),

      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: lightTextSecondary,
      ),

      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: lightTextSecondary,
      ),
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.dmSans().fontFamily,

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

    // ============================================================
    // APP BAR
    // ============================================================
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: false,

      titleTextStyle: GoogleFonts.nunito(
        color: darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),

      iconTheme: IconThemeData(color: darkTextPrimary),
    ),

    // ============================================================
    // CARDS
    // ============================================================
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ============================================================
    // ELEVATED BUTTON
    // ============================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkButtonBurgundy,
        foregroundColor: accentCream,
        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ============================================================
    // TEXT BUTTON
    // ============================================================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkTextSecondary,

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        textStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ============================================================
    // OUTLINED BUTTON
    // ============================================================
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrimary,

        side: BorderSide(color: darkTextSecondary, width: 1.5),

        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    // ============================================================
    // INPUT FIELDS
    // ============================================================
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

      hintStyle: GoogleFonts.dmSans(
        color: darkTextSecondary.withOpacity(0.5),
      ),
    ),

    // ============================================================
    // FLOATING ACTION BUTTON
    // ============================================================
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkButtonBurgundy,
      foregroundColor: accentCream,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // ============================================================
    // BOTTOM NAVIGATION
    // ============================================================
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCardBackground,

      selectedItemColor: primaryPeach,

      unselectedItemColor: darkTextSecondary.withOpacity(0.5),

      selectedLabelStyle: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),

      unselectedLabelStyle: GoogleFonts.dmSans(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),

      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),

    // ============================================================
    // CHIPS
    // ============================================================
    chipTheme: ChipThemeData(
      backgroundColor: darkSurface,
      selectedColor: darkButtonBurgundy,

      labelStyle: GoogleFonts.dmSans(color: darkTextPrimary),

      secondaryLabelStyle: GoogleFonts.dmSans(color: accentCream),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      elevation: 0,
    ),

    // ============================================================
    // DIALOG
    // ============================================================
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      elevation: 8,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      titleTextStyle: GoogleFonts.nunito(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),

    // ============================================================
    // SNACKBAR
    // ============================================================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardBackground,

      contentTextStyle: GoogleFonts.dmSans(color: darkTextPrimary),

      behavior: SnackBarBehavior.floating,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ============================================================
    // PROGRESS INDICATOR
    // ============================================================
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: darkButtonBurgundy,
    ),

    // ============================================================
    // SWITCH
    // ============================================================
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkButtonBurgundy;
        }

        return darkTextSecondary;
      }),

      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF6BAEC5).withOpacity(0.5);
        }

        return darkSurface;
      }),
    ),

    // ============================================================
    // SLIDER
    // ============================================================
    sliderTheme: SliderThemeData(
      activeTrackColor: darkButtonBurgundy,
      inactiveTrackColor: darkSurface,
      thumbColor: darkButtonBurgundy,
      overlayColor: darkButtonBurgundy.withOpacity(0.2),
    ),

    // ============================================================
    // DIVIDER
    // ============================================================
    dividerTheme: DividerThemeData(
      color: darkTextSecondary.withOpacity(0.2),
      thickness: 1,
      space: 16,
    ),

    // ============================================================
    // ICONS
    // ============================================================
    iconTheme: IconThemeData(color: darkTextSecondary, size: 24),

    // ============================================================
    // TEXT THEME
    // ============================================================
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: darkTextPrimary,
        letterSpacing: -0.5,
      ),

      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: darkTextPrimary,
      ),

      displaySmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: darkTextPrimary,
      ),

      headlineLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: darkTextPrimary,
      ),

      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: darkTextPrimary,
      ),

      headlineSmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: darkTextPrimary,
      ),

      titleLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),

      titleMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),

      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),

      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),

      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),

      bodySmall: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),

      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),

      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: darkTextSecondary,
      ),

      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: darkTextSecondary,
      ),
    ),
  );
}