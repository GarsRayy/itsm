import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/problem_model.dart';

final problemRepositoryProvider = Provider((ref) => ProblemRepository(Supabase.instance.client));

class ProblemRepository {
  final SupabaseClient _client;

  ProblemRepository(this._client);

  Future<List<ProblemModel>> getProblems() async {
    final response = await _client.from('problems').select().order('created_at', ascending: false);
    return response.map((json) => ProblemModel.fromJson(json)).toList();
  }

  Future<ProblemModel> createProblem(ProblemModel problem) async {
    final response = await _client.from('problems').insert(problem.toJson()).select().single();
    return ProblemModel.fromJson(response);
  }

  Future<void> updateProblemStatus(String id, String newStatus) async {
    await _client.from('problems').update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()}).eq('id', id);
  }
}
