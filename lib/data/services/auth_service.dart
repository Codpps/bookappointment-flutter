import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(response.body);
          final user = UserModel.fromJson(json);

          await _secureStorage.write(key: 'token', value: user.token);
          return user;
        } else {
          throw Exception("Login failed: Empty response from server");
        }
      } else {
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            throw Exception("Login failed: ${error['message'] ?? 'Unknown error'}");
          } catch (_) {
            throw Exception("Login failed: Unexpected response format");
          }
        } else {
          throw Exception("Login failed: No error message received from server");
        }
      }
    } catch (e) {
      print("Login Error: $e");
      throw Exception("Login error: $e");
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
  }
}
