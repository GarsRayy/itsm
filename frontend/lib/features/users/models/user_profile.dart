class UserProfile {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? division;
  final String? email;
  final String? employeeId;
  final bool isActive;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.division,
    this.email,
    this.employeeId,
    this.isActive = true,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String,
      division: map['division'] as String?,
      email: map['email'] as String?,
      employeeId: map['employee_id'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      role: map['role'] as String? ?? 'user',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'division': division,
      'email': email,
      'employee_id': employeeId,
      'is_active': isActive,
      'role': role,
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? division,
    String? email,
    String? employeeId,
    bool? isActive,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      division: division ?? this.division,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
