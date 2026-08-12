import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Based on UI Analysis
  static const Color primaryPeach = Color(0xFF41C1E8);
  static const Color accentCream = Color(0xFFF3FAFD);
  static const Color softBlue = Color(0xFFCDEFFB);
  static const Color sageGreen = Color(0xFF2FB79E);
  static const Color warmBrown = Color(0xFF16323F);

  // Button Colors from UI
  static const Color lightButtonPeach = Color(0xFF41C1E8);
  static const Color lightButtonOrange = Color(0xFFF2A93B);
  static const Color lightButtonGreen = Color(0xFF2FB79E);

  static const Color darkButtonBurgundy = Color(0xFF41C1E8);
  static const Color darkButtonPurple = Color(0xFF8176D6);
  static const Color darkButtonTeal = Color(0xFF2FB79E);

  // Semantic Colors
  static const Color success = Color(0xFF2FB79E);
  static const Color warning = Color(0xFFF2A93B);
  static const Color error = Color(0xFFE06F6F);
  static const Color info = Color(0xFF41C1E8);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFEAF6FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFF3FAFD);
  static const Color lightTextPrimary = Color(0xFF122430);
  static const Color lightTextSecondary = Color(0xFF55717F);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0A1B29);
  static const Color darkSurface = Color(0xFF12283B);
  static const Color darkCardBackground = Color(0xFF1B3349);
  static const Color darkTextPrimary = Color(0xFFEFF7FB);
  static const Color darkTextSecondary = Color(0xFF7CA3BE);

  // ============================================
  // SKY / NAVY DESIGN SYSTEM
  // ============================================
  // Additive palette for the newer sky-blue-header / cloud-wave screens
  // (Home, AI Hub, Reminders, Pet Profile, Activity Log, Medical Records).
  // Kept separate from the ColorScheme.fromSeed roles above (primary,
  // background, etc.) deliberately - those roles drive every stock Material
  // widget across the whole app, and most screens haven't been redesigned
  // to this language yet. Widgets in widgets.dart read these directly based
  // on Theme.of(context).brightness rather than through ColorScheme, so
  // this rolls out screen-by-screen without destabilizing the rest of the
  // app mid-redesign.

  // Header / hero surface - the signature blue-wave block at the top of
  // each redesigned screen.
  static const Color skyHeaderLight = Color(0xFF4FB4DE);
  static const Color skyHeaderDark = Color(0xFF12213A);

  // Page background beneath the header.
  static const Color skyPageBackgroundLight = Color(0xFFF7FBFE);
  static const Color skyPageBackgroundDark = Color(0xFF0A1220);

  // Card / surface within the page body.
  static const Color skySurfaceLight = Color(0xFFFFFFFF);
  static const Color skySurfaceDark = Color(0xFF182A47);

  // Text on the page body (not on the header - use skyOnHeader* for that).
  static const Color skyTextPrimaryLight = Color(0xFF152238);
  static const Color skyTextPrimaryDark = Color(0xFFF3F6FB);
  static const Color skyTextSecondaryLight = Color(0xFF5C7086);
  static const Color skyTextSecondaryDark = Color(0xFF93A4BC);

  // Text/icons directly on the header (both modes use a light header
  // relative to their own content, so this stays constant).
  static const Color skyOnHeader = Colors.white;
  static const Color skyOnHeaderMuted = Color(0xCCFFFFFF); // 80% white

  // Status accents - shared between light and dark.
  static const Color skyDue = Color(0xFFF2A93B);
  static const Color skyDueSoft = Color(0xFFFBE6C4);
  static const Color skyDueSoftDark = Color(0x33F2A93B);
  static const Color skySuccess = Color(0xFF4CAF7D);
  static const Color skySuccessSoft = Color(0xFFDCF2E6);
  static const Color skySuccessSoftDark = Color(0x334CAF7D);
  static const Color skyPremium = Color(0xFF8C7FD1);
  static const Color skyPremiumSoft = Color(0xFFEAE6F9);
  static const Color skyPremiumSoftDark = Color(0x338C7FD1);
  static const Color skyBorderLight = Color(0xFFE7EEF5);
  static const Color skyBorderDark = Color(0xFF243352);

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
        textStyle: GoogleFonts.dmSans(
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
        textStyle: GoogleFonts.dmSans(
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
      hintStyle: GoogleFonts.dmSans(color: lightTextSecondary.withOpacity(0.6)),
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

    chipTheme: ChipThemeData(
      backgroundColor: accentCream,
      selectedColor: primaryPeach,
      labelStyle: GoogleFonts.dmSans(color: lightTextPrimary),
      secondaryLabelStyle: GoogleFonts.dmSans(color: lightTextPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),

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

    snackBarTheme: SnackBarThemeData(
      backgroundColor: warmBrown,
      contentTextStyle: GoogleFonts.dmSans(color: Colors.white),
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
        textStyle: GoogleFonts.dmSans(
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
        textStyle: GoogleFonts.dmSans(
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
      hintStyle: GoogleFonts.dmSans(color: darkTextSecondary.withOpacity(0.5)),
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

    chipTheme: ChipThemeData(
      backgroundColor: darkSurface,
      selectedColor: darkButtonBurgundy,
      labelStyle: GoogleFonts.dmSans(color: darkTextPrimary),
      secondaryLabelStyle: GoogleFonts.dmSans(color: accentCream),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),

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

    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardBackground,
      contentTextStyle: GoogleFonts.dmSans(color: darkTextPrimary),
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

/// Resolves the right sky/navy color for the current theme brightness, so
/// widgets don't repeat `Theme.of(context).brightness == Brightness.dark
/// ? X : Y` everywhere. Usage: `SkyColors.of(context).header`.
class SkyColors {
  const SkyColors._({
    required this.header,
    required this.pageBackground,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.dueSoft,
    required this.successSoft,
    required this.premiumSoft,
  });

  final Color header;
  final Color pageBackground;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color dueSoft;
  final Color successSoft;
  final Color premiumSoft;

  static const skyOnHeader = AppTheme.skyOnHeader;
  static const skyOnHeaderMuted = AppTheme.skyOnHeaderMuted;
  static const due = AppTheme.skyDue;
  static const success = AppTheme.skySuccess;
  static const premium = AppTheme.skyPremium;

  static SkyColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const SkyColors._(
          header: AppTheme.skyHeaderDark,
          pageBackground: AppTheme.skyPageBackgroundDark,
          surface: AppTheme.skySurfaceDark,
          textPrimary: AppTheme.skyTextPrimaryDark,
          textSecondary: AppTheme.skyTextSecondaryDark,
          border: AppTheme.skyBorderDark,
          dueSoft: AppTheme.skyDueSoftDark,
          successSoft: AppTheme.skySuccessSoftDark,
          premiumSoft: AppTheme.skyPremiumSoftDark,
        )
        : const SkyColors._(
          header: AppTheme.skyHeaderLight,
          pageBackground: AppTheme.skyPageBackgroundLight,
          surface: AppTheme.skySurfaceLight,
          textPrimary: AppTheme.skyTextPrimaryLight,
          textSecondary: AppTheme.skyTextSecondaryLight,
          border: AppTheme.skyBorderLight,
          dueSoft: AppTheme.skyDueSoft,
          successSoft: AppTheme.skySuccessSoft,
          premiumSoft: AppTheme.skyPremiumSoft,
        );
  }
}
