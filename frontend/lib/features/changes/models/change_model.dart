class ChangeModel {
  final String id;
  final String changeRef;
  final String title;
  final String subclass;
  final String? organization;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? assigneeName;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChangeModel({
    required this.id,
    required this.changeRef,
    required this.title,
    required this.subclass,
    this.organization,
    this.startDate,
    this.endDate,
    required this.status,
    this.assigneeName,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChangeModel.fromJson(Map<String, dynamic> json) {
    return ChangeModel(
      id: json['id'] as String,
      changeRef: json['change_ref'] as String,
      title: json['title'] as String,
      subclass: json['subclass'] as String,
      organization: json['organization'] as String?,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      status: json['status'] as String,
      assigneeName: json['assignee_name'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'change_ref': changeRef,
      'title': title,
      'subclass': subclass,
      'organization': organization,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'assignee_name': assigneeName,
      'description': description,
    };
  }
}
