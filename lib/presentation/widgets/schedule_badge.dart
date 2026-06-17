import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Small badge indicating a task is a work task.
class ScheduleBadge extends StatelessWidget {
  final bool isWorkTask;
  final bool isCurrentlyWorkTime;

  const ScheduleBadge({
    super.key,
    this.isWorkTask = false,
    this.isCurrentlyWorkTime = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWorkTask) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.workAccent.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.workAccent.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline,
            size: 12,
            color: AppTheme.workAccent,
          ),
          const SizedBox(width: 4),
          Text(
            isCurrentlyWorkTime ? 'Work Hours' : 'Work',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.workAccent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
