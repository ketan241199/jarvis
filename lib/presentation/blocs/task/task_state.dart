import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

/// Filter modes for the task list.
enum TaskFilter { today, overdue, all }

/// Base state for the TaskCubit.
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Loading state while fetching tasks.
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tasks loaded successfully.
class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final List<TaskEntity> overdueTasks;
  final TaskFilter activeFilter;
  final int overdueCount;

  const TaskLoaded({
    required this.tasks,
    this.overdueTasks = const [],
    this.activeFilter = TaskFilter.today,
    this.overdueCount = 0,
  });

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? overdueTasks,
    TaskFilter? activeFilter,
    int? overdueCount,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      activeFilter: activeFilter ?? this.activeFilter,
      overdueCount: overdueCount ?? this.overdueCount,
    );
  }

  @override
  List<Object?> get props => [tasks, overdueTasks, activeFilter, overdueCount];
}

/// Error state.
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
