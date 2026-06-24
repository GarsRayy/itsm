import 'package:equatable/equatable.dart';

import '../models/app_user.dart';

/// Represents the current authentication state of the application.
///
/// Uses a sealed-class-like pattern with [Equatable] for clean
/// state comparison in Riverpod.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — app just launched, auth status unknown.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Actively checking auth session (e.g., on app start, during login).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated and their profile has been loaded.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  /// The currently authenticated user with role information.
  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// No active session — user must sign in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error occurred (invalid credentials, network, etc.).
class AuthError extends AuthState {
  const AuthError(this.message);

  /// Human-readable error message for display.
  final String message;

  @override
  List<Object?> get props => [message];
}
