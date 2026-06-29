import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Represents the priority level of an ITSM ticket.
enum TicketPriority {
  low('Low', AppColors.textSecondary),
  medium('Medium', AppColors.warning),
  high('High', AppColors.primaryOrange),
  critical('Critical', AppColors.accentRed);

  const TicketPriority(this.displayName, this.color);

  final String displayName;
  final Color color;

  static TicketPriority fromString(String? value) {
    if (value == null) return TicketPriority.medium;
    return TicketPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }
}
