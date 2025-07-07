import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloer_app/config/ApiConfig.dart';

class BarcodeService {
  final String baseUrl = ApiConfig().baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token không tồn tại');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barcode/$barcode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if response contains the expected 'result' object with 'id'
        if (data['code'] == 200 && data['result'] != null && data['result']['id'] != null) {
          return data['result']; // Return the 'result' object containing id, name, etc.
        }
        throw Exception('Dữ liệu sản phẩm không hợp lệ');
      }
      throw Exception('Lỗi server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}