import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/';

  static Future<http.Response> registerUser(
      String id,
      String nickname,
      String password,
      String location,
      String email) async {
    final Map<String, String> requestData = {
      'username': id,
      'nickname': nickname,
      'password': password,
      'location': location,
      'email': email,
    };

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 10)); // Timeout setting

      return response;
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}
