import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tag_entity.dart';
import '../../core/enums/tag_type.dart';

/// Firestore-serializable tag model.
class TagModel extends TagEntity {
  const TagModel({
    required super.id,
    required super.name,
    required super.type,
    required super.colorValue,
    required super.createdAt,
  });

  /// Creates a [TagModel] from a Firestore document snapshot.
  factory TagModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TagModel(
      id: doc.id,
      name: data['name'] as String,
      type: TagType.fromName(data['type'] as String),
      colorValue: data['colorValue'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Creates a [TagModel] from a [TagEntity].
  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      colorValue: entity.colorValue,
      createdAt: entity.createdAt,
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'colorValue': colorValue,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
