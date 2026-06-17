import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Banner displayed at the top of the overdue tasks section.
class OverdueBanner extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const OverdueBanner({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.overdueAccent.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.overdueAccent.withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.overdueAccent.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.overdueAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count Overdue Task${count == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.overdueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'These tasks need your attention',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.overdueAccent.withAlpha(180),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.overdueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
