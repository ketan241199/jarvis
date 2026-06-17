import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';

/// Use case: Get all tags with real-time updates.
class GetTags {
  final TagRepository _repository;

  const GetTags(this._repository);

  /// Watch all tags as a real-time stream.
  Stream<List<TagEntity>> call() => _repository.watchTags();

  /// Fetch all tags as a one-shot read.
  Future<List<TagEntity>> once() => _repository.getTags();

  /// Ensure default tags exist (idempotent).
  Future<void> ensureDefaults() => _repository.ensureDefaultTags();
}
