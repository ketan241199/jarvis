import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import '../../core/enums/task_priority.dart';
import '../../core/enums/task_status.dart';

/// Firestore-serializable task model.
///
/// Extends [TaskEntity] to add serialization without polluting the
/// domain layer — satisfying Open/Closed principle.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.createdAt,
    required super.dueDate,
    super.reminderTime,
    super.status,
    super.priority,
    required super.tagId,
    super.isWorkTask,
    super.completedAt,
    required super.updatedAt,
  });

  /// Creates a [TaskModel] from a Firestore document snapshot.
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      reminderTime: data['reminderTime'] != null
          ? (data['reminderTime'] as Timestamp).toDate()
          : null,
      status: TaskStatus.fromName(data['status'] as String),
      priority: TaskPriority.fromName(data['priority'] as String),
      tagId: data['tagId'] as String,
      isWorkTask: data['isWorkTask'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Creates a [TaskModel] from a [TaskEntity].
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
      reminderTime: entity.reminderTime,
      status: entity.status,
      priority: entity.priority,
      tagId: entity.tagId,
      isWorkTask: entity.isWorkTask,
      completedAt: entity.completedAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'status': status.name,
      'priority': priority.name,
      'tagId': tagId,
      'isWorkTask': isWorkTask,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
