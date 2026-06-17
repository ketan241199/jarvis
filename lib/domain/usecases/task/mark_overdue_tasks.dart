import '../../repositories/task_repository.dart';

/// Use case: Mark all pending tasks past their due date as overdue.
///
/// This should be called on app startup and periodically.
class MarkOverdueTasks {
  final TaskRepository _repository;

  const MarkOverdueTasks(this._repository);

  /// Scans and marks overdue tasks. Returns the count of newly marked tasks.
  Future<int> call() {
    return _repository.markOverdueTasks();
  }
}
