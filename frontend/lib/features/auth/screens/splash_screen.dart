import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../controllers/auth_controller.dart';

/// Splash screen shown on app launch.
///
/// Performs the initial auth check and redirects to:
/// - Login screen (unauthenticated)
/// - Leader/Executor dashboard (authenticated, based on role)
///
/// The router handles the actual redirect — this screen just
/// triggers [AuthController.checkAuthStatus] and shows a
/// branded loading animation.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated logo icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 40,
                  color: AppColors.textOnPrimary,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppSizes.spacing24),

              // App name
              Text(
                'ITSM',
                style: AppTextStyles.displayLarge.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w800,
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: AppSizes.spacing4),

              // Tagline
              Text(
                'IT Service Management',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                  letterSpacing: 1.5,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: AppSizes.spacing48),

              // Loading indicator
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryYellow.withValues(alpha: 0.7),
                  ),
                ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
