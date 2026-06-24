import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../../models/ticket_model.dart';
import 'status_badge.dart';

/// Glassmorphic ticket card used in lists.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  final Ticket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.id,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _formatTimeAgo(ticket.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),

          // Title
          Text(
            ticket.title,
            style: AppTextStyles.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.spacing4),

          // Description
          if (ticket.description.isNotEmpty)
            Text(
              ticket.description,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: AppSizes.spacing16),

          // Footer: Badges and Assignee
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
              if (ticket.assigneeName != null) ...[
                const Icon(
                  Icons.person_outline_rounded,
                  size: AppSizes.iconSmall,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: AppSizes.spacing4),
                Text(
                  ticket.assigneeName!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return DateFormat('MMM d, y').format(date);
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
