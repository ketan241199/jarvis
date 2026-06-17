import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/work_schedule_entity.dart';
import '../blocs/schedule/schedule_cubit.dart';
import '../blocs/schedule/schedule_state.dart';

/// Screen for configuring the work schedule (Mon-Fri timings).
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Map<int, DaySchedule> _weekdays;
  bool _initialized = false;

  static const _dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    context.read<ScheduleCubit>().loadSchedule();
  }

  void _initWeekdays(WorkScheduleEntity? schedule) {
    if (_initialized) return;
    _initialized = true;

    if (schedule != null) {
      _weekdays = Map.from(schedule.weekdays);
    } else {
      // Default: Mon-Fri enabled, Sat-Sun disabled
      _weekdays = {};
      for (int i = 1; i <= 7; i++) {
        _weekdays[i] =
            i <= 5 ? DaySchedule.defaultWorkDay : DaySchedule.disabled;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Schedule'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleLoaded) {
            _initWeekdays(state.schedule);
          } else if (state is ScheduleNotSet) {
            _initWeekdays(null);
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_initialized) {
            _initWeekdays(null);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Text(
                'Set your work hours',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tasks created during work hours will be automatically tagged as work tasks.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Day rows
              ...List.generate(7, (i) => _buildDayRow(context, i + 1)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, int day) {
    final theme = Theme.of(context);
    final schedule = _weekdays[day] ?? DaySchedule.disabled;
    final isWeekend = day >= 6;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                // Day name
                SizedBox(
                  width: 100,
                  child: Text(
                    _dayNames[day]!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isWeekend
                          ? theme.colorScheme.onSurface.withAlpha(120)
                          : null,
                    ),
                  ),
                ),

                const Spacer(),

                // Enabled toggle
                Switch(
                  value: schedule.isEnabled,
                  onChanged: (enabled) {
                    setState(() {
                      _weekdays[day] = schedule.copyWith(isEnabled: enabled);
                    });
                  },
                  activeTrackColor: AppTheme.workAccent,
                ),
              ],
            ),

            // Time pickers (only shown when enabled)
            if (schedule.isEnabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeTile(
                      context,
                      'Start',
                      schedule.startTime,
                      (time) {
                        setState(() {
                          _weekdays[day] =
                              schedule.copyWith(startTime: time);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: _buildTimeTile(
                      context,
                      'End',
                      schedule.endTime,
                      (time) {
                        setState(() {
                          _weekdays[day] = schedule.copyWith(endTime: time);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              time.format(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    context.read<ScheduleCubit>().save(_weekdays);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule saved!')),
    );

    context.pop();
  }
}
