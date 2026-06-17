import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case: Update an existing task.
class UpdateTask {
  final TaskRepository _repository;

  const UpdateTask(this._repository);

  /// Updates the given [task].
  Future<void> call(TaskEntity task) {
    return _repository.updateTask(task);
  }
}
