import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/task_status.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task/task_cubit.dart';
import '../blocs/task/task_state.dart';
import '../blocs/tag/tag_cubit.dart';
import '../blocs/tag/tag_state.dart';
import '../widgets/schedule_badge.dart';

/// Screen for viewing and editing an individual task.
class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        if (state is! TaskLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = _findTask(state);
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
            actions: [
              IconButton(
                icon: Icon(task.status == TaskStatus.completed
                    ? Icons.radio_button_unchecked
                    : Icons.check_circle_outline),
                tooltip: task.status == TaskStatus.completed
                    ? 'Mark Pending'
                    : 'Mark Complete',
                onPressed: () {
                  context.read<TaskCubit>().completeTask(task);
                  context.pop();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, task),
              ),
            ],
          ),
          body: _buildBody(context, task, theme),
        );
      },
    );
  }

  TaskEntity? _findTask(TaskLoaded state) {
    // Search in main tasks and overdue tasks
    final allTasks = [...state.tasks, ...state.overdueTasks];
    try {
      return allTasks.firstWhere((t) => t.id == widget.taskId);
    } catch (_) {
      return null;
    }
  }

  Widget _buildBody(BuildContext context, TaskEntity task, ThemeData theme) {
    final isOverdue = task.status == TaskStatus.overdue;
    final isCompleted = task.status == TaskStatus.completed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status banner
        if (isOverdue)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.overdueAccent.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.overdueAccent.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppTheme.overdueAccent),
                const SizedBox(width: 8),
                Text(
                  'This task is overdue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.overdueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        if (isCompleted)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Completed ${task.completedAt != null ? AppDateUtils.formatDateTime(task.completedAt!) : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Title
        Text(
          task.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 16),

        // Badges row
        Row(
          children: [
            // Tag
            BlocBuilder<TagCubit, TagState>(
              builder: (context, tagState) {
                if (tagState is! TagLoaded) return const SizedBox.shrink();
                final tag = tagState.tags.where((t) => t.id == task.tagId);
                if (tag.isEmpty) return const SizedBox.shrink();

                final tagEntity = tag.first;
                final color = Color(tagEntity.colorValue);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tagEntity.name,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            ScheduleBadge(isWorkTask: task.isWorkTask),
            const SizedBox(width: 8),
            // Priority
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.priority.label,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Description
        if (task.description != null && task.description!.isNotEmpty) ...[
          Text('Description', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            task.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Details section
        Text('Details', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          Icons.calendar_today,
          'Due Date',
          AppDateUtils.formatDateTime(task.dueDate),
          isOverdue: isOverdue,
        ),
        _buildDetailRow(
          context,
          Icons.access_time,
          'Created',
          AppDateUtils.formatDateTime(task.createdAt),
        ),
        _buildDetailRow(
          context,
          Icons.update,
          'Last Updated',
          AppDateUtils.timeAgo(task.updatedAt),
        ),
        _buildDetailRow(
          context,
          Icons.flag_outlined,
          'Status',
          task.status.label,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isOverdue = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOverdue
                  ? AppTheme.overdueAccent
                  : theme.colorScheme.onSurface,
              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskCubit>().removeTask(task.id);
              Navigator.pop(ctx);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
