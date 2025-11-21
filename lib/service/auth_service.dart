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
        
        // Kiểm tra nếu là lỗi 401 (Unauthorized) hoặc code lỗi xác thực
        String errorMessage;
        if (response.statusCode == 401 || 
            responseData['code'] == 401 ||
            (responseData['message'] != null && 
             (responseData['message'].toString().toLowerCase().contains('sai') ||
              responseData['message'].toString().toLowerCase().contains('invalid') ||
              responseData['message'].toString().toLowerCase().contains('incorrect') ||
              responseData['message'].toString().toLowerCase().contains('wrong')))) {
          errorMessage = 'Sai tài khoản hoặc mật khẩu';
        } else {
          errorMessage = responseData['message'] ?? 'Đăng nhập thất bại';
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      
      // Phân tích loại lỗi để đưa ra thông báo phù hợp
      String errorMessage;
      if (e.toString().contains('Failed to fetch') || e.toString().contains('Connection refused')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra:\n'
            '• Server backend có đang chạy không?\n'
            '• Kết nối mạng có ổn định không?\n'
            '• Địa chỉ server: $BASE_URL';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Server có thể đang quá tải hoặc mạng chậm.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      } else {
        errorMessage = 'Đã xảy ra lỗi khi kết nối đến server: ${e.toString()}';
      }
      
      return {'success': false, 'message': errorMessage};
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
      
      // Phân tích loại lỗi để đưa ra thông báo phù hợp
      String errorMessage;
      if (e.toString().contains('Failed to fetch') || e.toString().contains('Connection refused')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra:\n'
            '• Server backend có đang chạy không?\n'
            '• Kết nối mạng có ổn định không?\n'
            '• Địa chỉ server: $BASE_URL';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Server có thể đang quá tải hoặc mạng chậm.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      } else {
        errorMessage = 'Đã xảy ra lỗi khi kết nối đến server: ${e.toString()}';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }
}
