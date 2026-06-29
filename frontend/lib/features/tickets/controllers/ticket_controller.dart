import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../auth/models/user_role.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';
import '../repositories/ticket_repository.dart';

class TicketsState {
  const TicketsState({
    this.isLoading = false,
    this.tickets = const [],
    this.searchQuery = '',
    this.error,
  });

  final bool isLoading;
  final List<Ticket> tickets;
  final String searchQuery;
  final String? error;

  List<Ticket> get filteredTickets {
    if (searchQuery.isEmpty) return tickets;
    final lowerQuery = searchQuery.toLowerCase();
    return tickets.where((t) {
      return t.ticketCode.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  TicketsState copyWith({
    bool? isLoading,
    List<Ticket>? tickets,
    String? searchQuery,
    String? error,
  }) {
    return TicketsState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

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

  Future<void> refresh() async {
    await _loadTickets();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    try {
      await _repo.updateTicketStatus(ticketId, newStatus);
      final updatedTickets = state.tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(status: newStatus);
        }
        return t;
      }).toList();

      state = state.copyWith(tickets: updatedTickets);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update status: $e');
    }
  }

  /// Resolve a ticket with a resolution note.
  Future<void> resolveTicket(String ticketId, String resolutionNote) async {
    try {
      await _repo.resolveTicket(ticketId, resolutionNote);
      final updatedTickets = state.tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(
            status: TicketStatus.resolved,
            resolutionNote: resolutionNote,
            resolvedAt: DateTime.now(),
          );
        }
        return t;
      }).toList();

      state = state.copyWith(tickets: updatedTickets);
    } catch (e) {
      state = state.copyWith(error: 'Failed to resolve ticket: $e');
    }
  }

  /// Assign a ticket to a team member (Leader action).
  Future<void> assignTicket(String ticketId, String assigneeName) async {
    try {
      await _repo.assignTicket(ticketId, assigneeName);
      final updatedTickets = state.tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(
            assigneeName: assigneeName,
            status: TicketStatus.inProgress,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(tickets: updatedTickets);
    } catch (e) {
      state = state.copyWith(error: 'Failed to assign ticket: $e');
    }
  }

  /// Create a sub-task (Child Ticket) and add to state.
  Future<void> createSubTask({
    required String parentIncidentId,
    required String title,
    required String description,
    required String assigneeName,
  }) async {
    try {
      final newSubTask = await _repo.createSubTask(
        parentIncidentId: parentIncidentId,
        title: title,
        description: description,
        assigneeName: assigneeName,
      );
      
      state = state.copyWith(tickets: [newSubTask, ...state.tickets]);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create sub-task: $e');
      rethrow;
    }
  }
}
