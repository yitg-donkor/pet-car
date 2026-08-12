// widgets/widgets.dart
//
// Shared widget library for the sky-blue/cloud-wave design system (Home,
// AI Hub, Reminders, Pet Profile, Activity Log, Medical Records and beyond).
// Everything here is theme-aware: colors come from SkyColors.of(context)
// (theme/app_theme.dart), which resolves automatically based on
// Theme.of(context).brightness - build a screen with these and light/dark
// mode switching just works, no per-widget brightness checks needed.
//
// Typography: display/headline text uses Nunito at weight 900 (set via
// GoogleFonts.nunito or Theme.of(context).textTheme.headlineX, which
// AppTheme already wires to Nunito 900). Body/label text uses DM Sans
// (Theme.of(context).textTheme.bodyX / labelX, or GoogleFonts.dmSans
// directly when a one-off override is needed, e.g. text on the header
// where color needs to be white regardless of theme).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_care/theme/app_theme.dart';

// ============================================
// HEADER
// ============================================

/// The signature blue/navy header block with a cloud-wave bottom edge,
/// used at the top of every redesigned screen. Pass [child] for the
/// header's content (greeting, title, avatar, stats, progress bar - whatever
/// the screen needs); this widget only owns the background, wave shape, and
/// safe-area/padding handling.
class SkyHeader extends StatelessWidget {
  const SkyHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 32),
    this.waveHeight = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double waveHeight;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return ClipPath(
      clipper: _WaveBottomClipper(waveHeight: waveHeight),
      child: Container(
        width: double.infinity,
        color: sky.header,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: padding.copyWith(bottom: padding.bottom + waveHeight),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _WaveBottomClipper extends CustomClipper<Path> {
  _WaveBottomClipper({required this.waveHeight});

  final double waveHeight;

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - waveHeight);

    // Three gentle bumps across the width - the "cloud puff" bottom edge.
    final segment = size.width / 3;
    path.quadraticBezierTo(
      segment * 0.5,
      size.height,
      segment,
      size.height - waveHeight,
    );
    path.quadraticBezierTo(
      segment * 1.5,
      size.height - waveHeight * 2,
      segment * 2,
      size.height - waveHeight,
    );
    path.quadraticBezierTo(
      segment * 2.5,
      size.height,
      segment * 3,
      size.height - waveHeight,
    );

    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveBottomClipper oldClipper) =>
      oldClipper.waveHeight != waveHeight;
}

// ============================================
// AVATAR
// ============================================

/// Circular avatar showing [imageUrl] if provided, otherwise the first
/// letter of [fallbackText] on a tinted background.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  final String? imageUrl;
  final String fallbackText;
  final double radius;
  final Color? backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final initial =
        fallbackText.trim().isEmpty
            ? '?'
            : fallbackText.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? sky.header,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child:
          imageUrl == null
              ? Text(
                initial,
                style: GoogleFonts.nunito(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: radius * 0.8,
                ),
              )
              : null,
    );
  }
}

// ============================================
// STAT CHIP
// ============================================

enum SkyStatChipVariant { onHeader, onSurface }

/// A compact icon + value + label tile. [onHeader] renders translucent
/// white (for sitting directly on the blue/navy header), [onSurface]
/// renders as a normal themed card (for sitting in the page body).
class SkyStatChip extends StatelessWidget {
  const SkyStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.variant = SkyStatChipVariant.onSurface,
  });

  final IconData icon;
  final String value;
  final String label;
  final SkyStatChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final onHeader = variant == SkyStatChipVariant.onHeader;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onHeader ? Colors.white.withValues(alpha: 0.16) : sky.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            onHeader
                ? Border.all(color: Colors.white.withValues(alpha: 0.25))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: onHeader ? Colors.white : sky.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: onHeader ? Colors.white : sky.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color:
                  onHeader
                      ? Colors.white.withValues(alpha: 0.85)
                      : sky.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// STATUS PILL
// ============================================

enum SkyPillTone { success, due, premium, neutral }

/// Small rounded status label - "Fed", "Due", "PRO", category tags, etc.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = SkyPillTone.neutral,
    this.icon,
    this.filled = false,
  });

  final String label;
  final SkyPillTone tone;
  final IconData? icon;

  /// Filled = solid color background with white text (e.g. "DUE" badge on
  /// a reminder card). Not filled = soft tinted background (e.g. status
  /// pill on a pet card).
  final bool filled;

  (Color, Color) _colors(SkyColors sky) {
    switch (tone) {
      case SkyPillTone.success:
        return (SkyColors.success, sky.successSoft);
      case SkyPillTone.due:
        return (SkyColors.due, sky.dueSoft);
      case SkyPillTone.premium:
        return (SkyColors.premium, sky.premiumSoft);
      case SkyPillTone.neutral:
        return (sky.textSecondary, sky.border);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final (accent, soft) = _colors(sky);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? accent : soft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: filled ? Colors.white : accent),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "PRO" tag for gated premium features.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SkyColors.premium,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'PRO',
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================
// SECTION HEADER
// ============================================

/// Uppercase section label with an optional trailing action ("See all",
/// "+ Add", etc.).
class SkySectionHeader extends StatelessWidget {
  const SkySectionHeader({
    super.key,
    required this.label,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            color: sky.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon:
                actionIcon != null
                    ? Icon(actionIcon, size: 16, color: SkyColors.due)
                    : const SizedBox.shrink(),
            label: Text(
              actionLabel!,
              style: GoogleFonts.dmSans(
                color: SkyColors.due,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}

// ============================================
// CARD
// ============================================

/// Themed surface card - the base building block most other tiles/cards
/// in this file are built on top of. Use directly for custom card content
/// that doesn't fit one of the more specific widgets below.
class SkyCard extends StatelessWidget {
  const SkyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: sky.surface,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: card,
    );
  }
}

// ============================================
// PROGRESS BAR
// ============================================

/// Progress track. [onHeader] renders as a translucent-white track (for use
/// inside SkyHeader, e.g. "2 of 7 complete"), otherwise a normal themed
/// track.
class SkyProgressBar extends StatelessWidget {
  const SkyProgressBar({
    super.key,
    required this.progress,
    this.onHeader = false,
    this.height = 6,
  });

  /// 0.0 - 1.0
  final double progress;
  final bool onHeader;
  final double height;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor:
            onHeader ? Colors.white.withValues(alpha: 0.25) : sky.border,
        valueColor: AlwaysStoppedAnimation(
          onHeader ? Colors.white : SkyColors.due,
        ),
      ),
    );
  }
}

// ============================================
// BUTTONS
// ============================================

enum SkyButtonTone { primary, dark, premium }

/// Pill-shaped CTA button matching the mockup's rounded button language.
class SkyPillButton extends StatelessWidget {
  const SkyPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = SkyButtonTone.primary,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SkyButtonTone tone;
  final IconData? icon;
  final bool expand;

  Color _background(SkyColors sky) {
    switch (tone) {
      case SkyButtonTone.primary:
        return sky.header;
      case SkyButtonTone.dark:
        return sky.textPrimary;
      case SkyButtonTone.premium:
        return SkyColors.premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon:
          icon != null
              ? Icon(icon, size: 18, color: Colors.white)
              : const SizedBox.shrink(),
      label: Text(
        label,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _background(sky),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        elevation: 0,
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// ============================================
// FEATURE TILE
// ============================================

/// Icon + title + subtitle tile, used for grids of tappable features (AI
/// Hub's free/premium tool tiles). Set [isPro] to show a PRO badge.
class SkyFeatureTile extends StatelessWidget {
  const SkyFeatureTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPro = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return SkyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 22),
              if (isPro) const ProBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: sky.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(fontSize: 11, color: sky.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================
// DARK FEATURE CARD
// ============================================

/// The near-black "featured" card style (AI Vet Chat's card in the
/// mockups). Deliberately dark in BOTH light and dark theme - it's meant
/// to read as a strong, distinct accent block regardless of page mode, not
/// something that adapts with brightness.
class SkyDarkFeatureCard extends StatelessWidget {
  const SkyDarkFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.exampleText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? exampleText;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16202E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SkyColors.due,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (exampleText != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                exampleText!,
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SkyPillButton(label: buttonLabel, onPressed: onPressed, expand: true),
        ],
      ),
    );
  }
}

// ============================================
// TIMELINE ITEM
// ============================================

/// A single entry in a vertical timeline (Activity Log). Renders a
/// connecting spine line unless [isLast] is true.
class SkyTimelineItem extends StatelessWidget {
  const SkyTimelineItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.imageUrl,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String? imageUrl;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: sky.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: sky.border),
                ),
                child: Icon(icon, size: 16, color: sky.textSecondary),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: sky.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          color: sky.textPrimary,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: sky.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: sky.textSecondary,
                    ),
                  ),
                  if (imageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PET AVATAR CHIP (selector row)
// ============================================

/// Selectable pet chip - photo/initial avatar plus optional name label,
/// used for pet-selector rows (AI Hub) and similar horizontal pickers.
class SkyPetChip extends StatelessWidget {
  const SkyPetChip({
    super.key,
    required this.name,
    this.imageUrl,
    required this.selected,
    required this.onTap,
    this.showLabel = true,
  });

  final String name;
  final String? imageUrl;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 12 : 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: selected ? sky.header : sky.surface,
          borderRadius: BorderRadius.circular(100),
          border: selected ? null : Border.all(color: sky.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(
              imageUrl: imageUrl,
              fallbackText: name,
              radius: 12,
              backgroundColor:
                  selected ? Colors.white.withValues(alpha: 0.3) : sky.header,
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                name,
                style: GoogleFonts.dmSans(
                  color: selected ? Colors.white : sky.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// EMPTY STATE
// ============================================

/// Generic empty-state card - icon, title, subtitle. Used for "no
/// reminders today", "no pets yet", etc.
class SkyEmptyState extends StatelessWidget {
  const SkyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return SkyCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor ?? SkyColors.success),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              color: sky.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.dmSans(color: sky.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class SKyGradient extends StatelessWidget {
  const SKyGradient({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
