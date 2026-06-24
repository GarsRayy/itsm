import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_sizes.dart';

/// A highly reusable Glassmorphism container widget.
///
/// Implements the frosted-glass effect using [BackdropFilter] with
/// [ImageFilter.blur], semi-transparent fills, and subtle white borders.
///
/// ## Usage
/// ```dart
/// GlassmorphicContainer(
///   padding: EdgeInsets.all(AppSizes.spacing16),
///   child: Text('Hello Glass'),
/// )
/// ```
///
/// ## Customization
/// - [blurSigma]: Controls blur intensity (default: 12.0).
/// - [opacity]: Controls the white overlay opacity (default: 0.08).
/// - [borderRadius]: Corner rounding (default: 16.0).
/// - [gradient]: Override the default glass gradient for active states.
/// - [border]: Override the border color and width.
/// - [enableAnimation]: Add a subtle fade-in entrance animation.
class GlassmorphicContainer extends StatelessWidget {
  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blurSigma = AppSizes.glassBlurSigma,
    this.opacity = 0.08,
    this.borderRadius = AppSizes.radiusLarge,
    this.gradient,
    this.borderColor,
    this.borderWidth = AppSizes.glassBorderWidth,
    this.onTap,
  });

  /// The widget rendered inside the glass container.
  final Widget child;

  /// Inner padding applied to [child].
  final EdgeInsetsGeometry? padding;

  /// Outer margin around the container.
  final EdgeInsetsGeometry? margin;

  /// Fixed width. Defaults to available width if null.
  final double? width;

  /// Fixed height. Defaults to intrinsic height if null.
  final double? height;

  /// Blur intensity for the frosted glass effect.
  /// Higher values = more blur. Recommended range: 8–20.
  final double blurSigma;

  /// White overlay opacity (0.0–1.0). Default 0.08 for subtle glass.
  final double opacity;

  /// Corner radius. Defaults to [AppSizes.radiusLarge] (16dp).
  final double borderRadius;

  /// Optional gradient overlay. Useful for active/selected states.
  /// If null, the default [AppGradients.glass] is used.
  final Gradient? gradient;

  /// Border color. Defaults to [AppColors.glassBorder].
  final Color? borderColor;

  /// Border width. Defaults to [AppSizes.glassBorderWidth].
  final double borderWidth;

  /// Optional tap callback. When provided, adds ink splash feedback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? AppGradients.glass,
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: borderWidth,
              ),
            ),
            child: onTap != null
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: effectiveBorderRadius,
                      splashColor: AppColors.primaryYellow.withValues(alpha: 0.1),
                      highlightColor: AppColors.primaryYellow.withValues(alpha: 0.05),
                      child: Padding(
                        padding: padding ?? EdgeInsets.zero,
                        child: child,
                      ),
                    ),
                  )
                : Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
