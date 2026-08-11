// theme/redesign_tokens.dart
//
// Design tokens for the visual redesign.
// Based on the new sky-blue / white reference design.
//
// These tokens are intentionally separate from app_theme.dart so the
// redesigned screens can be updated without changing the entire app theme.

import 'package:flutter/material.dart';

class RedesignColors {
  RedesignColors._();

  // ============================================================
  // BRAND / PRIMARY
  // ============================================================

  /// Main sky-blue used in the reference header and primary actions.
  static const Color primary = Color(0xFF5BC8F5);

  /// Slightly darker blue for active states and stronger emphasis.
  static const Color primaryDark = Color(0xFF38B4E8);

  /// Very light blue for selected/secondary UI elements.
  static const Color primarySoft = Color(0xFFEAF8FE);

  /// Translucent-looking blue used for progress backgrounds,
  /// chips and subtle highlights.
  static const Color primaryMuted = Color(0xFFD5F1FC);
  static const Color accent = Color(0xFF5BC8F5);
  static const Color accentSoft = Color(0xFFF6D9C9);



  // ============================================================
  // PAGE BACKGROUND
  // ============================================================

  /// Main background from the reference design.
  static const Color background = Color(0xFFC8E6F5);

  /// Slightly lighter background for sections.
  static const Color backgroundLight = Color(0xFFEAF7FC);

  /// Main white surface.
  static const Color surface = Color(0xFFFFFFFF);

  /// Very subtle blue-tinted surface.
  static const Color surfaceMuted = Color(0xFFF3FAFD);

  /// Surface used for cards that sit against the white content area.
  static const Color surfaceBlue = Color(0xFFEEF8FC);


  // ============================================================
  // TEXT
  // ============================================================

  /// Main headings and important text.
  static const Color textPrimary = Color(0xFF10202B);

  /// Secondary text.
  static const Color textSecondary = Color(0xFF55717F);

  /// Small labels / metadata.
  static const Color textMuted = Color(0xFF8BA5B2);

  /// Text displayed on primary blue backgrounds.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text used on very light blue backgrounds.
  static const Color textOnSoft = Color(0xFF244452);


  // ============================================================
  // SUCCESS / COMPLETED
  // ============================================================

  /// Green/teal used for completed care items.
  static const Color success = Color(0xFF55B7A7);

  /// Soft green background for completed states.
  static const Color successSoft = Color(0xFFE0F5F1);

  /// Darker success text.
  static const Color successDark = Color(0xFF358F83);


  // ============================================================
  // DUE / ATTENTION
  // ============================================================

  /// Warm orange retained from the original design,
  /// but used sparingly for due/attention states.
  static const Color due = Color(0xFFF2A93B);

  /// Soft orange background.
  static const Color dueSoft = Color(0xFFFFF1D8);

  /// Dark orange text for due labels.
  static const Color dueDark = Color(0xFFC77B13);


  // ============================================================
  // AI / PREMIUM
  // ============================================================

  /// Purple remains useful for AI/premium functionality.
  static const Color premium = Color(0xFF8176D6);

  /// Soft purple background.
  static const Color premiumSoft = Color(0xFFEDEBFA);

  /// AI sparkle accent.
  static const Color ai = Color(0xFF8D82E8);


  // ============================================================
  // NAVIGATION
  // ============================================================

  /// Active bottom navigation icon/text.
  static const Color navActive = Color(0xFF42B9EC);

  /// Inactive bottom navigation icons.
  static const Color navInactive = Color(0xFF8EA5B1);

  /// Bottom navigation background.
  static const Color navBackground = Color(0xFFFFFFFF);


  // ============================================================
  // BORDERS / DIVIDERS
  // ============================================================

  /// Very subtle blue-gray border.
  static const Color border = Color(0xFFD7EAF2);

  /// Stronger border for inputs/cards.
  static const Color borderStrong = Color(0xFFC5DFEA);

  /// Divider color.
  static const Color divider = Color(0xFFE4F0F5);


  // ============================================================
  // PROGRESS
  // ============================================================

  /// Progress track.
  static const Color progressTrack = Color(0xFFDDEFF7);

  /// Progress fill.
  static const Color progressFill = Color(0xFF5BC8F5);


  // ============================================================
  // SPECIAL DARK CARD
  // ============================================================

  /// Dark AI/chat card.
  static const Color chatCardDark = Color(0xFF172B36);

  /// Text used inside dark cards.
  static const Color chatText = Color(0xFFFFFFFF);

  /// Secondary text inside dark cards.
  static const Color chatTextMuted = Color(0xFFB7CBD4);
}


class RedesignSpacing {
  RedesignSpacing._();

  // ============================================================
  // SPACING
  // ============================================================

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;


  // ============================================================
  // CARD / COMPONENT RADII
  // ============================================================

  /// Main cards in the reference have soft rounded corners.
  static const double cardRadius = 16;

  /// Slightly smaller radius for compact components.
  static const double smallCardRadius = 12;

  /// Chips and small pills.
  static const double chipRadius = 14;

  /// Fully rounded pills.
  static const double pillRadius = 100;

  /// Buttons.
  static const double buttonRadius = 14;

  /// Input fields.
  static const double inputRadius = 14;
}