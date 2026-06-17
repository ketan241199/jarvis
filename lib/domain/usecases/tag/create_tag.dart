import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';

/// Use case: Create a new tag.
class CreateTag {
  final TagRepository _repository;

  const CreateTag(this._repository);

  /// Creates the given [tag] and returns its ID.
  Future<String> call(TagEntity tag) {
    return _repository.createTag(tag);
  }
}
