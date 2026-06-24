import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Primary CTA button with Yellow-Orange gradient.
///
/// Supports loading state, optional icon, and full-width expansion.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.gradient,
    this.height = AppSizes.buttonHeight,
    this.borderRadius = AppSizes.radiusMedium,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Gradient? gradient;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final isDisabled = isLoading || onPressed == null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width: isExpanded ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          gradient: isDisabled
              ? AppGradients.primaryMuted
              : (gradient ?? AppGradients.primary),
          borderRadius: radius,
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: radius,
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: isExpanded
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: AppSizes.iconMedium,
                              color: AppColors.textOnPrimary),
                          const SizedBox(width: AppSizes.spacing8),
                        ],
                        Text(label,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
