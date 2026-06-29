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
    // Fetch old ticket for notification purposes
    final oldRecord = await _client.from('tickets').select().eq('id', ticketId).single();

    final updateData = {
      'status': newStatus.dbValue,
      if (newStatus == TicketStatus.inProgress) 'updated_at': DateTime.now().toIso8601String(),
    };

    final newRecordResponse = await _client.from('tickets').update(updateData).eq('id', ticketId).select().single();

    // Trigger Fonnte notification
    try {
      await _client.functions.invoke('fonnte-send', body: {
        'type': 'UPDATE',
        'old_record': oldRecord,
        'record': newRecordResponse,
      });
    } catch (e) {
      throw Exception('Database updated, but WA notification failed: \$e');
    }
  }

  /// Resolve a ticket with a resolution note.
  Future<void> resolveTicket(String ticketId, String resolutionNote) async {
    final oldRecord = await _client.from('tickets').select().eq('id', ticketId).single();

    final updateData = {
      'status': TicketStatus.resolved.dbValue,
      'resolution_note': resolutionNote,
      'resolved_at': DateTime.now().toIso8601String(),
    };

    final newRecordResponse = await _client.from('tickets').update(updateData).eq('id', ticketId).select().single();

    // Trigger Fonnte notification
    try {
      await _client.functions.invoke('fonnte-send', body: {
        'type': 'UPDATE',
        'old_record': oldRecord,
        'record': newRecordResponse,
      });
    } catch (e) {
      throw Exception('Database updated, but WA notification failed: \$e');
    }
  }

  /// Assign a ticket to a team member.
  Future<void> assignTicket(String ticketId, String assigneeName) async {
    await _client
        .from('tickets')
        .update({
          'assignee_name': assigneeName,
          'status': TicketStatus.inProgress.dbValue,
        })
        .eq('id', ticketId);
  }

  /// Create a sub-task for a parent ticket.
  Future<Ticket> createSubTask({
    required String parentIncidentId,
    required String title,
    required String description,
    required String assigneeName,
  }) async {
    final randomCode = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000));
    final ticketCode = 'TSK-APP-$randomCode';

    final response = await _client
        .from('tickets')
        .insert({
          'ticket_code': ticketCode,
          'title': title,
          'description': description,
          'source': 'manual',
          'status': 'open',
          'parent_incident_id': parentIncidentId,
          'assignee_name': assigneeName,
        })
        .select()
        .single();

    return Ticket.fromMap(response);
  }
}
