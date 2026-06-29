import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/change_model.dart';

final changeRepositoryProvider = Provider((ref) => ChangeRepository(Supabase.instance.client));

class ChangeRepository {
  final SupabaseClient _client;

  ChangeRepository(this._client);

  Future<List<ChangeModel>> getChanges() async {
    final response = await _client.from('changes').select().order('created_at', ascending: false);
    return response.map((json) => ChangeModel.fromJson(json)).toList();
  }

  Future<ChangeModel> createChange(ChangeModel change) async {
    final response = await _client.from('changes').insert(change.toJson()).select().single();
    return ChangeModel.fromJson(response);
  }

  Future<void> updateChangeStatus(String id, String newStatus) async {
    await _client.from('changes').update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()}).eq('id', id);
  }
}
