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
import '../../tickets/models/ticket_status.dart';
import '../../tickets/screens/widgets/ticket_card.dart';
import '../../../core/widgets/shimmer_ticket_card.dart';

/// Leader Dashboard
class LeaderDashboardScreen extends ConsumerWidget {
  const LeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.displayName
        : 'Leader';

    final ticketsState = ref.watch(ticketControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-ticket'),
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Ticket'),
      ),
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
                        // Top bar with greeting and sign out
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good Morning,',
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
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull,
                                ),
                              ),
                              child: Text(
                                '👑 LEADER',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                            .animate(delay: 200.ms)
                            .fadeIn()
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: AppSizes.spacing32),

                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: GlassmorphicContainer(
                                padding: const EdgeInsets.all(AppSizes.spacing16),
                                onTap: () => context.push('/users'),
                                child: Column(
                                  children: [
                                    const Icon(Icons.group_add_rounded, color: AppColors.primaryYellow, size: AppSizes.iconLarge),
                                    const SizedBox(height: AppSizes.spacing8),
                                    Text('Manage Users', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryYellow)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            Expanded(
                              child: GlassmorphicContainer(
                                padding: const EdgeInsets.all(AppSizes.spacing16),
                                onTap: () => context.push('/triage'),
                                child: Column(
                                  children: [
                                    const Icon(Icons.assignment_ind_rounded, color: AppColors.accentBlue, size: AppSizes.iconLarge),
                                    const SizedBox(height: AppSizes.spacing8),
                                    Text('Triage / Assign', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentBlue)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            Expanded(
                              child: GlassmorphicContainer(
                                padding: const EdgeInsets.all(AppSizes.spacing16),
                                onTap: () => context.push('/service-catalog'),
                                child: Column(
                                  children: [
                                    const Icon(Icons.menu_book_rounded, color: AppColors.accentPurple, size: AppSizes.iconLarge),
                                    const SizedBox(height: AppSizes.spacing8),
                                    Text('Catalog', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentPurple)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                        // Analytics Chart
                        const SizedBox(height: AppSizes.spacing16),
                        Text('Weekly Analytics', style: AppTextStyles.titleLarge)
                            .animate(delay: 350.ms)
                            .fadeIn()
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(height: AppSizes.spacing16),
                        _buildAnalyticsChart()
                            .animate(delay: 400.ms)
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: AppSizes.spacing32),

                        // Phase 4 Modules
                        Row(
                          children: [
                            _buildModuleCard(
                              context: context,
                              icon: Icons.warning_amber_rounded,
                              label: 'Incidents',
                              color: AppColors.accentRed,
                              route: '/incidents',
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            _buildModuleCard(
                              context: context,
                              icon: Icons.sync_alt_rounded,
                              label: 'Changes',
                              color: AppColors.accentBlue,
                              route: '/changes',
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            _buildModuleCard(
                              context: context,
                              icon: Icons.psychology_alt_rounded,
                              label: 'Problems',
                              color: AppColors.primaryOrange,
                              route: '/problems',
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            _buildModuleCard(
                              context: context,
                              icon: Icons.account_tree_rounded,
                              label: 'Projects',
                              color: AppColors.accentGreen,
                              route: '/projects',
                            ),
                          ],
                        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),

                        const SizedBox(height: AppSizes.spacing32),

                        // Analytics Metrics
                        _buildMetrics(ticketsState),

                        const SizedBox(height: AppSizes.spacing32),

                        Text(
                          'Recent Tickets',
                          style: AppTextStyles.headlineSmall,
                        ).animate(delay: 600.ms).fadeIn(),

                        const SizedBox(height: AppSizes.spacing16),
                      ],
                    ),
                  ),

                  // Ticket List
                  _buildTicketList(ticketsState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsChart() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tickets by Day', style: AppTextStyles.titleMedium),
              const Icon(Icons.show_chart_rounded, color: AppColors.accentBlue),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Mon', 40, AppColors.accentBlue),
                _buildBar('Tue', 70, AppColors.primaryOrange),
                _buildBar('Wed', 50, AppColors.accentBlue),
                _buildBar('Thu', 90, AppColors.accentRed),
                _buildBar('Fri', 30, AppColors.accentBlue),
                _buildBar('Sat', 20, AppColors.textHint),
                _buildBar('Sun', 10, AppColors.textHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return Expanded(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing16, horizontal: AppSizes.spacing8),
        onTap: () => context.push(route),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconLarge),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics(TicketsState state) {
    if (state.isLoading && state.tickets.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      );
    }

    final openCount = state.tickets
        .where((t) => t.status == TicketStatus.open)
        .length;
    final inProgressCount = state.tickets
        .where((t) => t.status == TicketStatus.inProgress)
        .length;
    final resolvedCount = state.tickets
        .where((t) => t.status == TicketStatus.resolved)
        .length;

    return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Open Tickets',
                    value: '$openCount',
                    color: AppColors.accentRed,
                    icon: Icons.confirmation_num_outlined,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing12),
                Expanded(
                  child: _MetricCard(
                    label: 'In Progress',
                    value: '$inProgressCount',
                    color: AppColors.accentBlue,
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Resolved',
                    value: '$resolvedCount',
                    color: AppColors.accentGreen,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing12),
                const Expanded(
                  child: _MetricCard(
                    label: 'Staff Online',
                    value: '3', // Mock for now
                    color: AppColors.accentPurple,
                    icon: Icons.people_outline_rounded,
                  ),
                ),
              ],
            ),
          ],
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTicketList(TicketsState state) {
    if (state.isLoading && state.tickets.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const ShimmerTicketCard(),
            childCount: 3,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing32),
            child: Text(
              'No recent tickets.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ),
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

/// Glassmorphic metric card for dashboard KPIs.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSizes.iconDefault),
          const SizedBox(height: AppSizes.spacing12),
          Text(value, style: AppTextStyles.metricMedium.copyWith(color: color)),
          const SizedBox(height: AppSizes.spacing4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
