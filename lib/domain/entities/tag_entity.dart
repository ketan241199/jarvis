import 'package:equatable/equatable.dart';
import '../../../core/enums/tag_type.dart';

/// Core tag entity — represents a task classification tag.
///
/// Tags allow users to categorize tasks (Home, Work, Personal, or custom).
/// Each tag has a color for visual differentiation in the UI.
class TagEntity extends Equatable {
  final String id;
  final String name;
  final TagType type;
  final int colorValue;
  final DateTime createdAt;

  const TagEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.createdAt,
  });

  /// Creates a copy of this entity with the given fields replaced.
  TagEntity copyWith({
    String? id,
    String? name,
    TagType? type,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, type, colorValue, createdAt];
}
