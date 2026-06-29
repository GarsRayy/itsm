import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../tickets/controllers/ticket_controller.dart';
import '../../tickets/screens/widgets/ticket_card.dart';
import '../../../core/widgets/shimmer_ticket_card.dart';
import '../../../core/utils/snackbar_utils.dart';

/// Executor Dashboard
class ExecutorDashboardScreen extends ConsumerWidget {
  const ExecutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.displayName
        : 'Executor';

    final ticketsState = ref.watch(ticketControllerProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(ticketControllerProvider.notifier).refresh(),
              color: AppColors.primaryYellow,
              backgroundColor: AppColors.surfaceVariant,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
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
                                    'Welcome back,',
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
                            // Sign out button
                            GlassmorphicContainer(
                              padding: const EdgeInsets.all(AppSizes.spacing8),
                              borderRadius: AppSizes.radiusMedium,
                              onTap: () {
                                ref
                                    .read(authControllerProvider.notifier)
                                    .signOut();
                              },
                              child: const Icon(
                                Icons.logout_rounded,
                                color: AppColors.textSecondary,
                                size: AppSizes.iconDefault,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: AppSizes.spacing24),

                        // Role badge
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.spacing12,
                                vertical: AppSizes.spacing4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppGradients.info,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull,
                                ),
                              ),
                              child: Text(
                                '⚡ EXECUTOR',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                            .animate(delay: 200.ms)
                            .fadeIn()
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: AppSizes.spacing32),

                        // Quick actions
                        Row(
                              children: [
                                Expanded(
                                  child: _QuickAction(
                                    label: 'Update Status',
                                    icon: Icons.update_rounded,
                                    color: AppColors.accentBlue,
                                    onTap: () {
                                      if (ticketsState.tickets.isNotEmpty) {
                                        context.push('/ticket/${ticketsState.tickets.first.id}');
                                      } else {
                                        SnackbarUtils.showInfo(context, 'No tickets to update.');
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSizes.spacing12),
                                Expanded(
                                  child: _QuickAction(
                                    label: 'Service Catalog',
                                    icon: Icons.menu_book_rounded,
                                    color: AppColors.accentPurple,
                                    onTap: () => context.push('/service-catalog'),
                                  ),
                                ),
                              ],
                            )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: AppSizes.spacing32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Tasks',
                              style: AppTextStyles.headlineSmall,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.spacing8,
                                vertical: AppSizes.spacing2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentRed.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull,
                                ),
                              ),
                              child: Text(
                                '${ticketsState.tickets.length} pending',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accentRed,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 600.ms).fadeIn(),

                        const SizedBox(height: AppSizes.spacing16),
                      ],
                    ),
                  ),

                  // Task List
                  _buildTaskList(ticketsState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(TicketsState state) {
    if (state.isLoading && state.tickets.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const ShimmerTicketCard(),
            childCount: 2,
          ),
        ),
      );
    }

    if (state.error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing32),
            child: Text(
              'Error: ${state.error}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ),
      );
    }

    if (state.tickets.isEmpty) {
      return SliverToBoxAdapter(
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          child: Row(
            children: [
              const Icon(
                Icons.inbox_rounded,
                color: AppColors.textHint,
                size: AppSizes.iconLarge,
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All caught up!', style: AppTextStyles.bodyMedium),
                    Text(
                      'No pending tasks assigned to you.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.1, end: 0),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final ticket = state.tickets[index];
        return TicketCard(
              ticket: ticket,
              onTap: () {
                context.push('/ticket/${ticket.id}');
              },
            )
            .animate(delay: (700 + (index * 100)).ms)
            .fadeIn()
            .slideY(begin: 0.1, end: 0);
      }, childCount: state.tickets.length),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
