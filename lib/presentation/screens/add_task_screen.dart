import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/task_priority.dart';
import '../../core/utils/validators.dart';
import '../blocs/task/task_cubit.dart';
import '../blocs/tag/tag_cubit.dart';
import '../blocs/tag/tag_state.dart';
import '../blocs/schedule/schedule_cubit.dart';
import '../widgets/tag_chip.dart';

/// Screen for creating a new task.
///
/// Features:
/// - Title and description input
/// - Date and time picker
/// - Tag selector (prompts user to tag)
/// - Priority selector
/// - Auto-detects work task based on schedule
class AddTaskScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialTag;

  const AddTaskScreen({
    super.key,
    this.initialTitle,
    this.initialTag,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedTagId;
  bool _isWorkTask = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController();

    // Auto-detect work task based on schedule
    final scheduleCubit = context.read<ScheduleCubit>();
    _isWorkTask = scheduleCubit.isWorkTime(DateTime.now());

    // Pre-select tag if provided via voice command
    if (widget.initialTag != null) {
      _preselectTag(widget.initialTag!);
    }
  }

  void _preselectTag(String tagName) {
    final tagState = context.read<TagCubit>().state;
    if (tagState is TagLoaded) {
      final match = tagState.tags.where(
        (t) => t.name.toLowerCase() == tagName.toLowerCase(),
      );
      if (match.isNotEmpty) {
        _selectedTagId = match.first.id;
        if (match.first.type.name == 'work') {
          _isWorkTask = true;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              autofocus: widget.initialTitle == null,
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.title),
              ),
              validator: Validators.taskTitle,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add details...',
                prefixIcon: Icon(Icons.notes),
              ),
              validator: Validators.taskDescription,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // Due Date
            Text('Due Date', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tag selector
            Text('Tag this task', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Choose a category for this task',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildTagSelector(),
            const SizedBox(height: 24),

            // Priority
            Text('Priority', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildPrioritySelector(),
            const SizedBox(height: 24),

            // Work task toggle
            SwitchListTile(
              title: const Text('Work Task'),
              subtitle: const Text('Highlight with work schedule styling'),
              secondary: const Icon(Icons.work_outline),
              value: _isWorkTask,
              onChanged: (value) => setState(() => _isWorkTask = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, size: 18),
          labelText: 'Date',
        ),
        child: Text(
          '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _dueTime,
        );
        if (picked != null) {
          setState(() => _dueTime = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.access_time, size: 18),
          labelText: 'Time',
        ),
        child: Text(_dueTime.format(context)),
      ),
    );
  }

  Widget _buildTagSelector() {
    return BlocBuilder<TagCubit, TagState>(
      builder: (context, state) {
        if (state is! TagLoaded) {
          return const LinearProgressIndicator();
        }

        // Auto-select 'Home' tag or initialTag by default if none selected
        if (_selectedTagId == null) {
          final targetTagName = widget.initialTag ?? 'Home';
          final match = state.tags.where(
            (t) => t.name.toLowerCase() == targetTagName.toLowerCase(),
          );
          if (match.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedTagId == null) {
                setState(() {
                  _selectedTagId = match.first.id;
                  if (match.first.type.name == 'work') {
                    _isWorkTask = true;
                  }
                });
              }
            });
          }
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...state.tags.map((tag) => TagChip(
                  tag: tag,
                  isSelected: _selectedTagId == tag.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTagId = selected ? tag.id : null;
                      // Auto-set work task if work tag selected
                      if (selected && tag.type.name == 'work') {
                        _isWorkTask = true;
                      }
                    });
                  },
                )),
            // Add new tag button
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('New Tag'),
              onPressed: () => _showCreateTagDialog(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrioritySelector() {
    return SegmentedButton<TaskPriority>(
      segments: TaskPriority.values.map((p) {
        return ButtonSegment(
          value: p,
          label: Text(p.label),
          icon: Icon(_priorityIcon(p), size: 16),
        );
      }).toList(),
      selected: {_priority},
      onSelectionChanged: (selected) {
        setState(() => _priority = selected.first);
      },
    );
  }

  IconData _priorityIcon(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => Icons.arrow_downward,
      TaskPriority.medium => Icons.remove,
      TaskPriority.high => Icons.arrow_upward,
      TaskPriority.urgent => Icons.priority_high,
    };
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            hintText: 'e.g., Gym, Shopping',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                context.read<TagCubit>().addTag(
                      name: name,
                      colorValue: Colors.teal.toARGB32(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTagId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tag for this task')),
      );
      return;
    }

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    context.read<TaskCubit>().addTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: dueDateTime,
          priority: _priority,
          tagId: _selectedTagId!,
          isWorkTask: _isWorkTask,
        );

    context.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task created!')),
    );
  }
}
