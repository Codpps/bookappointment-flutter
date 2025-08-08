import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/doctor_model.dart';

class DoctorService {
  Future<List<Doctor>> fetchDoctorsBySpecialization(int specializationId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/Doctors/by-specialization/$specializationId"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Handle API response format with $values
        final doctorsData = decoded is List ? decoded : decoded['\$values'] as List? ?? [];

        return doctorsData.map<Doctor>((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching doctors: $e');
    }
  }

  Future<Doctor> fetchDoctorDetails(int doctorId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/Doctors/$doctorId"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Doctor.fromJson(decoded);
      } else {
        throw Exception('Failed to load doctor details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching doctor details: $e');
    }
  }

  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/Doctors/search?query=$query"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final doctorsData = decoded is List ? decoded : decoded['\$values'] as List? ?? [];
        return doctorsData.map<Doctor>((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Search failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during search: $e');
    }
  }

 Future<List<Schedule>> fetchDoctorSchedules(int doctorId) async {
  try {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/DoctorSchedules/doctor/$doctorId"),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Handle both direct array and {$values: [...]} formats
      final schedulesData = decoded is List ? decoded :
                          decoded['\$values'] as List? ?? [];

      if (schedulesData.isEmpty) {
        throw Exception('No schedules found for doctor $doctorId');
      }

      return schedulesData.map<Schedule>((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load schedules for doctor $doctorId. '
                    'Status code: ${response.statusCode}');
    }
  } on FormatException catch (e) {
    throw Exception('Invalid response format for doctor $doctorId: $e');
  } catch (e) {
    throw Exception('Failed to fetch schedules for doctor $doctorId: $e');
  }
}
}