import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../controllers/project_controller.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: AppColors.surfaceLight),
        onPressed: () {
          ref.read(projectsControllerProvider.notifier).createProject(
                'Data Center Migration',
                'Migrate all legacy servers to cloud',
              );
        },
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacing24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: AppSizes.spacing16),
                    Text('Project Management', style: AppTextStyles.displayMedium),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: projectsState.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (projects) {
                    if (projects.isEmpty) {
                      return const Center(child: Text('No projects found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24, vertical: AppSizes.spacing8),
                      itemCount: projects.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacing16),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return GlassmorphicContainer(
                          padding: const EdgeInsets.all(AppSizes.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    project.projectRef,
                                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentGreen),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                      border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(project.status.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen)),
                                  )
                                ],
                              ),
                              const SizedBox(height: AppSizes.spacing8),
                              Text(
                                project.title,
                                style: AppTextStyles.titleLarge,
                              ),
                              if (project.description != null) ...[
                                const SizedBox(height: AppSizes.spacing8),
                                Text(project.description!, style: AppTextStyles.bodyMedium),
                              ],
                              const SizedBox(height: AppSizes.spacing12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(project.createdAt.toString().substring(0, 10), style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
