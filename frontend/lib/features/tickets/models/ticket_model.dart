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
    this.origin,
    this.organizationName,
    this.reporterName,
    this.department,
    this.location,
    this.manualAssetName,
    this.assigneeId,
    this.assigneeName,
    this.gitlabIssueUrl,
    this.resolutionNote,
    this.resolvedAt,
    this.serviceId,
    this.serviceItemId,
    this.requestType,
    this.impact,
    this.urgency,
    this.startDate,
    this.lastUpdate,
    this.ttoDeadline,
    this.parentRequestId,
    this.parentIncidentId,
    this.parentProblemId,
    this.parentChangeId,
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
  final String? origin;
  
  // General Info
  final String? organizationName;
  final String? reporterName;
  final String? department;
  final String? location;
  final String? manualAssetName;

  // More Information
  final int? serviceId;
  final int? serviceItemId;
  
  // Qualification
  final String? requestType;
  final String? impact;
  final String? urgency;

  // Dates
  final DateTime? startDate;
  final DateTime? lastUpdate;
  final DateTime? ttoDeadline;

  // Assignments
  final String? assigneeId;
  final String? assigneeName;
  final String? gitlabIssueUrl;

  // Resolution
  final String? resolutionNote;
  final DateTime? resolvedAt;
  
  // Relations
  final String? parentRequestId;
  final String? parentIncidentId;
  final String? parentProblemId;
  final String? parentChangeId;

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
    String? origin,
    String? organizationName,
    String? reporterName,
    String? department,
    String? location,
    String? manualAssetName,
    String? assigneeId,
    String? assigneeName,
    String? gitlabIssueUrl,
    String? resolutionNote,
    DateTime? resolvedAt,
    int? serviceId,
    int? serviceItemId,
    String? requestType,
    String? impact,
    String? urgency,
    DateTime? startDate,
    DateTime? lastUpdate,
    DateTime? ttoDeadline,
    String? parentRequestId,
    String? parentIncidentId,
    String? parentProblemId,
    String? parentChangeId,
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
      origin: origin ?? this.origin,
      organizationName: organizationName ?? this.organizationName,
      reporterName: reporterName ?? this.reporterName,
      department: department ?? this.department,
      location: location ?? this.location,
      manualAssetName: manualAssetName ?? this.manualAssetName,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      gitlabIssueUrl: gitlabIssueUrl ?? this.gitlabIssueUrl,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      serviceId: serviceId ?? this.serviceId,
      serviceItemId: serviceItemId ?? this.serviceItemId,
      requestType: requestType ?? this.requestType,
      impact: impact ?? this.impact,
      urgency: urgency ?? this.urgency,
      startDate: startDate ?? this.startDate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      ttoDeadline: ttoDeadline ?? this.ttoDeadline,
      parentRequestId: parentRequestId ?? this.parentRequestId,
      parentIncidentId: parentIncidentId ?? this.parentIncidentId,
      parentProblemId: parentProblemId ?? this.parentProblemId,
      parentChangeId: parentChangeId ?? this.parentChangeId,
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
      origin: map['origin'] as String? ?? 'portal',
      organizationName: map['organization_name'] as String?,
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
      serviceId: map['service_id'] as int?,
      serviceItemId: map['service_item_id'] as int?,
      requestType: map['request_type'] as String?,
      impact: map['impact'] as String?,
      urgency: map['urgency'] as String?,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date'] as String) : null,
      lastUpdate: map['last_update'] != null ? DateTime.parse(map['last_update'] as String) : null,
      ttoDeadline: map['tto_deadline'] != null ? DateTime.parse(map['tto_deadline'] as String) : null,
      parentRequestId: map['parent_request_id'] as String?,
      parentIncidentId: map['parent_incident_id'] as String?,
      parentProblemId: map['parent_problem_id'] as String?,
      parentChangeId: map['parent_change_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_code': ticketCode,
      'title': title,
      'description': description,
      'status': status.dbValue,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'source': source,
      'phone_number': phoneNumber,
      'origin': origin,
      'organization_name': organizationName,
      'reporter_name': reporterName,
      'department': department,
      'location': location,
      'manual_asset_name': manualAssetName,
      'assignee_id': assigneeId,
      'assignee_name': assigneeName,
      'gitlab_issue_url': gitlabIssueUrl,
      'resolution_note': resolutionNote,
      'resolved_at': resolvedAt?.toIso8601String(),
      'service_id': serviceId,
      'service_item_id': serviceItemId,
      'request_type': requestType,
      'impact': impact,
      'urgency': urgency,
      'start_date': startDate?.toIso8601String(),
      'last_update': lastUpdate?.toIso8601String(),
      'tto_deadline': ttoDeadline?.toIso8601String(),
      'parent_request_id': parentRequestId,
      'parent_incident_id': parentIncidentId,
      'parent_problem_id': parentProblemId,
      'parent_change_id': parentChangeId,
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
    origin,
    organizationName,
    reporterName,
    department,
    location,
    manualAssetName,
    assigneeId,
    assigneeName,
    gitlabIssueUrl,
    resolutionNote,
    resolvedAt,
    serviceId,
    serviceItemId,
    requestType,
    impact,
    urgency,
    startDate,
    lastUpdate,
    ttoDeadline,
    parentRequestId,
    parentIncidentId,
    parentProblemId,
    parentChangeId,
  ];
}
