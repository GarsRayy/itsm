import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Typography hierarchy using Plus Jakarta Sans.
///
/// All text styling in the app MUST reference these predefined styles.
/// Use `copyWith()` for minor one-off adjustments (e.g., color override),
/// but never create entirely new TextStyles in widgets.
abstract final class AppTextStyles {
  /// The base font family used throughout the app.
  static String get _fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  // ──────────────────────────────────────────────
  // Display — Hero sections, splash screens
  // ──────────────────────────────────────────────

  /// 32px, Bold — Dashboard main headers, hero numbers.
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  /// 28px, Bold — Secondary hero text.
  static TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.25,
      );

  // ──────────────────────────────────────────────
  // Headline — Section headers
  // ──────────────────────────────────────────────

  /// 24px, SemiBold — Section titles (e.g., "Recent Tickets").
  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  /// 20px, SemiBold — Sub-section headers.
  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ──────────────────────────────────────────────
  // Title — Card titles, list item headers
  // ──────────────────────────────────────────────

  /// 20px, SemiBold — Primary card titles.
  static TextStyle get titleLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  /// 16px, SemiBold — Secondary card titles, tab labels.
  static TextStyle get titleMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// 14px, SemiBold — Compact titles, chip labels.
  static TextStyle get titleSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // Body — Content text
  // ──────────────────────────────────────────────

  /// 16px, Regular — Primary body text.
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// 14px, Regular — Secondary body text, descriptions.
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// 12px, Regular — Tertiary text, timestamps.
  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.5,
      );

  // ──────────────────────────────────────────────
  // Label — Badges, captions, buttons
  // ──────────────────────────────────────────────

  /// 14px, Medium — Button labels.
  static TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
        height: 1.4,
      );

  /// 12px, Medium — Badge labels, status chips.
  static TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
        height: 1.4,
      );

  /// 10px, Medium — Tiny captions, superscript badges.
  static TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // Special — Metric numbers on dashboard
  // ──────────────────────────────────────────────

  /// 40px, Bold — Large metric values (e.g., "142" open tickets).
  static TextStyle get metricLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.1,
      );

  /// 24px, Bold — Medium metric values.
  static TextStyle get metricMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );
}
