import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../models/user_profile.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<UserProfile>> fetchUsers() async {
    final response = await _client
        .from('user_profiles')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserProfile> createUser(Map<String, dynamic> data) async {
    final response = await _client
        .from('user_profiles')
        .insert(data)
        .select()
        .single();
    return UserProfile.fromMap(response);
  }

  Future<UserProfile> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('user_profiles')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return UserProfile.fromMap(response);
  }

  /// Bulk insert users from CSV import.
  /// Returns the number of successfully inserted rows.
  Future<int> bulkInsertUsers(List<Map<String, dynamic>> rows) async {
    final response = await _client
        .from('user_profiles')
        .insert(rows)
        .select();
    return (response as List).length;
  }
}
