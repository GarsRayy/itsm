import 'package:equatable/equatable.dart';
import 'ticket_status.dart';
import 'ticket_priority.dart';

/// Immutable model representing an ITSM Ticket.
class Ticket extends Equatable {
  const Ticket({
    required this.id,
    required this.ticketCode,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.source,
    this.phoneNumber,
    this.reporterName,
    this.department,
    this.location,
    this.manualAssetName,
    this.assigneeId,
    this.assigneeName,
    this.gitlabIssueUrl,
    this.resolutionNote,
    this.resolvedAt,
  });

  final String id;
  final String ticketCode;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  
  // WA/Fonnte & Source
  final String source;
  final String? phoneNumber;
  
  // Manual Info
  final String? reporterName;
  final String? department;
  final String? location;
  final String? manualAssetName;

  // Assignments
  final String? assigneeId;
  final String? assigneeName;
  final String? gitlabIssueUrl;

  // Resolution
  final String? resolutionNote;
  final DateTime? resolvedAt;

  Ticket copyWith({
    String? id,
    String? ticketCode,
    String? title,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    DateTime? createdAt,
    String? source,
    String? phoneNumber,
    String? reporterName,
    String? department,
    String? location,
    String? manualAssetName,
    String? assigneeId,
    String? assigneeName,
    String? gitlabIssueUrl,
    String? resolutionNote,
    DateTime? resolvedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketCode: ticketCode ?? this.ticketCode,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      reporterName: reporterName ?? this.reporterName,
      department: department ?? this.department,
      location: location ?? this.location,
      manualAssetName: manualAssetName ?? this.manualAssetName,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      gitlabIssueUrl: gitlabIssueUrl ?? this.gitlabIssueUrl,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] as String,
      ticketCode: map['ticket_code'] as String? ?? map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      status: TicketStatus.fromString(map['status'] as String?),
      priority: TicketPriority.fromString(map['priority'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String),
      source: map['source'] as String? ?? 'manual',
      phoneNumber: map['phone_number'] as String?,
      reporterName: map['reporter_name'] as String?,
      department: map['department'] as String?,
      location: map['location'] as String?,
      manualAssetName: map['manual_asset_name'] as String?,
      assigneeId: map['assignee_id'] as String?,
      assigneeName: map['assignee_name'] as String?,
      gitlabIssueUrl: map['gitlab_issue_url'] as String?,
      resolutionNote: map['resolution_note'] as String?,
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_code': ticketCode,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'source': source,
      'phone_number': phoneNumber,
      'reporter_name': reporterName,
      'department': department,
      'location': location,
      'manual_asset_name': manualAssetName,
      'assignee_id': assigneeId,
      'assignee_name': assigneeName,
      'gitlab_issue_url': gitlabIssueUrl,
      'resolution_note': resolutionNote,
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    ticketCode,
    title,
    description,
    status,
    priority,
    createdAt,
    source,
    phoneNumber,
    reporterName,
    department,
    location,
    manualAssetName,
    assigneeId,
    assigneeName,
    gitlabIssueUrl,
    resolutionNote,
    resolvedAt,
  ];
}
