import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloer_app/config/ApiConfig.dart';

class UserService {
  static final String BASE_URL = ApiConfig().baseUrl;

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return false;

    final response = await http.get(
      Uri.parse("$BASE_URL/users/check-token"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      prefs.remove('token');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/login"),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      throw Exception("Đăng xuất thất bại");
    }
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return null;
    }

    print("🔑 Token: ${token.substring(0, 10)}...");
    print("🌐 Calling API: $BASE_URL/users/info");

    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/users/info"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (!response.headers['content-type']!.contains('application/json')) {
          print("⚠️ API không trả về JSON: ${response.body}");
          return null;
        }

        final responseData = json.decode(response.body);
        if (responseData['code'] == 1000 && responseData['result'] != null) {
          print("✅ Parsed Data: ${responseData['result']}");
          return responseData['result'];
        } else {
          print("❌ API trả về code lỗi hoặc không có dữ liệu");
          return null;
        }
      } else {
        print("❌ Lỗi lấy dữ liệu: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  Future<bool> updateUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse("$BASE_URL/users/updateMyInfo"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        print("✅ Cập nhật thông tin thành công!");
        return true;
      } else {
        print("❌ Lỗi cập nhật: ${response.statusCode} - ${response.body}");
        // Ném exception để catch ở UI
        throw http.Response(response.body, response.statusCode);
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      if (e is http.ClientException || e is http.Response) {
        throw e; // Ném lại để UI xử lý
      }
      return false;
    }
  }

  Future<bool> register(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      print("⚠️ Mật khẩu xác nhận không khớp.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/users/create"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("✅ Đăng ký thành công! Hãy đăng nhập để tiếp tục.");
        return true;
      } else {
        print("❌ Lỗi đăng ký: ${responseData['message'] ?? 'Lỗi không xác định'}");
        return false;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối: $e");
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/api/password/request-reset"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      print("✅ OTP đã được gửi đến email");
      return true;
    } else {
      print("❌ Lỗi gửi OTP: ${response.body}");
      return false;
    }
  }

  Future<bool> verifyOtpAndResetPassword(String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/api/password/verify-otp"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otp': otp,
        'newPassword': newPassword,
        'confirmPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Mật khẩu đã được đặt lại thành công");
      return true;
    } else {
      print("❌ Lỗi xác thực OTP: ${response.body}");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getWeightLost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/users/weight-lost"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 1000 && responseData['result'] != null) {
          return responseData['result'];
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeightLostWeekly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/users/weight-lost/weekly"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 1000 && responseData['result'] != null) {
          return responseData['result'];
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeightLostMonthly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/users/weight-lost/monthly"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 1000 && responseData['result'] != null) {
          return responseData['result'];
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  Future<bool> updateWeightLostDaily() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/users/update-daily"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return false;
    }
  }

  Future<bool> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Không tìm thấy token, vui lòng đăng nhập lại!");
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse("$BASE_URL/users/clear-data"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 1000) {
          print("✅ Xóa dữ liệu thành công!");
          return true;
        } else {
          print("❌ Lỗi xóa dữ liệu: ${responseData['message'] ?? 'Lỗi không xác định'}");
          return false;
        }
      } else {
        print("❌ Lỗi xóa dữ liệu: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return false;
    }
  }
}