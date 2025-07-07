import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloer_app/config/ApiConfig.dart';

class WeightLostService {
  final String baseUrl = ApiConfig().baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Lấy cân nặng giảm tổng cộng
  Future<double> getTotalWeightLost() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token không tồn tại');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/weight-lost'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 1000 && data['result'] != null && data['result']['WeightLost'] != null) {
          return data['result']['WeightLost'].toDouble();
        }
        throw Exception('Dữ liệu cân nặng không hợp lệ');
      }
      throw Exception('Lỗi server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // Lấy cân nặng giảm theo tuần
  Future<double> getWeeklyWeightLost() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token không tồn tại');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/weight-lost/weekly'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 1000 && data['result'] != null && data['result']['WeightLost'] != null) {
          return data['result']['WeightLost'].toDouble();
        }
        throw Exception('Dữ liệu cân nặng không hợp lệ');
      }
      throw Exception('Lỗi server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // Lấy cân nặng giảm theo tháng
  Future<double> getMonthlyWeightLost() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token không tồn tại');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/weight-lost/monthly'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 1000 && data['result'] != null && data['result']['WeightLost'] != null) {
          return data['result']['WeightLost'].toDouble();
        }
        throw Exception('Dữ liệu cân nặng không hợp lệ');
      }
      throw Exception('Lỗi server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}