import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Represents the current status of an ITSM ticket.
enum TicketStatus {
  open('Open', AppColors.accentRed),
  inProgress('In Progress', AppColors.accentBlue),
  resolved('Resolved', AppColors.accentGreen),
  closed('Closed', AppColors.textHint);

  const TicketStatus(this.displayName, this.color);

  final String displayName;
  final Color color;

  static TicketStatus fromString(String? value) {
    if (value == null) return TicketStatus.open;
    return TicketStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TicketStatus.open,
    );
  }
}
