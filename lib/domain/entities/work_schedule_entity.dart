import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the user's work schedule configuration.
///
/// Maps weekday numbers (1=Monday .. 7=Sunday) to their schedule.
/// Only configured days are present in the map.
class WorkScheduleEntity extends Equatable {
  final String id;
  final Map<int, DaySchedule> weekdays;
  final DateTime updatedAt;

  const WorkScheduleEntity({
    required this.id,
    required this.weekdays,
    required this.updatedAt,
  });

  /// Whether the given [weekday] (1=Monday..7=Sunday) is a workday.
  bool isWorkDay(int weekday) {
    final schedule = weekdays[weekday];
    return schedule != null && schedule.isEnabled;
  }

  /// Whether the current time falls within work hours for today.
  bool get isCurrentlyWorkTime {
    final now = DateTime.now();
    final todaySchedule = weekdays[now.weekday];
    if (todaySchedule == null || !todaySchedule.isEnabled) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes =
        todaySchedule.startTime.hour * 60 + todaySchedule.startTime.minute;
    final endMinutes =
        todaySchedule.endTime.hour * 60 + todaySchedule.endTime.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  /// Creates a copy with the given fields replaced.
  WorkScheduleEntity copyWith({
    String? id,
    Map<int, DaySchedule>? weekdays,
    DateTime? updatedAt,
  }) {
    return WorkScheduleEntity(
      id: id ?? this.id,
      weekdays: weekdays ?? this.weekdays,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, weekdays, updatedAt];
}

/// Schedule for a single day of the week.
class DaySchedule extends Equatable {
  final bool isEnabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const DaySchedule({
    required this.isEnabled,
    required this.startTime,
    required this.endTime,
  });

  /// Default work day schedule: 9 AM - 6 PM.
  static const DaySchedule defaultWorkDay = DaySchedule(
    isEnabled: true,
    startTime: TimeOfDay(hour: 9, minute: 0),
    endTime: TimeOfDay(hour: 18, minute: 0),
  );

  /// Disabled day (weekend or day off).
  static const DaySchedule disabled = DaySchedule(
    isEnabled: false,
    startTime: TimeOfDay(hour: 9, minute: 0),
    endTime: TimeOfDay(hour: 18, minute: 0),
  );

  DaySchedule copyWith({
    bool? isEnabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return DaySchedule(
      isEnabled: isEnabled ?? this.isEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [isEnabled, startTime, endTime];
}
