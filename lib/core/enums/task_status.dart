/// Status of a task in its lifecycle.
enum TaskStatus {
  pending('Pending'),
  completed('Completed'),
  overdue('Overdue');

  const TaskStatus(this.label);

  /// Human-readable label for display.
  final String label;

  /// Creates a [TaskStatus] from its string name.
  /// Returns [TaskStatus.pending] if the name is unrecognized.
  static TaskStatus fromName(String name) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TaskStatus.pending,
    );
  }
}
