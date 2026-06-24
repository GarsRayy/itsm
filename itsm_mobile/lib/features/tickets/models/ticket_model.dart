import 'package:equatable/equatable.dart';
import 'ticket_status.dart';
import 'ticket_priority.dart';

/// Immutable model representing an ITSM Ticket.
class Ticket extends Equatable {
  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.assigneeId,
    this.assigneeName,
    this.gitlabIssueUrl,
  });

  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final String? assigneeId;
  final String? assigneeName;
  final String? gitlabIssueUrl;

  Ticket copyWith({
    String? id,
    String? title,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    DateTime? createdAt,
    String? assigneeId,
    String? assigneeName,
    String? gitlabIssueUrl,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      gitlabIssueUrl: gitlabIssueUrl ?? this.gitlabIssueUrl,
    );
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      status: TicketStatus.fromString(map['status'] as String?),
      priority: TicketPriority.fromString(map['priority'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String),
      assigneeId: map['assignee_id'] as String?,
      assigneeName: map['assignee_name'] as String?,
      gitlabIssueUrl: map['gitlab_issue_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'assignee_id': assigneeId,
      'assignee_name': assigneeName,
      'gitlab_issue_url': gitlabIssueUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    createdAt,
    assigneeId,
    assigneeName,
    gitlabIssueUrl,
  ];
}
