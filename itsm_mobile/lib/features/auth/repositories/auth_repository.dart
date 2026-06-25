import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

/// Provides the singleton [AuthRepository] instance via Riverpod.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Abstracts all Supabase Auth and profile operations.
///
/// Adheres to the Repository pattern (SOLID: Single Responsibility).
/// The controller layer calls these methods — UI never touches
/// Supabase directly.
class AuthRepository {
  /// The Supabase client instance.
  SupabaseClient get _client => SupabaseConfig.client;

  /// The Supabase auth module.
  GoTrueClient get _auth => _client.auth;

  // ──────────────────────────────────────────────
  // Auth Operations
  // ──────────────────────────────────────────────

  /// Sign in with email and password.
  ///
  /// Returns the [AuthResponse] on success.
  /// Throws [AuthException] on failure.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset link to email.
  Future<void> resetPasswordForEmail(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Get the current session, if one exists.
  Session? get currentSession => _auth.currentSession;

  /// Get the current Supabase auth user, if signed in.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (sign in, sign out, token refresh).
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ──────────────────────────────────────────────
  // Profile Operations
  // ──────────────────────────────────────────────

  /// Fetch the user's profile from the `profiles` table.
  ///
  /// The `profiles` table is expected to have columns:
  /// `id` (UUID, FK to auth.users), `email`, `full_name`,
  /// `role` (text: 'leader' or 'executor'), `avatar_url`.
  Future<AppUser?> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return AppUser.fromMap(response);
    } catch (_) {
      return null;
    }
  }

  /// Build an [AppUser] from the current session.
  ///
  /// First attempts to fetch the profile from the database.
  /// Falls back to constructing a minimal user from auth metadata.
  Future<AppUser> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    // Try fetching from profiles table
    final profile = await fetchUserProfile(user.id);
    if (profile != null) return profile;

    // Fallback: construct from auth metadata
    final metadata = user.userMetadata ?? {};
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      role: UserRole.fromString(metadata['role'] as String?),
      fullName: metadata['full_name'] as String?,
    );
  }
}
