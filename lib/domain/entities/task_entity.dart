import 'package:equatable/equatable.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';

/// Core task entity — the domain representation of a task.
///
/// This class is free from any data layer concerns (no Firestore
/// annotations). The data layer's [TaskModel] extends this for
/// serialization.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? reminderTime;
  final TaskStatus status;
  final TaskPriority priority;
  final String tagId;
  final bool isWorkTask;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.dueDate,
    this.reminderTime,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.tagId,
    this.isWorkTask = false,
    this.completedAt,
    required this.updatedAt,
  });

  /// Creates a copy of this entity with the given fields replaced.
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? reminderTime,
    TaskStatus? status,
    TaskPriority? priority,
    String? tagId,
    bool? isWorkTask,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tagId: tagId ?? this.tagId,
      isWorkTask: isWorkTask ?? this.isWorkTask,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        dueDate,
        reminderTime,
        status,
        priority,
        tagId,
        isWorkTask,
        completedAt,
        updatedAt,
      ];
}
