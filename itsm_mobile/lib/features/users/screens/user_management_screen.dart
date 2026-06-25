import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../controllers/user_controller.dart';
import '../models/user_profile.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(userControllerProvider);

    ref.listen<UsersState>(userControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        SnackbarUtils.showError(context, next.error!);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('User Management', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded, color: AppColors.textPrimary),
            tooltip: 'Import CSV',
            onPressed: usersState.isLoading ? null : () async {
              await ref.read(userControllerProvider.notifier).importCsv();
            },
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
                  borderRadius: AppSizes.radiusFull,
                  child: TextField(
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      icon: const Icon(Icons.search, color: AppColors.textHint),
                    ),
                    onChanged: (value) =>
                        ref.read(userControllerProvider.notifier).setSearchQuery(value),
                  ),
                ),
              ),
              if (usersState.isLoading && usersState.users.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow))),
              if (!usersState.isLoading && usersState.filteredUsers.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No users found',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
                    ),
                  ),
                ),
              if (usersState.filteredUsers.isNotEmpty)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.read(userControllerProvider.notifier).fetchUsers(),
                    color: AppColors.primaryYellow,
                    backgroundColor: AppColors.surfaceVariant,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing8),
                      itemCount: usersState.filteredUsers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.spacing12),
                      itemBuilder: (context, index) {
                        final user = usersState.filteredUsers[index];
                        return _buildUserCard(user)
                            .animate(delay: (100 * (index % 10)).ms)
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context, ref),
        backgroundColor: AppColors.primaryYellow,
        child: const Icon(Icons.person_add_rounded, color: AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceVariant,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryYellow),
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(user.phoneNumber, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                if (user.division != null && user.division!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(user.division!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentBlue)),
                ]
              ],
            ),
          ),
          Icon(
            user.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: user.isActive ? AppColors.success : AppColors.error,
            size: AppSizes.iconSmall,
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '628');
    final divCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
          title: Text('Add New User', style: AppTextStyles.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Full Name', hintText: 'John Doe'),
                ),
                const SizedBox(height: AppSizes.spacing12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'WhatsApp Number', hintText: '628...'),
                ),
                const SizedBox(height: AppSizes.spacing12),
                TextField(
                  controller: divCtrl,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Division (Optional)', hintText: 'IT Dept'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                if (name.isEmpty || phone.isEmpty) return;

                Navigator.pop(context);
                await ref.read(userControllerProvider.notifier).createUser({
                  'full_name': name,
                  'phone_number': phone,
                  'division': divCtrl.text.trim().isEmpty ? null : divCtrl.text.trim(),
                  'is_active': true,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: AppColors.textPrimary),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
