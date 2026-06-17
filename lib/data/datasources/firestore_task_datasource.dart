import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/enums/task_status.dart';

/// Firestore data source for task CRUD operations.
///
/// Handles all direct Firestore interactions for tasks.
/// Repository delegates to this class — Single Responsibility.
class FirestoreTaskDataSource {
  final FirebaseFirestore _firestore;

  FirestoreTaskDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.tasks);

  /// Watches all tasks, ordered by due date.
  Stream<List<TaskModel>> watchAll() {
    return _collection
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Watches tasks filtered by [status].
  Stream<List<TaskModel>> watchByStatus(TaskStatus status) {
    return _collection
        .where('status', isEqualTo: status.name)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Watches today's tasks (due date is today, any status).
  Stream<List<TaskModel>> watchToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _collection
        .where('dueDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Watches overdue tasks (due before now, still pending).
  Stream<List<TaskModel>> watchOverdue() {
    return _collection
        .where('status', isEqualTo: TaskStatus.overdue.name)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Watches tasks filtered by [tagId].
  Stream<List<TaskModel>> watchByTag(String tagId) {
    return _collection
        .where('tagId', isEqualTo: tagId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Fetches a single task by [id].
  Future<TaskModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  /// Creates a new task. Returns the document ID.
  Future<String> create(TaskModel task) async {
    final docRef = _collection.doc(task.id);
    await docRef.set(task.toFirestore());
    return task.id;
  }

  /// Updates an existing task.
  Future<void> update(TaskModel task) async {
    await _collection.doc(task.id).update(task.toFirestore());
  }

  /// Deletes a task by [id].
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  /// Marks all pending tasks past their due date as overdue.
  /// Returns the count of updated tasks.
  Future<int> markOverdue() async {
    final now = DateTime.now();
    final query = await _collection
        .where('status', isEqualTo: TaskStatus.pending.name)
        .where('dueDate', isLessThan: Timestamp.fromDate(now))
        .get();

    if (query.docs.isEmpty) return 0;

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'status': TaskStatus.overdue.name,
        'updatedAt': Timestamp.fromDate(now),
      });
    }
    await batch.commit();
    return query.docs.length;
  }
}
