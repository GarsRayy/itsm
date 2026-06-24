import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../auth/models/user_role.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';
import '../repositories/ticket_repository.dart';

/// State of the tickets list
class TicketsState {
  const TicketsState({
    this.isLoading = false,
    this.tickets = const [],
    this.error,
  });

  final bool isLoading;
  final List<Ticket> tickets;
  final String? error;

  TicketsState copyWith({
    bool? isLoading,
    List<Ticket>? tickets,
    String? error,
  }) {
    return TicketsState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      error: error,
    );
  }
}

/// Provider for managing tickets.
/// It observes the Auth state to automatically load the correct tickets
/// (all for Leader, personal for Executor).
final ticketControllerProvider =
    StateNotifierProvider<TicketController, TicketsState>((ref) {
      final repo = ref.watch(ticketRepositoryProvider);
      final authState = ref.watch(authControllerProvider);

      return TicketController(repo, authState);
    });

class TicketController extends StateNotifier<TicketsState> {
  TicketController(this._repo, this._authState) : super(const TicketsState()) {
    _loadTickets();
  }

  final TicketRepository _repo;
  final AuthState _authState;

  Future<void> _loadTickets() async {
    final currentState = _authState;
    if (currentState is! AuthAuthenticated) return;

    final user = currentState.user;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final List<Ticket> tickets;
      if (user.role == UserRole.leader) {
        tickets = await _repo.fetchAllTickets();
      } else {
        tickets = await _repo.fetchTicketsForUser(user.id);
      }
      state = state.copyWith(isLoading: false, tickets: tickets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Manually refresh tickets
  Future<void> refresh() async {
    await _loadTickets();
  }

  /// Update the status of a ticket and refresh the list
  Future<void> updateTicketStatus(
    String ticketId,
    TicketStatus newStatus,
  ) async {
    try {
      await _repo.updateTicketStatus(ticketId, newStatus);
      // Refresh the local list without a full reload indicator
      final updatedTickets = state.tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(status: newStatus);
        }
        return t;
      }).toList();

      state = state.copyWith(tickets: updatedTickets);
    } catch (e) {
      // Don't wipe out the existing list, just show the error via a separate mechanism
      // if possible, or just let the caller handle it. For now, we'll set it to state.
      state = state.copyWith(error: 'Failed to update status: $e');
    }
  }
}
