import 'package:flutter/material.dart';
import '../../core/enums/task_status.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/tag_entity.dart';

/// Reusable task card widget.
///
/// Displays task title, due date, tag, priority indicator, and status.
/// Work tasks have a distinct left border accent.
/// Overdue tasks have red highlighting.
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final TagEntity? tag;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.tag,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.status == TaskStatus.overdue;
    final isCompleted = task.status == TaskStatus.completed;
    final accentColor = _getAccentColor();

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(
        context,
        Colors.green,
        Icons.check_circle_outline,
        'Complete',
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        context,
        Colors.red,
        Icons.delete_outline,
        'Delete',
        Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: accentColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Checkbox
                  _buildCheckbox(context, isCompleted),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? theme.colorScheme.onSurface.withAlpha(100)
                                : null,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Due date + tag row
                        Row(
                          children: [
                            // Due date
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: isOverdue
                                  ? AppTheme.overdueAccent
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppDateUtils.formatDueDate(task.dueDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isOverdue
                                    ? AppTheme.overdueAccent
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),

                            if (tag != null) ...[
                              const SizedBox(width: 12),
                              _buildMiniTag(context),
                            ],

                            if (task.isWorkTask) ...[
                              const SizedBox(width: 8),
                              _buildWorkBadge(context),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Priority indicator
                  _buildPriorityDot(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, bool isCompleted) {
    return GestureDetector(
      onTap: onComplete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted
              ? Colors.green
              : Colors.transparent,
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildMiniTag(BuildContext context) {
    final tagColor = Color(tag!.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tagColor.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag!.name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tagColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildWorkBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.workAccent.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.workAccent.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_outline, size: 10, color: AppTheme.workAccent),
          const SizedBox(width: 2),
          Text(
            'Work',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.workAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDot(BuildContext context) {
    final color = switch (task.priority.name) {
      'urgent' => Colors.red,
      'high' => Colors.orange,
      'medium' => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Color _getAccentColor() {
    if (task.status == TaskStatus.overdue) return AppTheme.overdueAccent;
    if (task.isWorkTask) return AppTheme.workAccent;
    if (tag != null) return Color(tag!.colorValue);
    return AppTheme.customAccent;
  }

  Widget _buildDismissBackground(
    BuildContext context,
    Color color,
    IconData icon,
    String label,
    Alignment alignment,
  ) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
