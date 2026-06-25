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
    required String title,
    required String description,
    required String requestType,
    required String priority,
    String? assigneeId,
  }) async {
    final randomCode = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000));
    final ticketCode = 'TKT-APP-$randomCode';

    final response = await _client
        .from('tickets')
        .insert({
          'ticket_code': ticketCode,
          'phone_number': phoneNumber,
          'reporter_name': reporterName,
          'title': title,
          'description': description,
          'source': 'mobile_app',
          'status': 'open',
          'priority': priority,
          'request_type': requestType,
          'user_profile_id': userProfileId,
          'service_item_id': serviceItemId,
          'assignee_id': assigneeId,
        })
        .select()
        .single();

    return Ticket.fromMap(response);
  }
}
