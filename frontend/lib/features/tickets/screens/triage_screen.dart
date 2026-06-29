import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket_status.dart';
import 'widgets/ticket_card.dart';

class TriageScreen extends ConsumerWidget {
  const TriageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsState = ref.watch(ticketControllerProvider);

    // Filter only "new" tickets that need triage
    final newTickets = ticketsState.tickets
        .where((t) => t.status == TicketStatus.open || t.status == TicketStatus.newStatus)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triage Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incoming Reports',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Review and assign incoming WA reports to your team.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: AppSizes.spacing24),
                
                Expanded(
                  child: newTickets.isEmpty
                      ? Center(
                          child: Text(
                            'No new reports.',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
                          ),
                        )
                      : ListView.separated(
                          itemCount: newTickets.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSizes.spacing16),
                          itemBuilder: (context, index) {
                            final ticket = newTickets[index];
                            return TicketCard(
                              ticket: ticket,
                              onTap: () => context.push('/ticket/${ticket.id}'),
                            );
                          },
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
