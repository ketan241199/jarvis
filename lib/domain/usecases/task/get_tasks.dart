import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/enums/task_status.dart';

/// Use case: Get tasks with various filter options.
///
/// Provides reactive streams for real-time updates from Firestore.
class GetTasks {
  final TaskRepository _repository;

  const GetTasks(this._repository);

  /// Watch all tasks.
  Stream<List<TaskEntity>> all() => _repository.watchTasks();

  /// Watch tasks for today.
  Stream<List<TaskEntity>> today() => _repository.watchTodayTasks();

  /// Watch overdue tasks.
  Stream<List<TaskEntity>> overdue() => _repository.watchOverdueTasks();

  /// Watch tasks by status.
  Stream<List<TaskEntity>> byStatus(TaskStatus status) =>
      _repository.watchTasksByStatus(status);

  /// Watch tasks by tag.
  Stream<List<TaskEntity>> byTag(String tagId) =>
      _repository.watchTasksByTag(tagId);

  /// Get a single task by ID.
  Future<TaskEntity?> byId(String id) => _repository.getTask(id);
}
