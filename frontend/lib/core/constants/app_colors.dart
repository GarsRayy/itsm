import 'dart:ui';

/// Centralized color palette for the ITSM app.
///
/// All colors used across the application MUST be referenced from this class.
/// Direct color literals in widgets are strictly prohibited to enforce DRY.
abstract final class AppColors {
  // Background & Surface (Light Mode)
  // ──────────────────────────────────────────────

  /// Deepest background layer — used for Scaffold backgrounds.
  static const Color backgroundLight = Color(0xFFFFF8F0);

  /// Slightly lighter surface — used for cards and elevated surfaces.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Mid-tone surface for secondary containers.
  static const Color surfaceVariant = Color(0xFFFFF0E5);

  // ──────────────────────────────────────────────
  // Glassmorphism Tokens (Light Mode)
  // ──────────────────────────────────────────────

  /// Glass fill — semi-transparent white overlay.
  static const Color glassFill = Color(0xB3FFFFFF); // ~70% white

  /// Glass border — subtle orange edge for frosted containers.
  static const Color glassBorder = Color(0x33FF6A00); // ~20% orange

  /// Glass highlight — top-edge shine for depth illusion.
  static const Color glassHighlight = Color(0x80FFFFFF); // ~50% white

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
  static const Color accentRed = Color(0xFFE11D48);

  /// Blue accent — Informative elements, secondary highlights.
  static const Color accentBlue = Color(0xFF2563EB);

  /// Green accent — Success, Resolved, Completed states.
  static const Color accentGreen = Color(0xFF059669);

  /// Purple accent — Mesh gradient orb, decorative use.
  static const Color accentPurple = Color(0xFF8B5CF6);

  // ──────────────────────────────────────────────
  // Text Colors (Light Mode)
  // ──────────────────────────────────────────────

  /// Primary text — maximum contrast on light backgrounds.
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary text — body copy, descriptions.
  static const Color textSecondary = Color(0xFF475569); 

  /// Hint text — placeholders, disabled labels.
  static const Color textHint = Color(0xFF94A3B8); 

  /// Inverse text — for use on primary/gradient backgrounds.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ──────────────────────────────────────────────
  // Semantic / Status Colors
  // ──────────────────────────────────────────────

  /// Error / Critical.
  static const Color error = accentRed;

  /// Warning — approaching SLA, needs attention.
  static const Color warning = Color(0xFFD97706);

  /// Info — neutral informational badges.
  static const Color info = accentBlue;

  /// Success — resolved, completed.
  static const Color success = accentGreen;

  // ──────────────────────────────────────────────
  // Dividers & Borders
  // ──────────────────────────────────────────────

  /// Subtle divider on light surfaces.
  static const Color divider = Color(0x1A000000); // ~10% black
}
