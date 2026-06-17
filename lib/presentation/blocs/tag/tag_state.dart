import 'package:equatable/equatable.dart';
import '../../../domain/entities/tag_entity.dart';

abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {
  const TagInitial();
}

class TagLoading extends TagState {
  const TagLoading();
}

class TagLoaded extends TagState {
  final List<TagEntity> tags;

  const TagLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagError extends TagState {
  final String message;

  const TagError(this.message);

  @override
  List<Object?> get props => [message];
}
