import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/change_model.dart';
import '../repositories/change_repository.dart';

final changesControllerProvider = StateNotifierProvider<ChangesController, AsyncValue<List<ChangeModel>>>((ref) {
  return ChangesController(ref.watch(changeRepositoryProvider));
});

class ChangesController extends StateNotifier<AsyncValue<List<ChangeModel>>> {
  final ChangeRepository _repository;

  ChangesController(this._repository) : super(const AsyncValue.loading()) {
    fetchChanges();
  }

  Future<void> fetchChanges() async {
    try {
      state = const AsyncValue.loading();
      final changes = await _repository.getChanges();
      state = AsyncValue.data(changes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createChange(String title, String subclass, String? desc) async {
    try {
      final ref = 'C-\${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final newChange = ChangeModel(
        id: '',
        changeRef: ref,
        title: title,
        subclass: subclass,
        status: 'planned_and_scheduled',
        description: desc,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createChange(newChange);
      fetchChanges();
    } catch (e) {
      rethrow;
    }
  }
}
