class ProjectModel {
  final String id;
  final String projectRef;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? managerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.projectRef,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.status,
    this.managerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      projectRef: json['project_ref'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      status: json['status'] as String,
      managerName: json['manager_name'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_ref': projectRef,
      'title': title,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'manager_name': managerName,
    };
  }
}
