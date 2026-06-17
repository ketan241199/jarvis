import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/tag_entity.dart';
import '../blocs/task/task_cubit.dart';
import '../blocs/task/task_state.dart';
import '../blocs/tag/tag_cubit.dart';
import '../blocs/tag/tag_state.dart';
import '../blocs/speech/speech_cubit.dart';
import '../blocs/speech/speech_state.dart';
import '../../services/speech_service.dart';
import '../widgets/task_card.dart';
import '../widgets/overdue_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/voice_input_button.dart';

/// Main home screen with three tabs: Today, Overdue, All.
///
/// Features:
/// - Tab-based task list filtering
/// - Overdue banner with count
/// - Voice input FAB
/// - Swipe to complete/delete
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
    context.read<TagCubit>().ensureDefaultsAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jarvis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: 'Work Schedule',
            onPressed: () => context.push('/schedule'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Overdue banner
          BlocBuilder<TaskCubit, TaskState>(
            buildWhen: (prev, curr) {
              if (prev is TaskLoaded && curr is TaskLoaded) {
                return prev.overdueCount != curr.overdueCount;
              }
              return true;
            },
            builder: (context, state) {
              if (state is TaskLoaded && state.overdueCount > 0) {
                return OverdueBanner(
                  count: state.overdueCount,
                  onTap: () {
                    context.read<TaskCubit>().setFilter(TaskFilter.overdue);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Filter tabs
          _buildFilterTabs(),

          // Task list
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFilterTabs() {
    return BlocBuilder<TaskCubit, TaskState>(
      buildWhen: (prev, curr) {
        if (prev is TaskLoaded && curr is TaskLoaded) {
          return prev.activeFilter != curr.activeFilter ||
              prev.overdueCount != curr.overdueCount;
        }
        return true;
      },
      builder: (context, state) {
        final activeFilter =
            state is TaskLoaded ? state.activeFilter : TaskFilter.today;
        final overdueCount = state is TaskLoaded ? state.overdueCount : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterTab(
                label: 'Today',
                isActive: activeFilter == TaskFilter.today,
                onTap: () =>
                    context.read<TaskCubit>().setFilter(TaskFilter.today),
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'Overdue',
                isActive: activeFilter == TaskFilter.overdue,
                badgeCount: overdueCount,
                onTap: () =>
                    context.read<TaskCubit>().setFilter(TaskFilter.overdue),
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'All',
                isActive: activeFilter == TaskFilter.all,
                onTap: () =>
                    context.read<TaskCubit>().setFilter(TaskFilter.all),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, taskState) {
        if (taskState is TaskLoading || taskState is TaskInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskState is TaskError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(taskState.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TaskCubit>().loadTasks(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (taskState is! TaskLoaded) return const SizedBox.shrink();

        if (taskState.tasks.isEmpty) {
          return switch (taskState.activeFilter) {
            TaskFilter.today => const EmptyState.today(),
            TaskFilter.overdue => const EmptyState.overdue(),
            TaskFilter.all => const EmptyState.all(),
          };
        }

        return BlocBuilder<TagCubit, TagState>(
          builder: (context, tagState) {
            final tags = tagState is TagLoaded ? tagState.tags : <TagEntity>[];
            final tagMap = {for (final t in tags) t.id: t};

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskCubit>().checkOverdue();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: taskState.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskState.tasks[index];
                  final tag = tagMap[task.tagId];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TaskCard(
                      task: task,
                      tag: tag,
                      onTap: () => context.push('/task/${task.id}'),
                      onComplete: () =>
                          context.read<TaskCubit>().completeTask(task),
                      onDelete: () =>
                          context.read<TaskCubit>().removeTask(task.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice input button
        BlocConsumer<SpeechCubit, SpeechState>(
          listener: (context, state) {
            if (state is SpeechResult) {
              _handleVoiceCommand(context, state);
            }
            if (state is SpeechUnavailable) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Speech recognition not available')),
              );
            }
          },
          builder: (context, state) {
            return VoiceInputButton(
              isListening: state is SpeechListening,
              partialText:
                  state is SpeechListening ? state.partialText : null,
              onPressed: () {
                if (state is SpeechListening) {
                  context.read<SpeechCubit>().stopListening();
                } else {
                  context.read<SpeechCubit>().startListening();
                }
              },
            );
          },
        ),
        const SizedBox(height: 8),

        // Add task button
        FloatingActionButton.small(
          heroTag: 'add_task',
          onPressed: () => context.push('/add-task'),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _handleVoiceCommand(BuildContext context, SpeechResult state) {
    final command = state.command;

    switch (command.action) {
      case VoiceAction.addTask:
        context.push('/add-task', extra: {
          'title': command.content,
          'tag': command.tag,
        });
        break;

      case VoiceAction.showOverdue:
        context.read<TaskCubit>().setFilter(TaskFilter.overdue);
        break;

      case VoiceAction.completeTask:
      case VoiceAction.removeTask:
        // For complete/remove, we'd need to find the matching task
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice command: ${command.action.name} "${command.content}"')),
        );
        break;

      case VoiceAction.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Heard: "${state.recognizedText}"')),
        );
        break;
    }

    context.read<SpeechCubit>().reset();
  }
}

/// Individual filter tab chip.
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.onPrimary.withAlpha(50)
                      : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: isActive
                        ? theme.colorScheme.onPrimary
                        : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
