import '../../repositories/task_repository.dart';

/// Use case: Delete a task by ID.
class DeleteTask {
  final TaskRepository _repository;

  const DeleteTask(this._repository);

  /// Deletes the task with the given [taskId].
  Future<void> call(String taskId) {
    return _repository.deleteTask(taskId);
  }
}
