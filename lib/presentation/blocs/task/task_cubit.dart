import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/create_task.dart';
import '../../../domain/usecases/task/delete_task.dart';
import '../../../domain/usecases/task/get_tasks.dart';
import '../../../domain/usecases/task/update_task.dart';
import '../../../domain/usecases/task/mark_overdue_tasks.dart';
import 'task_state.dart';

/// Cubit managing the task list state.
///
/// Subscribes to real-time Firestore streams and emits
/// state changes for the UI to react to.
class TaskCubit extends Cubit<TaskState> {
  final GetTasks _getTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final MarkOverdueTasks _markOverdueTasks;

  static const _uuid = Uuid();

  StreamSubscription<List<TaskEntity>>? _tasksSub;
  StreamSubscription<List<TaskEntity>>? _overdueSub;

  TaskCubit({
    required GetTasks getTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required MarkOverdueTasks markOverdueTasks,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        _markOverdueTasks = markOverdueTasks,
        super(const TaskInitial());

  /// Loads tasks and starts listening to real-time updates.
  void loadTasks({TaskFilter filter = TaskFilter.today}) {
    emit(const TaskLoading());

    _tasksSub?.cancel();
    _overdueSub?.cancel();

    // Subscribe to overdue count
    _overdueSub = _getTasks.overdue().listen(
      (overdueTasks) {
        final currentState = state;
        if (currentState is TaskLoaded) {
          emit(currentState.copyWith(
            overdueTasks: overdueTasks,
            overdueCount: overdueTasks.length,
          ));
        }
      },
    );

    // Subscribe to the filtered tasks
    _subscribeToFilter(filter);
  }

  /// Changes the active filter.
  void setFilter(TaskFilter filter) {
    _tasksSub?.cancel();
    _subscribeToFilter(filter);
  }

  void _subscribeToFilter(TaskFilter filter) {
    final Stream<List<TaskEntity>> stream;
    switch (filter) {
      case TaskFilter.today:
        stream = _getTasks.today();
        break;
      case TaskFilter.overdue:
        stream = _getTasks.overdue();
        break;
      case TaskFilter.all:
        stream = _getTasks.all();
        break;
    }

    _tasksSub = stream.listen(
      (tasks) {
        final currentState = state;
        final overdueCount = currentState is TaskLoaded
            ? currentState.overdueCount
            : 0;
        final overdueTasks = currentState is TaskLoaded
            ? currentState.overdueTasks
            : <TaskEntity>[];

        emit(TaskLoaded(
          tasks: tasks,
          overdueTasks: overdueTasks,
          activeFilter: filter,
          overdueCount: overdueCount,
        ));
      },
      onError: (error) {
        emit(TaskError(error.toString()));
      },
    );
  }

  /// Creates a new task with the given parameters.
  Future<void> addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    DateTime? reminderTime,
    TaskPriority priority = TaskPriority.medium,
    required String tagId,
    bool isWorkTask = false,
  }) async {
    try {
      final now = DateTime.now();
      final task = TaskEntity(
        id: _uuid.v4(),
        title: title,
        description: description,
        createdAt: now,
        dueDate: dueDate,
        reminderTime: reminderTime,
        status: TaskStatus.pending,
        priority: priority,
        tagId: tagId,
        isWorkTask: isWorkTask,
        updatedAt: now,
      );
      await _createTask(task);
    } catch (e) {
      emit(TaskError('Failed to create task: $e'));
    }
  }

  /// Toggles task completion status between completed and pending/overdue.
  Future<void> completeTask(TaskEntity task) async {
    try {
      final now = DateTime.now();
      final isCurrentlyCompleted = task.status == TaskStatus.completed;
      final targetStatus = isCurrentlyCompleted
          ? (task.dueDate.isBefore(now) ? TaskStatus.overdue : TaskStatus.pending)
          : TaskStatus.completed;

      await _updateTask(task.copyWith(
        status: targetStatus,
        completedAt: isCurrentlyCompleted ? null : now,
        updatedAt: now,
      ));
    } catch (e) {
      emit(TaskError('Failed to toggle task completion: $e'));
    }
  }

  /// Updates a task.
  Future<void> editTask(TaskEntity task) async {
    try {
      await _updateTask(task.copyWith(updatedAt: DateTime.now()));
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  /// Deletes a task.
  Future<void> removeTask(String taskId) async {
    try {
      await _deleteTask(taskId);
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  /// Scans and marks overdue tasks.
  Future<void> checkOverdue() async {
    try {
      await _markOverdueTasks();
    } catch (e) {
      // Silently handle — overdue check is best-effort
    }
  }

  @override
  Future<void> close() {
    _tasksSub?.cancel();
    _overdueSub?.cancel();
    return super.close();
  }
}
