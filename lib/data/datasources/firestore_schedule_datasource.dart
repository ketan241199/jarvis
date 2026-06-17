import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_schedule_model.dart';
import '../../core/constants/firestore_paths.dart';

/// Firestore data source for work schedule operations.
class FirestoreScheduleDataSource {
  final FirebaseFirestore _firestore;

  /// The schedule document ID. Since this is a single-user app,
  /// we use a fixed ID.
  static const String _scheduleDocId = 'user_schedule';

  FirestoreScheduleDataSource(this._firestore);

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(FirestorePaths.schedules).doc(_scheduleDocId);

  /// Watches the work schedule in real-time.
  Stream<WorkScheduleModel?> watch() {
    return _docRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return WorkScheduleModel.fromFirestore(snapshot);
    });
  }

  /// Fetches the current work schedule.
  Future<WorkScheduleModel?> get() async {
    final doc = await _docRef.get();
    if (!doc.exists) return null;
    return WorkScheduleModel.fromFirestore(doc);
  }

  /// Saves (creates or updates) the work schedule.
  Future<void> save(WorkScheduleModel schedule) async {
    await _docRef.set(
      schedule.toFirestore(),
      SetOptions(merge: true),
    );
  }
}
