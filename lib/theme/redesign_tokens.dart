// theme/redesign_tokens.dart
//
// Design tokens for the visual redesign (starting with Home + AI screens).
// Kept separate from theme/app_theme.dart deliberately - the existing
// ThemeData drives Material widgets app-wide (buttons, AppBars, etc.) and
// changing it would touch every screen at once. These are additive
// constants for the specific new layouts, close in spirit to the existing
// warm/cream palette but with a punchier accent to match the reference
// design. As more screens get redesigned, this file is the place to keep
// adding to rather than duplicating hex values per-screen.
import 'package:flutter/material.dart';

class RedesignColors {
  RedesignColors._();

  static const Color background = Color(0xFFFAF3E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFDF8F0);

  // Primary accent - warm coral/orange. Used for progress fill, active nav,
  // primary CTAs, "due" states.
  static const Color accent = Color(0xFFE8734F);
  static const Color accentSoft = Color(0xFFF6D9C9);

  static const Color success = Color(0xFF6FAE7C);
  static const Color successSoft = Color(0xFFDCEEE0);

  static const Color due = Color(0xFFE0A32E);
  static const Color dueSoft = Color(0xFFF3DFC0);

  static const Color premium = Color(0xFF8B7FC7);
  static const Color premiumSoft = Color(0xFFEAE6F7);

  static const Color textPrimary = Color(0xFF2B241C);
  static const Color textSecondary = Color(0xFF7A6F60);
  static const Color textMuted = Color(0xFFAFA495);

  static const Color chatCardDark = Color(0xFF2B2019);

  static const Color border = Color(0xFFF0E5D6);
}

class RedesignSpacing {
  RedesignSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const double cardRadius = 20;
  static const double chipRadius = 14;
  static const double pillRadius = 100;
}
