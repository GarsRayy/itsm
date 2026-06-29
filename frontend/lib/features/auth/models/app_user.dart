import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Represents an authenticated user in the ITSM system.
///
/// Immutable value object — use [copyWith] for mutations.
/// Uses [Equatable] so two [AppUser] instances with the same
/// field values are considered equal (important for state comparison).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
  });

  /// Supabase auth user ID (UUID).
  final String id;

  /// User email address.
  final String email;

  /// RBAC role determining navigation and permissions.
  final UserRole role;

  /// Optional display name.
  final String? fullName;

  /// Optional profile picture URL.
  final String? avatarUrl;

  /// The display name to show in the UI.
  /// Falls back to email if [fullName] is not set.
  String get displayName => fullName ?? email.split('@').first;

  /// Creates a copy with the given fields replaced.
  AppUser copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Construct from a Supabase `profiles` table row.
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  /// Serialize to a map (for potential local caching).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, email, role, fullName, avatarUrl];

  @override
  String toString() => 'AppUser(id: $id, email: $email, role: ${role.name})';
}
