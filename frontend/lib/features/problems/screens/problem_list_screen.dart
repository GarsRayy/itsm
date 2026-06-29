import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../controllers/problem_controller.dart';

class ProblemListScreen extends ConsumerWidget {
  const ProblemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsState = ref.watch(problemsControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.add, color: AppColors.surfaceLight),
        onPressed: () {
          ref.read(problemsControllerProvider.notifier).createProblem(
                'New Root Cause Analysis',
                'Network switch failure in HQ',
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
                    Text('Problem Management', style: AppTextStyles.displayMedium),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: problemsState.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (problems) {
                    if (problems.isEmpty) {
                      return const Center(child: Text('No problems found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24, vertical: AppSizes.spacing8),
                      itemCount: problems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacing16),
                      itemBuilder: (context, index) {
                        final problem = problems[index];
                        return GlassmorphicContainer(
                          padding: const EdgeInsets.all(AppSizes.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    problem.problemRef,
                                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryOrange),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                      border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(problem.status.replaceAll('_', ' '), style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryOrange)),
                                  )
                                ],
                              ),
                              const SizedBox(height: AppSizes.spacing8),
                              Text(
                                problem.title,
                                style: AppTextStyles.titleLarge,
                              ),
                              if (problem.rootCause != null) ...[
                                const SizedBox(height: AppSizes.spacing8),
                                Text('RCA: \${problem.rootCause}', style: AppTextStyles.bodyMedium),
                              ],
                              const SizedBox(height: AppSizes.spacing12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(problem.createdAt.toString().substring(0, 10), style: AppTextStyles.bodySmall),
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
