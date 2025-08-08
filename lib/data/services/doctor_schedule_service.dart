// doctor_schedule_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_schedule_model.dart';
import '../../core/constants/api_constants.dart';

class DoctorScheduleService {
  Future<List<DoctorSchedule>> fetchDoctorSchedules(int doctorId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/DoctorSchedules/doctor/$doctorId'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> values = decoded['\$values'];

      return values.map((json) => DoctorSchedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doctor schedules');
    }
  }
}
