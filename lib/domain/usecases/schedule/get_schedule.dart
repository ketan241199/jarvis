import '../../entities/work_schedule_entity.dart';
import '../../repositories/schedule_repository.dart';

/// Use case: Get the work schedule with real-time updates.
class GetSchedule {
  final ScheduleRepository _repository;

  const GetSchedule(this._repository);

  /// Watch the work schedule as a real-time stream.
  Stream<WorkScheduleEntity?> call() => _repository.watchSchedule();

  /// Fetch the work schedule as a one-shot read.
  Future<WorkScheduleEntity?> once() => _repository.getSchedule();
}
