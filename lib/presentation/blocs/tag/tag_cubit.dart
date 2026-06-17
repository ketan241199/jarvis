import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/enums/tag_type.dart';
import '../../../domain/entities/tag_entity.dart';
import '../../../domain/usecases/tag/create_tag.dart';
import '../../../domain/usecases/tag/get_tags.dart';
import 'tag_state.dart';

/// Cubit managing tag state.
class TagCubit extends Cubit<TagState> {
  final GetTags _getTags;
  final CreateTag _createTag;

  static const _uuid = Uuid();
  StreamSubscription<List<TagEntity>>? _sub;

  TagCubit({
    required GetTags getTags,
    required CreateTag createTag,
  })  : _getTags = getTags,
        _createTag = createTag,
        super(const TagInitial());

  /// Loads tags and subscribes to real-time updates.
  void loadTags() {
    emit(const TagLoading());

    _sub?.cancel();
    _sub = _getTags().listen(
      (tags) => emit(TagLoaded(tags)),
      onError: (e) => emit(TagError(e.toString())),
    );
  }

  /// Ensures default tags exist, then loads.
  Future<void> ensureDefaultsAndLoad() async {
    try {
      await _getTags.ensureDefaults();
      loadTags();
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  /// Creates a new custom tag.
  Future<void> addTag({
    required String name,
    required int colorValue,
    TagType type = TagType.custom,
  }) async {
    try {
      final tag = TagEntity(
        id: _uuid.v4(),
        name: name,
        type: type,
        colorValue: colorValue,
        createdAt: DateTime.now(),
      );
      await _createTag(tag);
    } catch (e) {
      emit(TagError('Failed to create tag: $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
