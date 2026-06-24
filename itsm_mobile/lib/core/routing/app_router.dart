import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/controllers/auth_state.dart';
import '../../features/auth/models/user_role.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/leader_dashboard_screen.dart';
import '../../features/dashboard/screens/executor_dashboard_screen.dart';

// ──────────────────────────────────────────────
// Route Path Constants
// ──────────────────────────────────────────────

/// Centralized route paths — avoids scattered string literals.
abstract final class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String leaderDashboard = '/leader';
  static const String executorDashboard = '/executor';
}

// ──────────────────────────────────────────────
// Router Provider
// ──────────────────────────────────────────────

/// GoRouter provider that rebuilds when auth state changes.
///
/// Uses [redirect] to enforce RBAC:
/// - Unauthenticated → forced to `/login`
/// - Authenticated Leader → forced to `/leader`
/// - Authenticated Executor → forced to `/executor`
/// - Loading/Initial → stays on splash `/`
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) => _guardRedirect(authState, state),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: RoutePaths.leaderDashboard,
        name: 'leaderDashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LeaderDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: RoutePaths.executorDashboard,
        name: 'executorDashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExecutorDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
    ],
  );
});

// ──────────────────────────────────────────────
// RBAC Redirect Logic
// ──────────────────────────────────────────────

/// Determines where the user should be redirected based on auth state.
///
/// Rules:
/// 1. [AuthInitial] / [AuthLoading] → stay on splash (no redirect)
/// 2. [AuthUnauthenticated] / [AuthError] → force to login
/// 3. [AuthAuthenticated] → route to role-specific dashboard
///    - Prevents authenticated users from accessing login
///    - Prevents cross-role access (executor can't hit /leader)
String? _guardRedirect(AuthState authState, GoRouterState routerState) {
  final currentPath = routerState.matchedLocation;
  final isOnSplash = currentPath == RoutePaths.splash;
  final isOnLogin = currentPath == RoutePaths.login;

  // ── Still loading / checking session ──
  if (authState is AuthInitial || authState is AuthLoading) {
    // Only allow splash while loading.
    return isOnSplash ? null : RoutePaths.splash;
  }

  // ── Not authenticated ──
  if (authState is AuthUnauthenticated || authState is AuthError) {
    // Force to login unless already there.
    return isOnLogin ? null : RoutePaths.login;
  }

  // ── Authenticated ──
  if (authState is AuthAuthenticated) {
    final role = authState.user.role;
    final targetPath = role == UserRole.leader
        ? RoutePaths.leaderDashboard
        : RoutePaths.executorDashboard;

    // If on splash or login, redirect to the role dashboard.
    if (isOnSplash || isOnLogin) {
      return targetPath;
    }

    // Prevent cross-role access:
    // A leader on /executor → redirect to /leader (and vice versa).
    if (role == UserRole.leader &&
        currentPath == RoutePaths.executorDashboard) {
      return RoutePaths.leaderDashboard;
    }
    if (role == UserRole.executor &&
        currentPath == RoutePaths.leaderDashboard) {
      return RoutePaths.executorDashboard;
    }

    // User is on their correct dashboard — no redirect.
    return null;
  }

  return null;
}
