import 'package:equatable/equatable.dart';
import '../../../domain/entities/work_schedule_entity.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final WorkScheduleEntity schedule;

  const ScheduleLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleNotSet extends ScheduleState {
  const ScheduleNotSet();
}

class ScheduleSaved extends ScheduleState {
  const ScheduleSaved();
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
