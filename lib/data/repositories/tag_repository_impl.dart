import '../../domain/entities/tag_entity.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/firestore_tag_datasource.dart';
import '../models/tag_model.dart';

/// Concrete implementation of [TagRepository] backed by Firestore.
class TagRepositoryImpl implements TagRepository {
  final FirestoreTagDataSource _dataSource;

  const TagRepositoryImpl(this._dataSource);

  @override
  Stream<List<TagEntity>> watchTags() => _dataSource.watchAll();

  @override
  Future<List<TagEntity>> getTags() => _dataSource.getAll();

  @override
  Future<TagEntity?> getTag(String id) => _dataSource.getById(id);

  @override
  Future<String> createTag(TagEntity tag) =>
      _dataSource.create(TagModel.fromEntity(tag));

  @override
  Future<void> updateTag(TagEntity tag) =>
      _dataSource.update(TagModel.fromEntity(tag));

  @override
  Future<void> deleteTag(String id) => _dataSource.delete(id);

  @override
  Future<void> ensureDefaultTags() => _dataSource.ensureDefaults();
}
