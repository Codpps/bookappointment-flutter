import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/specialization_model.dart';

class SpecializationService {
  Future<List<Specialization>> fetchSpecializations() async {
    final url = Uri.parse(ApiConstants.specializationEndpoint);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // pastikan ambil dari $values
        final List<dynamic> values = decoded['\$values'];

        // mapping json ke list model
        return values.map((json) => Specialization.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load specializations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
