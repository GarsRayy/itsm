import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

/// Repository for handling Ticket data via Supabase.
class TicketRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  /// Fetch all tickets (Leader view), ordered by newest first.
  Future<List<Ticket>> fetchAllTickets() async {
    final response = await _client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((e) => Ticket.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch tickets assigned to a specific user (Executor view), ordered by newest first.
  Future<List<Ticket>> fetchTicketsForUser(String userId) async {
    final response = await _client
        .from('tickets')
        .select()
        .eq('assignee_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Ticket.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Update the status of a specific ticket.
  Future<void> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    await _client
        .from('tickets')
        .update({
          'status': newStatus.name,
          if (newStatus == TicketStatus.inProgress)
            'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId);
  }

  /// Resolve a ticket with a resolution note.
  Future<void> resolveTicket(String ticketId, String resolutionNote) async {
    await _client
        .from('tickets')
        .update({
          'status': TicketStatus.resolved.name,
          'resolution_note': resolutionNote,
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId);
  }

  /// Assign a ticket to a team member.
  Future<void> assignTicket(String ticketId, String assigneeName) async {
    await _client
        .from('tickets')
        .update({
          'assignee_name': assigneeName,
          'status': TicketStatus.inProgress.name,
        })
        .eq('id', ticketId);
  }
}
