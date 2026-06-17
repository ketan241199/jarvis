import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case: Create a new task.
///
/// Single Responsibility — this class only handles task creation logic.
class CreateTask {
  final TaskRepository _repository;

  const CreateTask(this._repository);

  /// Creates the given [task] and returns its ID.
  Future<String> call(TaskEntity task) {
    return _repository.createTask(task);
  }
}
