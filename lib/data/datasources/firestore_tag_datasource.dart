import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/tag_model.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/enums/tag_type.dart';
import '../../core/theme/app_theme.dart';

/// Firestore data source for tag CRUD operations.
class FirestoreTagDataSource {
  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  FirestoreTagDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.tags);

  /// Watches all tags.
  Stream<List<TagModel>> watchAll() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TagModel.fromFirestore(doc)).toList());
  }

  /// Fetches all tags.
  Future<List<TagModel>> getAll() async {
    final snapshot = await _collection.orderBy('name').get();
    return snapshot.docs.map((doc) => TagModel.fromFirestore(doc)).toList();
  }

  /// Fetches a single tag by [id].
  Future<TagModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return TagModel.fromFirestore(doc);
  }

  /// Creates a new tag. Returns the document ID.
  Future<String> create(TagModel tag) async {
    final docRef = _collection.doc(tag.id);
    await docRef.set(tag.toFirestore());
    return tag.id;
  }

  /// Updates an existing tag.
  Future<void> update(TagModel tag) async {
    await _collection.doc(tag.id).update(tag.toFirestore());
  }

  /// Deletes a tag by [id].
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  /// Ensures default tags exist. Creates them if the collection is empty.
  Future<void> ensureDefaults() async {
    final existing = await _collection.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final defaults = [
      TagModel(
        id: _uuid.v4(),
        name: 'Work',
        type: TagType.work,
        colorValue: AppTheme.workAccent.toARGB32(),
        createdAt: now,
      ),
      TagModel(
        id: _uuid.v4(),
        name: 'Home',
        type: TagType.home,
        colorValue: AppTheme.homeAccent.toARGB32(),
        createdAt: now,
      ),
      TagModel(
        id: _uuid.v4(),
        name: 'Personal',
        type: TagType.personal,
        colorValue: AppTheme.personalAccent.toARGB32(),
        createdAt: now,
      ),
    ];

    final batch = _firestore.batch();
    for (final tag in defaults) {
      batch.set(_collection.doc(tag.id), tag.toFirestore());
    }
    await batch.commit();
  }
}
