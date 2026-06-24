/// Static string constants used across the application.
///
/// Centralizing strings here enforces DRY and simplifies future
/// localization (i18n) efforts.
abstract final class AppStrings {
  // ──────────────────────────────────────────────
  // App-Level
  // ──────────────────────────────────────────────

  static const String appName = 'ITSM Mobile';
  static const String appTagline = 'IT Service Management';

  // ──────────────────────────────────────────────
  // Auth
  // ──────────────────────────────────────────────

  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to manage your IT services';
  static const String emailHint = 'Email address';
  static const String passwordHint = 'Password';
  static const String signInButton = 'Sign In';
  static const String forgotPassword = 'Forgot Password?';

  // ──────────────────────────────────────────────
  // Dashboard
  // ──────────────────────────────────────────────

  static const String dashboardTitle = 'Dashboard';
  static const String myTasks = 'My Tasks';
  static const String allTickets = 'All Tickets';
  static const String workload = 'Staff Workload';
  static const String analytics = 'Analytics';

  // ──────────────────────────────────────────────
  // Tickets
  // ──────────────────────────────────────────────

  static const String ticketDetail = 'Ticket Detail';
  static const String createTicket = 'Create Ticket';
  static const String assignTicket = 'Assign Ticket';
  static const String updateStatus = 'Update Status';
  static const String createGitLabIssue = 'Create GitLab Issue';
  static const String attachMedia = 'Attach Media';

  // ──────────────────────────────────────────────
  // Status Labels
  // ──────────────────────────────────────────────

  static const String statusOpen = 'Open';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved = 'Resolved';
  static const String statusClosed = 'Closed';
  static const String statusOverdue = 'Overdue';

  // ──────────────────────────────────────────────
  // Priority Labels
  // ──────────────────────────────────────────────

  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';
  static const String priorityCritical = 'Critical';

  // ──────────────────────────────────────────────
  // Roles
  // ──────────────────────────────────────────────

  static const String roleLeader = 'Leader';
  static const String roleExecutor = 'Executor';

  // ──────────────────────────────────────────────
  // General
  // ──────────────────────────────────────────────

  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String errorGeneric = 'Something went wrong. Please try again.';
}
