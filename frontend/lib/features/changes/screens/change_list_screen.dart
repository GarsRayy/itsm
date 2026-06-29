import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../controllers/change_controller.dart';

class ChangeListScreen extends ConsumerWidget {
  const ChangeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changesState = ref.watch(changesControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        child: const Icon(Icons.add, color: AppColors.surfaceLight),
        onPressed: () {
          _showCreateChangeModal(context, ref);
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
                    Text('Change Management', style: AppTextStyles.displayMedium),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: changesState.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (changes) {
                    if (changes.isEmpty) {
                      return const Center(child: Text('No change requests found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24, vertical: AppSizes.spacing8),
                      itemCount: changes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacing16),
                      itemBuilder: (context, index) {
                        final change = changes[index];
                        return GlassmorphicContainer(
                          padding: const EdgeInsets.all(AppSizes.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    change.changeRef,
                                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentBlue),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                      border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(change.subclass, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentBlue)),
                                  )
                                ],
                              ),
                              const SizedBox(height: AppSizes.spacing8),
                              Text(
                                change.title,
                                style: AppTextStyles.titleLarge,
                              ),
                              const SizedBox(height: AppSizes.spacing12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(change.createdAt.toString().substring(0, 10), style: AppTextStyles.bodyMedium),
                                  const Spacer(),
                                  Text(change.status.replaceAll('_', ' '), style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentGreen)),
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

  void _showCreateChangeModal(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String subclass = 'Normal Change';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSizes.spacing24,
            right: AppSizes.spacing24,
            top: AppSizes.spacing24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSizes.spacing24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Change Request', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSizes.spacing16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSizes.spacing16),
              DropdownButtonFormField<String>(
                initialValue: subclass,
                decoration: const InputDecoration(labelText: 'Subclass', border: OutlineInputBorder()),
                items: ['Normal Change', 'Routine Change', 'Emergency Change']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) subclass = val;
                },
              ),
              const SizedBox(height: AppSizes.spacing16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSizes.spacing24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      ref.read(changesControllerProvider.notifier).createChange(
                            titleController.text,
                            subclass,
                            descController.text,
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text('Submit Request', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
