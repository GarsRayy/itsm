import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Represents the current status of an ITSM ticket.
enum TicketStatus {
  newStatus('New', 'new', AppColors.accentPurple),
  open('Open', 'open', AppColors.accentRed),
  inProgress('In Progress', 'in_progress', AppColors.accentBlue),
  resolved('Resolved', 'resolved', AppColors.accentGreen),
  closed('Closed', 'closed', AppColors.textHint);

  const TicketStatus(this.displayName, this.dbValue, this.color);

  final String displayName;
  final String dbValue;
  final Color color;

  static TicketStatus fromString(String? value) {
    if (value == null) return TicketStatus.open;
    return TicketStatus.values.firstWhere(
      (status) => status.dbValue.toLowerCase() == value.toLowerCase(),
      orElse: () => TicketStatus.open,
    );
  }
}
