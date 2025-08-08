// doctor_schedule_model.dart
class DoctorSchedule {
  final int schedulesID;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDuration;
  final bool isActive;

  DoctorSchedule({
    required this.schedulesID,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    required this.isActive,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      schedulesID: json['schedulesID'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      slotDuration: json['slotDuration'],
      isActive: json['isActive'],
    );
  }
}
