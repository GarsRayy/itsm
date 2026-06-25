import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

/// Glassmorphic login screen.
///
/// Features a frosted-glass card over the animated mesh background,
/// with staggered entrance animations and real-time validation.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    // Listen for auth errors and show snackbar.
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        SnackbarUtils.showError(context, next.message);
        // Reset to unauthenticated so the user can retry.
        ref.read(authControllerProvider.notifier).resetToUnauthenticated();
      }
    });

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo & Header ─────────────────
                  _buildHeader(),
                  const SizedBox(height: AppSizes.spacing32),

                  // ── Login Card ────────────────────
                  _buildLoginCard(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo icon with gradient background
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            size: 36,
            color: AppColors.textOnPrimary,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.0, 1.0),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 300.ms),

        const SizedBox(height: AppSizes.spacing20),

        // Title
        Text(
          AppStrings.loginTitle,
          style: AppTextStyles.displayMedium,
        )
            .animate(delay: 150.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: AppSizes.spacing8),

        // Subtitle
        Text(
          AppStrings.loginSubtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          textAlign: TextAlign.center,
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildLoginCard(bool isLoading) {
    return GlassmorphicContainer(
      borderRadius: AppSizes.radiusXXLarge,
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email field
            Text('Email', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.spacing8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: AppStrings.emailHint,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.textHint,
                  size: AppSizes.iconMedium,
                ),
              ),
              validator: _validateEmail,
            ),

            const SizedBox(height: AppSizes.spacing20),

            // Password field
            Text('Password', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.spacing8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              style: AppTextStyles.bodyLarge,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                hintText: AppStrings.passwordHint,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textHint,
                  size: AppSizes.iconMedium,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textHint,
                    size: AppSizes.iconMedium,
                  ),
                ),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: AppSizes.spacing12),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : _showForgotPasswordDialog,
                  child: Text(
                  AppStrings.forgotPassword,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacing24),

            // Sign In button
            GradientButton(
              label: AppStrings.signInButton,
              icon: Icons.login_rounded,
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleLogin,
            ),
          ],
        ),
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          title: Text('Reset Password', style: AppTextStyles.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address to receive a password reset link.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSizes.spacing16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                  hintText: AppStrings.emailHint,
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;
                Navigator.pop(context); // close dialog

                try {
                  await ref.read(authControllerProvider.notifier).resetPassword(email);
                  if (context.mounted) {
                    SnackbarUtils.showSuccess(context, 'Password reset link sent to $email');
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackbarUtils.showError(context, 'Failed to send reset link.');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // Validators
  // ──────────────────────────────────────────────

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
