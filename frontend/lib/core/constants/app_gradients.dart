import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Centralized gradient definitions for the ITSM design system.
///
/// Use these constants instead of creating inline gradients in widgets.
abstract final class AppGradients {
  // ──────────────────────────────────────────────
  // Primary (Yellow → Orange)
  // ──────────────────────────────────────────────

  /// Main action gradient — buttons, active card accents, navigation highlights.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryYellow, AppColors.primaryOrange],
  );

  /// Horizontal variant for wide elements (app bars, banners).
  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryYellow, AppColors.primaryOrange],
  );

  /// Muted version for disabled/inactive gradient elements.
  static const LinearGradient primaryMuted = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x66FFB800), // 40% yellow
      Color(0x66FF6A00), // 40% orange
    ],
  );

  // ──────────────────────────────────────────────
  // Background / Mesh
  // ──────────────────────────────────────────────

  /// Soft warm gradient for scaffold backgrounds (Light Mode).
  static const LinearGradient backgroundLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBF7),
      Color(0xFFFFF0E6),
      Color(0xFFFFE4D6),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ──────────────────────────────────────────────
  // Glass Surfaces (Light Mode)
  // ──────────────────────────────────────────────

  /// Subtle top-to-bottom white fade for glass containers.
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCCFFFFFF), // ~80%
      Color(0x99FFFFFF), // ~60%
    ],
  );

  /// Slightly more opaque glass for elevated/active states.
  static const LinearGradient glassElevated = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xE6FFFFFF), // ~90%
      Color(0xCCFFFFFF), // ~80%
    ],
  );

  // ──────────────────────────────────────────────
  // Status / Semantic
  // ──────────────────────────────────────────────

  /// Danger gradient — overdue tickets, critical alerts.
  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF3B5C),
      Color(0xFFE11D48),
    ],
  );

  /// Success gradient — resolved indicators.
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  /// Info gradient — informational badges.
  static const LinearGradient info = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
  );
}
