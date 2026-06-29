import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../models/service_catalog.dart';
import '../models/ticket_model.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

class CatalogRepository {
  final _client = SupabaseConfig.client;

  /// Fetch all 11 service catalogs ordered by display_order
  Future<List<ServiceCatalog>> fetchCatalogs() async {
    final response = await _client
        .from('service_catalog')
        .select()
        .order('display_order', ascending: true);

    return (response as List<dynamic>)
        .map((e) => ServiceCatalog.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch sub-category items for a specific catalog
  Future<List<ServiceItem>> fetchItemsByCatalog(int catalogId) async {
    final response = await _client
        .from('service_items')
        .select()
        .eq('catalog_id', catalogId)
        .order('id', ascending: true);

    return (response as List<dynamic>)
        .map((e) => ServiceItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a ticket manually from the app
  Future<Ticket> createManualTicket({
    required String reporterName,
    required String phoneNumber,
    required String? userProfileId,
    required int serviceItemId,
    required int catalogId,
    required String title,
    required String description,
    required String requestType,
    required String priority,
    required String organizationName,
    required String origin,
    required String impact,
    required String urgency,
    String? assigneeId,
  }) async {
    final randomCode = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000));
    final ticketCode = 'TKT-APP-$randomCode';

    // Kalkulasi TTO Deadline (SLA Matrix)
    DateTime ttoDeadline;
    switch (urgency.toLowerCase()) {
      case 'critical':
        ttoDeadline = DateTime.now().add(const Duration(hours: 1));
        break;
      case 'high':
        ttoDeadline = DateTime.now().add(const Duration(hours: 4));
        break;
      case 'low':
        ttoDeadline = DateTime.now().add(const Duration(hours: 48));
        break;
      case 'medium':
      default:
        ttoDeadline = DateTime.now().add(const Duration(hours: 24));
        break;
    }

    final response = await _client
        .from('tickets')
        .insert({
          'ticket_code': ticketCode,
          'phone_number': phoneNumber,
          'reporter_name': reporterName,
          'title': title,
          'description': description,
          'source': 'manual',
          'origin': origin,
          'organization_name': organizationName,
          'status': 'open',
          'priority': priority,
          'request_type': requestType,
          'impact': impact,
          'urgency': urgency,
          'user_profile_id': userProfileId,
          'service_item_id': serviceItemId,
          'service_id': catalogId,
          'assignee_id': assigneeId,
          'tto_deadline': ttoDeadline.toUtc().toIso8601String(),
        })
        .select()
        .single();

    return Ticket.fromMap(response);
  }
}
