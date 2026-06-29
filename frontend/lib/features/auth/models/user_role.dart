/// Defines the two roles in the ITSM RBAC system.
///
/// Each authenticated user is assigned exactly one role that
/// determines their navigation flow and available features.
enum UserRole {
  /// Admin — overall system control, manages all users and settings.
  admin('Admin'),

  /// IT Team Leader — full dashboard analytics, ticket management,
  /// staff workload views, assignment/re-assignment.
  leader('Leader'),

  /// IT Executor — personal task queue, quick status updates,
  /// media attachments, GitLab issue creation.
  executor('Executor');

  const UserRole(this.displayName);

  /// Human-readable label for UI display.
  final String displayName;

  /// Parse a role string from the database (case-insensitive).
  ///
  /// Defaults to [UserRole.executor] if the value is unrecognized,
  /// following the principle of least privilege.
  static UserRole fromString(String? value) {
    if (value == null) return UserRole.executor;
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.executor,
    );
  }
}
