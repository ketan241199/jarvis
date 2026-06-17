import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/work_schedule_entity.dart';

/// Firestore-serializable work schedule model.
class WorkScheduleModel extends WorkScheduleEntity {
  const WorkScheduleModel({
    required super.id,
    required super.weekdays,
    required super.updatedAt,
  });

  /// Creates a [WorkScheduleModel] from a Firestore document snapshot.
  factory WorkScheduleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final weekdaysMap = data['weekdays'] as Map<String, dynamic>;

    final weekdays = <int, DaySchedule>{};
    for (final entry in weekdaysMap.entries) {
      final dayNum = int.parse(entry.key);
      final dayData = entry.value as Map<String, dynamic>;
      weekdays[dayNum] = DaySchedule(
        isEnabled: dayData['isEnabled'] as bool,
        startTime: TimeOfDay(
          hour: dayData['startHour'] as int,
          minute: dayData['startMinute'] as int,
        ),
        endTime: TimeOfDay(
          hour: dayData['endHour'] as int,
          minute: dayData['endMinute'] as int,
        ),
      );
    }

    return WorkScheduleModel(
      id: doc.id,
      weekdays: weekdays,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Creates a [WorkScheduleModel] from a [WorkScheduleEntity].
  factory WorkScheduleModel.fromEntity(WorkScheduleEntity entity) {
    return WorkScheduleModel(
      id: entity.id,
      weekdays: entity.weekdays,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    final weekdaysMap = <String, dynamic>{};
    for (final entry in weekdays.entries) {
      weekdaysMap[entry.key.toString()] = {
        'isEnabled': entry.value.isEnabled,
        'startHour': entry.value.startTime.hour,
        'startMinute': entry.value.startTime.minute,
        'endHour': entry.value.endTime.hour,
        'endMinute': entry.value.endTime.minute,
      };
    }

    return {
      'weekdays': weekdaysMap,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
