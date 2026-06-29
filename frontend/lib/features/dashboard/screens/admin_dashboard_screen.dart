import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.displayName
        : 'Admin';

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Admin,',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                          Text(
                            userName,
                            style: AppTextStyles.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GlassmorphicContainer(
                      padding: const EdgeInsets.all(AppSizes.spacing8),
                      borderRadius: AppSizes.radiusMedium,
                      onTap: () {
                        ref.read(authControllerProvider.notifier).signOut();
                      },
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.textSecondary,
                        size: AppSizes.iconDefault,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.spacing32),
                
                Text('Admin Actions', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSizes.spacing16),
                
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(AppSizes.spacing20),
                  onTap: () => context.push('/users'),
                  child: Row(
                    children: [
                      const Icon(Icons.manage_accounts_rounded, color: AppColors.primaryYellow, size: AppSizes.iconLarge),
                      const SizedBox(width: AppSizes.spacing16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Manage Users', style: AppTextStyles.titleMedium),
                          Text('Add, edit, or deactivate staff roles', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spacing16),
                
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(AppSizes.spacing20),
                  onTap: () => context.push('/service-catalog'),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppColors.accentPurple, size: AppSizes.iconLarge),
                      const SizedBox(width: AppSizes.spacing16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Service Catalog', style: AppTextStyles.titleMedium),
                          Text('Manage ITSM Service Catalog', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
