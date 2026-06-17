import '../entities/tag_entity.dart';

/// Abstract repository interface for tag operations.
///
/// Separated from [TaskRepository] to satisfy Interface Segregation (SOLID-I).
abstract class TagRepository {
  /// Returns a real-time stream of all tags.
  Stream<List<TagEntity>> watchTags();

  /// Fetches all tags as a one-shot read.
  Future<List<TagEntity>> getTags();

  /// Fetches a single tag by [id].
  Future<TagEntity?> getTag(String id);

  /// Creates a new tag. Returns the created tag's ID.
  Future<String> createTag(TagEntity tag);

  /// Updates an existing tag.
  Future<void> updateTag(TagEntity tag);

  /// Deletes a tag by [id].
  Future<void> deleteTag(String id);

  /// Ensures default tags (Home, Work, Personal) exist.
  /// Creates them if they don't. Idempotent.
  Future<void> ensureDefaultTags();
}
