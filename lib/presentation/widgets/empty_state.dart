import 'package:flutter/material.dart';

/// Empty state placeholder widget shown when a task list is empty.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.check_circle_outline,
    this.title = 'No tasks',
    this.subtitle = 'Add a task to get started',
    this.action,
  });

  /// Empty state for the "Today" tab.
  const EmptyState.today({super.key})
      : icon = Icons.wb_sunny_outlined,
        title = 'All clear for today!',
        subtitle = 'No tasks due today. Enjoy your free time!',
        action = null;

  /// Empty state for the "Overdue" tab.
  const EmptyState.overdue({super.key})
      : icon = Icons.celebration_outlined,
        title = 'No overdue tasks!',
        subtitle = 'Great job staying on top of things.',
        action = null;

  /// Empty state for the "All" tab.
  const EmptyState.all({super.key})
      : icon = Icons.add_task,
        title = 'No tasks yet',
        subtitle = 'Tap + or use voice to add your first task.',
        action = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withAlpha(60),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
