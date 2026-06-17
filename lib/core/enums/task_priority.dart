/// Priority level for a task.
///
/// Ordered from lowest to highest urgency.
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const TaskPriority(this.label);

  /// Human-readable label for display.
  final String label;

  /// Creates a [TaskPriority] from its string name.
  /// Returns [TaskPriority.medium] if the name is unrecognized.
  static TaskPriority fromName(String name) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TaskPriority.medium,
    );
  }
}
