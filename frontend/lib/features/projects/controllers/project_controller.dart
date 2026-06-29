import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';

final projectsControllerProvider = StateNotifierProvider<ProjectsController, AsyncValue<List<ProjectModel>>>((ref) {
  return ProjectsController(ref.watch(projectRepositoryProvider));
});

class ProjectsController extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository _repository;

  ProjectsController(this._repository) : super(const AsyncValue.loading()) {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      state = const AsyncValue.loading();
      final projects = await _repository.getProjects();
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProject(String title, String? desc) async {
    try {
      final ref = 'PRJ-\${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final newProject = ProjectModel(
        id: '',
        projectRef: ref,
        title: title,
        description: desc,
        status: 'planning',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createProject(newProject);
      fetchProjects();
    } catch (e) {
      rethrow;
    }
  }
}
