import '../../entities/work_schedule_entity.dart';
import '../../repositories/schedule_repository.dart';

/// Use case: Save (create or update) the work schedule.
class SaveSchedule {
  final ScheduleRepository _repository;

  const SaveSchedule(this._repository);

  /// Saves the given [schedule].
  Future<void> call(WorkScheduleEntity schedule) {
    return _repository.saveSchedule(schedule);
  }
}
