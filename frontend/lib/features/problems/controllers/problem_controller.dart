import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/problem_model.dart';
import '../repositories/problem_repository.dart';

final problemsControllerProvider = StateNotifierProvider<ProblemsController, AsyncValue<List<ProblemModel>>>((ref) {
  return ProblemsController(ref.watch(problemRepositoryProvider));
});

class ProblemsController extends StateNotifier<AsyncValue<List<ProblemModel>>> {
  final ProblemRepository _repository;

  ProblemsController(this._repository) : super(const AsyncValue.loading()) {
    fetchProblems();
  }

  Future<void> fetchProblems() async {
    try {
      state = const AsyncValue.loading();
      final problems = await _repository.getProblems();
      state = AsyncValue.data(problems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProblem(String title, String? rootCause) async {
    try {
      final ref = 'P-\${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final newProblem = ProblemModel(
        id: '',
        problemRef: ref,
        title: title,
        rootCause: rootCause,
        status: 'under_investigation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createProblem(newProblem);
      fetchProblems();
    } catch (e) {
      rethrow;
    }
  }
}
