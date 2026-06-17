import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/enums/task_status.dart';
import '../datasources/firestore_task_datasource.dart';
import '../models/task_model.dart';

/// Concrete implementation of [TaskRepository] backed by Firestore.
///
/// Satisfies Liskov Substitution — can be swapped for any other
/// [TaskRepository] implementation (e.g., local storage for offline).
class TaskRepositoryImpl implements TaskRepository {
  final FirestoreTaskDataSource _dataSource;

  const TaskRepositoryImpl(this._dataSource);

  @override
  Stream<List<TaskEntity>> watchTasks() => _dataSource.watchAll();

  @override
  Stream<List<TaskEntity>> watchTasksByStatus(TaskStatus status) =>
      _dataSource.watchByStatus(status);

  @override
  Stream<List<TaskEntity>> watchTodayTasks() => _dataSource.watchToday();

  @override
  Stream<List<TaskEntity>> watchOverdueTasks() => _dataSource.watchOverdue();

  @override
  Stream<List<TaskEntity>> watchTasksByTag(String tagId) =>
      _dataSource.watchByTag(tagId);

  @override
  Future<TaskEntity?> getTask(String id) => _dataSource.getById(id);

  @override
  Future<String> createTask(TaskEntity task) =>
      _dataSource.create(TaskModel.fromEntity(task));

  @override
  Future<void> updateTask(TaskEntity task) =>
      _dataSource.update(TaskModel.fromEntity(task));

  @override
  Future<void> deleteTask(String id) => _dataSource.delete(id);

  @override
  Future<int> markOverdueTasks() => _dataSource.markOverdue();
}
