import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloer_app/config/ApiConfig.dart';

class AuthService {
  static final String BASE_URL = ApiConfig().baseUrl;  // Lấy baseUrl từ ApiConfig

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("📤 Gửi request đăng nhập: $BASE_URL/auth");
      print("📧 Email: $email | 🔑 Password: ******"); // Không log password thực tế

      final response = await http.post(
        Uri.parse('$BASE_URL/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("📡 Phản hồi từ server: ${response.statusCode} - ${response.body}");
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['code'] == 0) {
        String token = responseData['result']['token'];
        print("✅ Đăng nhập thành công! Token nhận được: $token");

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return {'success': true, 'result': responseData['result']};
      } else {
        print("⚠️ Đăng nhập thất bại: ${responseData['message']}");
        return {'success': false, 'message': responseData['message'] ?? 'Đăng nhập thất bại'};
      }
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      return {'success': false, 'message': 'Đã xảy ra lỗi khi kết nối đến server'};
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    try {
      print("📤 Gửi request đăng ký: $BASE_URL/auth/register");
      print("👤 Họ tên: $fullName | 📧 Email: $email");

      final response = await http.post(
        Uri.parse('$BASE_URL/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'fullName': fullName}),
      );

      print("📡 Phản hồi từ server: ${response.statusCode} - ${response.body}");
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['code'] == 0) {
        print("✅ Đăng ký thành công!");
        return {'success': true, 'result': responseData['result']};
      } else {
        print("⚠️ Đăng ký thất bại: ${responseData['message']}");
        return {'success': false, 'message': responseData['message'] ?? 'Đăng ký thất bại'};
      }
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
      return {'success': false, 'message': 'Đã xảy ra lỗi khi kết nối đến server'};
    }
  }
}
