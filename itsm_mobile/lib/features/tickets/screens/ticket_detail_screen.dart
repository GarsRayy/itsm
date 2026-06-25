import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../auth/models/user_role.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';
import 'widgets/status_badge.dart';

/// Ticket Detail Screen — full lifecycle management.
///
/// Shows complete ticket information, allows status transitions,
/// assignment (Leader only), and resolution note submission.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _resolutionCtrl = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _resolutionCtrl.dispose();
    super.dispose();
  }

  Ticket? _findTicket() {
    final ticketsState = ref.read(ticketControllerProvider);
    try {
      return ticketsState.tickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateStatus(TicketStatus newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(ticketControllerProvider.notifier).updateTicketStatus(
            widget.ticketId,
            newStatus,
          );
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Status updated to ${newStatus.displayName}',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to update: $e');
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _resolveTicket() async {
    final note = _resolutionCtrl.text.trim();
    if (note.isEmpty) {
      SnackbarUtils.showError(context, 'Please enter a resolution note.');
      return;
    }

    setState(() => _isUpdating = true);
    try {
      await ref.read(ticketControllerProvider.notifier).resolveTicket(
            widget.ticketId,
            note,
          );
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Ticket resolved successfully!');
        _resolutionCtrl.clear();
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _showAssignDialog(Ticket ticket) {
    final assigneeCtrl = TextEditingController(text: ticket.assigneeName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: Text('Assign Ticket', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assign this ticket to a team member.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSizes.spacing16),
            TextField(
              controller: assigneeCtrl,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Assignee Name',
                hintText: 'e.g., Ahmad Fauzi',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = assigneeCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => _isUpdating = true);
              try {
                await ref
                    .read(ticketControllerProvider.notifier)
                    .assignTicket(widget.ticketId, name);
                if (mounted) {
                  SnackbarUtils.showSuccess(
                    context,
                    'Ticket assigned to $name',
                  );
                }
              } catch (e) {
                if (mounted) {
                  SnackbarUtils.showError(context, 'Failed: $e');
                }
              } finally {
                if (mounted) setState(() => _isUpdating = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _findTicket();
    final authState = ref.watch(authControllerProvider);
    final isLeader = authState is AuthAuthenticated &&
        authState.user.role == UserRole.leader;

    // Re-watch to rebuild on ticket state changes
    ref.watch(ticketControllerProvider);

    if (ticket == null) {
      return Scaffold(
        body: AnimatedGradientBackground(
          child: Center(
            child: Text(
              'Ticket not found.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(ticket.ticketCode, style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isLeader)
            IconButton(
              icon: const Icon(Icons.assignment_ind_rounded,
                  color: AppColors.primaryYellow),
              tooltip: 'Assign Ticket',
              onPressed: () => _showAssignDialog(ticket),
            ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing8),

                // ── Status & Priority Row ──────────────────
                Row(
                  children: [
                    StatusBadge(
                      label: ticket.status.displayName,
                      color: ticket.status.color,
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    StatusBadge(
                      label: ticket.priority.displayName,
                      color: ticket.priority.color,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                        vertical: AppSizes.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: ticket.source == 'whatsapp'
                            ? AppColors.accentGreen.withValues(alpha: 0.15)
                            : AppColors.accentBlue.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        ticket.source == 'whatsapp'
                            ? '📱 WhatsApp'
                            : '🖥️ App',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: ticket.source == 'whatsapp'
                              ? AppColors.accentGreen
                              : AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: AppSizes.spacing24),

                // ── Title ──────────────────────────────────
                Text(ticket.title, style: AppTextStyles.headlineMedium)
                    .animate(delay: 100.ms)
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSizes.spacing24),

                // ── Info Cards ─────────────────────────────
                _InfoSection(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Reporter',
                      value: ticket.reporterName ?? 'Unknown',
                    ),
                    if (ticket.phoneNumber != null &&
                        ticket.phoneNumber!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: ticket.phoneNumber!,
                      ),
                    if (ticket.department != null &&
                        ticket.department!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Department',
                        value: ticket.department!,
                      ),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Created',
                      value:
                          DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt),
                    ),
                    if (ticket.assigneeName != null)
                      _InfoRow(
                        icon: Icons.engineering_outlined,
                        label: 'Assigned To',
                        value: ticket.assigneeName!,
                        valueColor: AppColors.primaryYellow,
                      ),
                  ],
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSizes.spacing24),

                // ── Description ────────────────────────────
                Text('📝 Description', style: AppTextStyles.titleMedium)
                    .animate(delay: 300.ms)
                    .fadeIn(),
                const SizedBox(height: AppSizes.spacing12),
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Text(
                    ticket.description.isNotEmpty
                        ? ticket.description
                        : 'No description provided.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.6,
                    ),
                  ),
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSizes.spacing32),

                // ── Status Transition Actions ──────────────
                if (ticket.status != TicketStatus.closed) ...[
                  Text('⚡ Actions', style: AppTextStyles.titleMedium)
                      .animate(delay: 400.ms)
                      .fadeIn(),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildStatusActions(ticket)
                      .animate(delay: 450.ms)
                      .fadeIn()
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSizes.spacing24),
                ],

                // ── Resolution Note ────────────────────────
                if (ticket.status == TicketStatus.inProgress ||
                    ticket.status == TicketStatus.open) ...[
                  Text('✅ Resolve Ticket', style: AppTextStyles.titleMedium)
                      .animate(delay: 500.ms)
                      .fadeIn(),
                  const SizedBox(height: AppSizes.spacing12),
                  GlassmorphicContainer(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _resolutionCtrl,
                          maxLines: 4,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText:
                                'Describe the resolution...\n(What was done, root cause, etc.)',
                            hintStyle: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textHint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isUpdating ? null : _resolveTicket,
                            icon: _isUpdating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_rounded),
                            label: Text(
                              _isUpdating ? 'Resolving...' : 'Mark as Resolved',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 550.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSizes.spacing32),
                ],

                // ── Resolution display (if resolved/closed) ─
                if (ticket.resolutionNote != null &&
                    ticket.resolutionNote!.isNotEmpty) ...[
                  Text('📋 Resolution', style: AppTextStyles.titleMedium)
                      .animate(delay: 500.ms)
                      .fadeIn(),
                  const SizedBox(height: AppSizes.spacing12),
                  GlassmorphicContainer(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    borderColor: AppColors.accentGreen.withValues(alpha: 0.3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accentGreen,
                          size: AppSizes.iconDefault,
                        ),
                        const SizedBox(width: AppSizes.spacing12),
                        Expanded(
                          child: Text(
                            ticket.resolutionNote!,
                            style: AppTextStyles.bodyMedium
                                .copyWith(height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 550.ms).fadeIn().slideY(begin: 0.1, end: 0),
                ],

                const SizedBox(height: AppSizes.spacing48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusActions(Ticket ticket) {
    final transitions = _getAvailableTransitions(ticket.status);

    return Wrap(
      spacing: AppSizes.spacing12,
      runSpacing: AppSizes.spacing12,
      children: transitions.map((newStatus) {
        return SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _isUpdating ? null : () => _updateStatus(newStatus),
            icon: Icon(
              _statusIcon(newStatus),
              size: AppSizes.iconSmall,
              color: newStatus.color,
            ),
            label: Text(
              newStatus.displayName,
              style: AppTextStyles.labelMedium
                  .copyWith(color: newStatus.color),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: newStatus.color.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusMedium),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<TicketStatus> _getAvailableTransitions(TicketStatus current) {
    switch (current) {
      case TicketStatus.open:
        return [TicketStatus.inProgress];
      case TicketStatus.inProgress:
        return [TicketStatus.resolved, TicketStatus.open];
      case TicketStatus.resolved:
        return [TicketStatus.closed, TicketStatus.inProgress];
      case TicketStatus.closed:
        return [];
    }
  }

  IconData _statusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.replay_rounded;
      case TicketStatus.inProgress:
        return Icons.play_arrow_rounded;
      case TicketStatus.resolved:
        return Icons.check_circle_outline_rounded;
      case TicketStatus.closed:
        return Icons.lock_outline_rounded;
    }
  }
}

/// Section card grouping info rows.
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacing8),
                child: Divider(
                  color: AppColors.divider,
                  height: 1,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Single info row with icon, label and value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: AppColors.textHint),
        const SizedBox(width: AppSizes.spacing12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textHint),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
