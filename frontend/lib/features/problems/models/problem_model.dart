class ProblemModel {
  final String id;
  final String problemRef;
  final String title;
  final String? rootCause;
  final String? workaround;
  final String status;
  final String? assigneeName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProblemModel({
    required this.id,
    required this.problemRef,
    required this.title,
    this.rootCause,
    this.workaround,
    required this.status,
    this.assigneeName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as String,
      problemRef: json['problem_ref'] as String,
      title: json['title'] as String,
      rootCause: json['root_cause'] as String?,
      workaround: json['workaround'] as String?,
      status: json['status'] as String,
      assigneeName: json['assignee_name'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem_ref': problemRef,
      'title': title,
      'root_cause': rootCause,
      'workaround': workaround,
      'status': status,
      'assignee_name': assigneeName,
    };
  }
}
