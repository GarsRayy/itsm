/// Spacing, sizing, and radius constants based on an 8dp grid system.
///
/// All layout values (padding, margin, gap, radius) MUST reference
/// these tokens. No magic numbers in widget trees.
abstract final class AppSizes {
  // ──────────────────────────────────────────────
  // Spacing (8dp grid)
  // ──────────────────────────────────────────────

  /// 2dp — hairline gaps.
  static const double spacing2 = 2.0;

  /// 4dp — tight inner padding.
  static const double spacing4 = 4.0;

  /// 8dp — standard minimum spacing.
  static const double spacing8 = 8.0;

  /// 12dp — compact section gaps.
  static const double spacing12 = 12.0;

  /// 16dp — default content padding.
  static const double spacing16 = 16.0;

  /// 20dp — comfortable section spacing.
  static const double spacing20 = 20.0;

  /// 24dp — generous gaps between major sections.
  static const double spacing24 = 24.0;

  /// 32dp — large section separators.
  static const double spacing32 = 32.0;

  /// 40dp — extra-large spacing (screen edges on tablets).
  static const double spacing40 = 40.0;

  /// 48dp — hero section spacing.
  static const double spacing48 = 48.0;

  /// 64dp — maximum spacing token.
  static const double spacing64 = 64.0;

  // ──────────────────────────────────────────────
  // Border Radius
  // ──────────────────────────────────────────────

  /// 8dp — subtle rounding (chips, small badges).
  static const double radiusSmall = 8.0;

  /// 12dp — standard card rounding.
  static const double radiusMedium = 12.0;

  /// 16dp — prominent rounding (glassmorphic containers).
  static const double radiusLarge = 16.0;

  /// 20dp — modal/sheet rounding.
  static const double radiusXLarge = 20.0;

  /// 24dp — hero card rounding.
  static const double radiusXXLarge = 24.0;

  /// Full circle — avatars, FABs.
  static const double radiusFull = 999.0;

  // ──────────────────────────────────────────────
  // Icon Sizes
  // ──────────────────────────────────────────────

  /// 16dp — inline/tiny icons.
  static const double iconSmall = 16.0;

  /// 20dp — standard action icons.
  static const double iconMedium = 20.0;

  /// 24dp — default Material icon size.
  static const double iconDefault = 24.0;

  /// 32dp — prominent icons (nav bar, headers).
  static const double iconLarge = 32.0;

  /// 48dp — hero/feature icons.
  static const double iconXLarge = 48.0;

  // ──────────────────────────────────────────────
  // Component Heights
  // ──────────────────────────────────────────────

  /// Standard button height.
  static const double buttonHeight = 52.0;

  /// Standard text input height.
  static const double inputHeight = 52.0;

  /// App bar height.
  static const double appBarHeight = 64.0;

  /// Bottom navigation bar height.
  static const double bottomNavHeight = 72.0;

  /// Card minimum height for dashboard metric cards.
  static const double metricCardHeight = 100.0;

  // ──────────────────────────────────────────────
  // Glassmorphism Defaults
  // ──────────────────────────────────────────────

  /// Default blur sigma for glass effect.
  static const double glassBlurSigma = 12.0;

  /// Default glass border width.
  static const double glassBorderWidth = 1.0;
}
