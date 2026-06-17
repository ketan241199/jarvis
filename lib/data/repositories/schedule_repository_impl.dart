import '../../domain/entities/work_schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/firestore_schedule_datasource.dart';
import '../models/work_schedule_model.dart';

/// Concrete implementation of [ScheduleRepository] backed by Firestore.
class ScheduleRepositoryImpl implements ScheduleRepository {
  final FirestoreScheduleDataSource _dataSource;

  const ScheduleRepositoryImpl(this._dataSource);

  @override
  Stream<WorkScheduleEntity?> watchSchedule() => _dataSource.watch();

  @override
  Future<WorkScheduleEntity?> getSchedule() => _dataSource.get();

  @override
  Future<void> saveSchedule(WorkScheduleEntity schedule) =>
      _dataSource.save(WorkScheduleModel.fromEntity(schedule));
}
