import 'dart:convert';
import 'package:caloer_app/config/ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StepService {
  final String baseUrl = ApiConfig().baseUrl; // Thay bằng base URL của bạn

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> fetchSteps(String date) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token không tồn tại');

    final response = await http.post(
      Uri.parse('$baseUrl/steps'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 1000) {
        return data['result'];
      }
      throw Exception('Lỗi API: ${data['message']}');
    }
    throw Exception('Lỗi server: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateSteps(int steps) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token không tồn tại');

    final response = await http.post(
      Uri.parse('$baseUrl/steps'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'steps': steps,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 1000) {
        return data['result'];
      }
      throw Exception('Lỗi API: ${data['message']}');
    }
    throw Exception('Lỗi server: ${response.statusCode}');
  }
}