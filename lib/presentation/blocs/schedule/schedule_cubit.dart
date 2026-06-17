import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/work_schedule_entity.dart';
import '../../../domain/usecases/schedule/get_schedule.dart';
import '../../../domain/usecases/schedule/save_schedule.dart';
import 'schedule_state.dart';

/// Cubit managing the work schedule state.
class ScheduleCubit extends Cubit<ScheduleState> {
  final GetSchedule _getSchedule;
  final SaveSchedule _saveSchedule;

  static const _uuid = Uuid();
  StreamSubscription<WorkScheduleEntity?>? _sub;

  ScheduleCubit({
    required GetSchedule getSchedule,
    required SaveSchedule saveSchedule,
  })  : _getSchedule = getSchedule,
        _saveSchedule = saveSchedule,
        super(const ScheduleInitial());

  /// Loads the schedule and subscribes to real-time updates.
  void loadSchedule() {
    emit(const ScheduleLoading());

    _sub?.cancel();
    _sub = _getSchedule().listen(
      (schedule) {
        if (schedule == null) {
          emit(const ScheduleNotSet());
        } else {
          emit(ScheduleLoaded(schedule));
        }
      },
      onError: (e) => emit(ScheduleError(e.toString())),
    );
  }

  /// Saves a new or updated schedule.
  Future<void> save(Map<int, DaySchedule> weekdays) async {
    try {
      emit(const ScheduleLoading());

      final currentState = state;
      final id = currentState is ScheduleLoaded
          ? currentState.schedule.id
          : _uuid.v4();

      final schedule = WorkScheduleEntity(
        id: id,
        weekdays: weekdays,
        updatedAt: DateTime.now(),
      );

      await _saveSchedule(schedule);
      // The stream subscription will emit the new state
    } catch (e) {
      emit(ScheduleError('Failed to save schedule: $e'));
    }
  }

  /// Creates a default Mon-Fri 9-6 schedule.
  Future<void> saveDefault() async {
    final weekdays = <int, DaySchedule>{};
    for (int i = 1; i <= 7; i++) {
      weekdays[i] = i <= 5
          ? DaySchedule.defaultWorkDay
          : DaySchedule.disabled;
    }
    await save(weekdays);
  }

  /// Whether a given date/time falls within work hours.
  bool isWorkTime(DateTime dateTime) {
    final currentState = state;
    if (currentState is! ScheduleLoaded) return false;
    return currentState.schedule.isWorkDay(dateTime.weekday);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
