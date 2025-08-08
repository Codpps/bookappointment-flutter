import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Schedule {
  final int schedulesID;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDuration;
  final bool isActive;

  Schedule({
    required this.schedulesID,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    required this.isActive,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      schedulesID: json['schedulesID'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '08:00', // Default start time
      endTime: json['endTime'] as String? ?? '17:00',   // Default end time
      slotDuration: json['slotDuration'] as int? ?? 30,  // Default 30 minutes
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
        'schedulesID': schedulesID,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'slotDuration': slotDuration,
        'isActive': isActive,
      };

  // Helper method to parse time string to DateTime
  DateTime parseTime(String timeString, DateTime date) {
    final parts = timeString.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // Get start time as DateTime for a specific date
  DateTime getStartTime(DateTime date) => parseTime(startTime, date);

  // Get end time as DateTime for a specific date
  DateTime getEndTime(DateTime date) => parseTime(endTime, date);

  // Generate all available time slots for this schedule on a specific date
  List<String> generateTimeSlots(DateTime date) {
    final slots = <String>[];
    final start = getStartTime(date);
    final end = getEndTime(date);
    final duration = Duration(minutes: slotDuration);

    DateTime current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('HH:mm').format(current));
      current = current.add(duration);
    }

    return slots;
  }

  // Check if a specific time is within this schedule
  bool isTimeWithinSchedule(TimeOfDay time, DateTime date) {
    final start = getStartTime(date);
    final end = getEndTime(date);
    final checkTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return (checkTime.isAfter(start) || checkTime.isAtSameMomentAs(start)) &&
        checkTime.isBefore(end);
  }

  // Get the duration of this schedule
  Duration get duration {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final start = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    final end = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return Duration(minutes: endMinutes - startMinutes);
  }

  @override
  String toString() {
    return 'Schedule(schedulesID: $schedulesID, dayOfWeek: $dayOfWeek, '
           'startTime: $startTime, endTime: $endTime, '
           'slotDuration: $slotDuration, isActive: $isActive)';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schedule &&
          runtimeType == other.runtimeType &&
          schedulesID == other.schedulesID &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          slotDuration == other.slotDuration &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      schedulesID.hashCode ^
      dayOfWeek.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      slotDuration.hashCode ^
      isActive.hashCode;
}