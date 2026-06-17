import '../entities/work_schedule_entity.dart';

/// Abstract repository interface for work schedule operations.
abstract class ScheduleRepository {
  /// Returns a real-time stream of the work schedule.
  Stream<WorkScheduleEntity?> watchSchedule();

  /// Fetches the current work schedule.
  Future<WorkScheduleEntity?> getSchedule();

  /// Saves (creates or updates) the work schedule.
  Future<void> saveSchedule(WorkScheduleEntity schedule);
}
