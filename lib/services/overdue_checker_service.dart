import '../domain/repositories/task_repository.dart';
import 'notification_service.dart';

/// Service that checks for and marks overdue tasks.
///
/// Should be called on app startup. Queries Firestore for pending
/// tasks past their due date, marks them as overdue, and fires
/// a notification.
class OverdueCheckerService {
  final TaskRepository _taskRepository;

  const OverdueCheckerService(this._taskRepository);

  /// Runs the overdue check. Returns the number of newly overdue tasks.
  Future<int> check() async {
    final count = await _taskRepository.markOverdueTasks();

    if (count > 0) {
      await NotificationService.showOverdueNotification(taskCount: count);
    }

    return count;
  }
}
