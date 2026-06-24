import 'dart:ui';

/// Centralized color palette for the ITSM app.
///
/// All colors used across the application MUST be referenced from this class.
/// Direct color literals in widgets are strictly prohibited to enforce DRY.
abstract final class AppColors {
  // ──────────────────────────────────────────────
  // Background & Surface (Dark Mode)
  // ──────────────────────────────────────────────

  /// Deepest background layer — used for Scaffold backgrounds.
  static const Color backgroundDark = Color(0xFF0A0E21);

  /// Slightly lighter surface — used for cards and elevated surfaces.
  static const Color surfaceDark = Color(0xFF141A2E);

  /// Mid-tone surface for secondary containers.
  static const Color surfaceVariant = Color(0xFF1C2340);

  // ──────────────────────────────────────────────
  // Glassmorphism Tokens
  // ──────────────────────────────────────────────

  /// Glass fill — semi-transparent white overlay.
  static const Color glassFill = Color(0x14FFFFFF); // ~8% white

  /// Glass border — subtle white edge for frosted containers.
  static const Color glassBorder = Color(0x26FFFFFF); // ~15% white

  /// Glass highlight — top-edge shine for depth illusion.
  static const Color glassHighlight = Color(0x0DFFFFFF); // ~5% white

  // ──────────────────────────────────────────────
  // Primary Gradient Anchors (Yellow → Orange)
  // ──────────────────────────────────────────────

  /// Gradient start — vibrant yellow.
  static const Color primaryYellow = Color(0xFFFFB800);

  /// Gradient end — vibrant orange.
  static const Color primaryOrange = Color(0xFFFF6A00);

  /// Muted primary for disabled states.
  static const Color primaryMuted = Color(0x66FFB800); // 40% yellow

  // ──────────────────────────────────────────────
  // Accent Colors
  // ──────────────────────────────────────────────

  /// Red accent — High Priority, Open, Overdue badges.
  static const Color accentRed = Color(0xFFFF3B5C);

  /// Blue accent — Informative elements, secondary highlights.
  static const Color accentBlue = Color(0xFF3B82F6);

  /// Green accent — Success, Resolved, Completed states.
  static const Color accentGreen = Color(0xFF10B981);

  /// Purple accent — Mesh gradient orb, decorative use.
  static const Color accentPurple = Color(0xFF8B5CF6);

  // ──────────────────────────────────────────────
  // Text Colors
  // ──────────────────────────────────────────────

  /// Primary text — maximum contrast on dark backgrounds.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text — body copy, descriptions.
  static const Color textSecondary = Color(0xB3FFFFFF); // ~70% white

  /// Hint text — placeholders, disabled labels.
  static const Color textHint = Color(0x61FFFFFF); // ~38% white

  /// Inverse text — for use on light/gradient backgrounds.
  static const Color textOnPrimary = Color(0xFF0A0E21);

  // ──────────────────────────────────────────────
  // Semantic / Status Colors
  // ──────────────────────────────────────────────

  /// Error / Critical.
  static const Color error = accentRed;

  /// Warning — approaching SLA, needs attention.
  static const Color warning = Color(0xFFFBBF24);

  /// Info — neutral informational badges.
  static const Color info = accentBlue;

  /// Success — resolved, completed.
  static const Color success = accentGreen;

  // ──────────────────────────────────────────────
  // Dividers & Borders
  // ──────────────────────────────────────────────

  /// Subtle divider on dark surfaces.
  static const Color divider = Color(0x1AFFFFFF); // ~10% white
}
