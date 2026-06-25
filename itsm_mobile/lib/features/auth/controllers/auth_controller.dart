import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../repositories/auth_repository.dart';
import 'auth_state.dart';

/// Global provider for the auth controller.
///
/// Manages the entire auth lifecycle. The router listens to this
/// provider to perform RBAC-based redirects.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

/// Manages authentication state transitions.
///
/// Adheres to the Single Responsibility Principle — this class
/// ONLY handles auth lifecycle. Business logic for tickets,
/// dashboards, etc. lives in their own controllers.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  // ──────────────────────────────────────────────
  // Auth Lifecycle
  // ──────────────────────────────────────────────

  /// Check if a valid session exists on app startup.
  ///
  /// Called from the splash screen to determine the initial route.
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    try {
      final session = _repository.currentSession;

      if (session == null) {
        state = const AuthUnauthenticated();
        return;
      }

      // Session exists — fetch the full user profile.
      final appUser = await _repository.getCurrentAppUser();
      state = AuthAuthenticated(appUser);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Failed to restore session: $e');
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      // Fetch profile after successful auth.
      final appUser = await _repository.getCurrentAppUser();
      state = AuthAuthenticated(appUser);
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = AuthError('Sign in failed: $e');
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = const AuthLoading();

    try {
      await _repository.signOut();
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError('Sign out failed: $e');
    }
  }

  /// Reset password for email.
  Future<void> resetPassword(String email) async {
    try {
      await _repository.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset link: $e');
    }
  }

  /// Reset to unauthenticated (e.g., after dismissing an error).
  void resetToUnauthenticated() {
    state = const AuthUnauthenticated();
  }

  // ──────────────────────────────────────────────
  // Error Mapping
  // ──────────────────────────────────────────────

  /// Maps raw Supabase error messages to user-friendly strings.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address first.';
    }
    if (lower.contains('too many requests') ||
        lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Network error. Check your connection.';
    }

    return message;
  }
}
