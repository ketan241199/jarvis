import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Data sources
import '../../data/datasources/firestore_task_datasource.dart';
import '../../data/datasources/firestore_tag_datasource.dart';
import '../../data/datasources/firestore_schedule_datasource.dart';

// Repositories
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/schedule_repository.dart';

// Use cases — Task
import '../../domain/usecases/task/create_task.dart';
import '../../domain/usecases/task/update_task.dart';
import '../../domain/usecases/task/delete_task.dart';
import '../../domain/usecases/task/get_tasks.dart';
import '../../domain/usecases/task/mark_overdue_tasks.dart';

// Use cases — Tag
import '../../domain/usecases/tag/create_tag.dart';
import '../../domain/usecases/tag/get_tags.dart';

// Use cases — Schedule
import '../../domain/usecases/schedule/save_schedule.dart';
import '../../domain/usecases/schedule/get_schedule.dart';

// Services
import '../../services/speech_service.dart';
import '../../services/overdue_checker_service.dart';

// BLoC
import '../../presentation/blocs/task/task_cubit.dart';
import '../../presentation/blocs/tag/tag_cubit.dart';
import '../../presentation/blocs/schedule/schedule_cubit.dart';
import '../../presentation/blocs/speech/speech_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Registers all dependencies in the service locator.
///
/// Registration order follows Dependency Inversion:
/// External → DataSources → Repositories → UseCases → Services → Cubits
void setupDependencies() {
  // ── External ───────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ── Data Sources ───────────────────────────────────────────
  sl.registerLazySingleton(
    () => FirestoreTaskDataSource(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton(
    () => FirestoreTagDataSource(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton(
    () => FirestoreScheduleDataSource(sl<FirebaseFirestore>()),
  );

  // ── Repositories ───────────────────────────────────────────
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl<FirestoreTaskDataSource>()),
  );
  sl.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(sl<FirestoreTagDataSource>()),
  );
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(sl<FirestoreScheduleDataSource>()),
  );

  // ── Use Cases — Task ───────────────────────────────────────
  sl.registerLazySingleton(() => CreateTask(sl<TaskRepository>()));
  sl.registerLazySingleton(() => UpdateTask(sl<TaskRepository>()));
  sl.registerLazySingleton(() => DeleteTask(sl<TaskRepository>()));
  sl.registerLazySingleton(() => GetTasks(sl<TaskRepository>()));
  sl.registerLazySingleton(() => MarkOverdueTasks(sl<TaskRepository>()));

  // ── Use Cases — Tag ────────────────────────────────────────
  sl.registerLazySingleton(() => CreateTag(sl<TagRepository>()));
  sl.registerLazySingleton(() => GetTags(sl<TagRepository>()));

  // ── Use Cases — Schedule ───────────────────────────────────
  sl.registerLazySingleton(() => SaveSchedule(sl<ScheduleRepository>()));
  sl.registerLazySingleton(() => GetSchedule(sl<ScheduleRepository>()));

  // ── Services ───────────────────────────────────────────────
  sl.registerLazySingleton(() => SpeechService());
  sl.registerLazySingleton(
    () => OverdueCheckerService(sl<TaskRepository>()),
  );

  // ── Cubits (Factory — new instance per widget tree) ────────
  sl.registerFactory(
    () => TaskCubit(
      getTasks: sl<GetTasks>(),
      createTask: sl<CreateTask>(),
      updateTask: sl<UpdateTask>(),
      deleteTask: sl<DeleteTask>(),
      markOverdueTasks: sl<MarkOverdueTasks>(),
    ),
  );
  sl.registerFactory(
    () => TagCubit(
      getTags: sl<GetTags>(),
      createTag: sl<CreateTag>(),
    ),
  );
  sl.registerFactory(
    () => ScheduleCubit(
      getSchedule: sl<GetSchedule>(),
      saveSchedule: sl<SaveSchedule>(),
    ),
  );
  sl.registerFactory(
    () => SpeechCubit(speechService: sl<SpeechService>()),
  );
}
