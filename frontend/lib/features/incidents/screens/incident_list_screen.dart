import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../tickets/controllers/ticket_controller.dart';
import '../../tickets/models/ticket_priority.dart';

class IncidentListScreen extends ConsumerWidget {
  const IncidentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsState = ref.watch(ticketControllerProvider);
    // Filter tickets that are likely incidents (e.g., High priority or title contains insiden)
    final incidents = ticketsState.tickets.where((t) => 
      t.priority == TicketPriority.high || t.title.toLowerCase().contains('insiden') || t.title.toLowerCase().contains('gangguan')
    ).toList();

    return Scaffold(
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
                    Text('Incident Management', style: AppTextStyles.displayMedium),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ticketsState.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accentRed))
                    : incidents.isEmpty
                        ? const Center(child: Text('No incidents found.'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24, vertical: AppSizes.spacing8),
                            itemCount: incidents.length,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacing16),
                            itemBuilder: (context, index) {
                              final incident = incidents[index];
                              return GlassmorphicContainer(
                                padding: const EdgeInsets.all(AppSizes.spacing16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          incident.ticketCode,
                                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryOrange),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentRed.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                            border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
                                          ),
                                          child: Text('High Priority', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentRed)),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: AppSizes.spacing8),
                                    Text(
                                      incident.title,
                                      style: AppTextStyles.titleLarge,
                                    ),
                                    const SizedBox(height: AppSizes.spacing8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textHint),
                                        const SizedBox(width: 4),
                                        Text(incident.location ?? 'Unknown Area', style: AppTextStyles.bodyMedium),
                                      ],
                                    ),
                                    const SizedBox(height: AppSizes.spacing12),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.2),
                                          child: Text(
                                            (incident.reporterName ?? 'U')[0].toUpperCase(),
                                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryOrange),
                                          ),
                                        ),
                                        const SizedBox(width: AppSizes.spacing8),
                                        Text(incident.reporterName ?? 'Unknown User', style: AppTextStyles.bodyMedium),
                                        const Spacer(),
                                        Text(incident.createdAt.toString().substring(0, 10), style: AppTextStyles.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
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

