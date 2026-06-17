import '../entities/task_entity.dart';
import '../../core/enums/task_status.dart';

/// Abstract repository interface for task operations.
///
/// Follows Interface Segregation (SOLID-I) — only task-related
/// operations. Dependency Inversion (SOLID-D) — domain layer
/// defines this interface, data layer implements it.
abstract class TaskRepository {
  /// Returns a real-time stream of all tasks.
  Stream<List<TaskEntity>> watchTasks();

  /// Returns a real-time stream of tasks filtered by [status].
  Stream<List<TaskEntity>> watchTasksByStatus(TaskStatus status);

  /// Returns a real-time stream of tasks for today.
  Stream<List<TaskEntity>> watchTodayTasks();

  /// Returns a real-time stream of overdue tasks.
  Stream<List<TaskEntity>> watchOverdueTasks();

  /// Returns a real-time stream of tasks filtered by [tagId].
  Stream<List<TaskEntity>> watchTasksByTag(String tagId);

  /// Fetches a single task by [id].
  Future<TaskEntity?> getTask(String id);

  /// Creates a new task. Returns the created task's ID.
  Future<String> createTask(TaskEntity task);

  /// Updates an existing task.
  Future<void> updateTask(TaskEntity task);

  /// Deletes a task by [id].
  Future<void> deleteTask(String id);

  /// Marks all tasks with due dates before now as overdue
  /// (if they are still pending).
  Future<int> markOverdueTasks();
}
