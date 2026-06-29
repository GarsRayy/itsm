import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';

final projectRepositoryProvider = Provider((ref) => ProjectRepository(Supabase.instance.client));

class ProjectRepository {
  final SupabaseClient _client;

  ProjectRepository(this._client);

  Future<List<ProjectModel>> getProjects() async {
    final response = await _client.from('projects').select().order('created_at', ascending: false);
    return response.map((json) => ProjectModel.fromJson(json)).toList();
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _client.from('projects').insert(project.toJson()).select().single();
    return ProjectModel.fromJson(response);
  }

  Future<void> updateProjectStatus(String id, String newStatus) async {
    await _client.from('projects').update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()}).eq('id', id);
  }
}
