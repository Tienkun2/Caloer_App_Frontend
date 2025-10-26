import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloer_app/config/ApiConfig.dart';

class FoodService {
  static final String BASE_URL = ApiConfig().baseUrl;
  static final String BASE_URL_AI = ApiConfig().baseUrlAi;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token?.trim();
  }

  Future<List<Map<String, dynamic>>> fetchRandomFoods() async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      final response = await http.get(
        Uri.parse('$BASE_URL/food/random'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data["result"]);
      } else {
        throw Exception("Lỗi khi tải dữ liệu món ăn");
      }
    } catch (e) {
      print("🔴 Lỗi fetchRandomFoods: $e");
      throw Exception("Lỗi fetchRandomFoods: $e");
    }
  }

  Future<List<Map<String, dynamic>>> searchFoods(String keyword) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      final response = await http.get(
        Uri.parse('$BASE_URL/food/search?keyword=$keyword'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // Kiểm tra xem "result" có tồn tại và là một List không
        if (data["result"] is List) {
          return List<Map<String, dynamic>>.from(data["result"]);
        } else {
          throw Exception('Dữ liệu từ API không đúng định dạng: "result" không phải là danh sách');
        }
      } else {
        throw Exception('Lỗi khi tìm kiếm món ăn: ${response.statusCode}');
      }
    } catch (e) {
      print("🔴 Lỗi searchFoods: $e");
      throw Exception("Lỗi searchFoods: $e");
    }
  }

  Future<Map<String, dynamic>> fetchFoodDetail(int foodId) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      final response = await http.get(
        Uri.parse('$BASE_URL/food/$foodId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data["result"] as Map<String, dynamic>? ?? {};
        double servingAmount = 100.0;
        if (result["servingSize"] != null) {
          String servingSize = result["servingSize"] as String;
          final numericPart = servingSize.replaceAll(RegExp(r'[^0-9.]'), '');
          servingAmount = double.tryParse(numericPart) ?? 100.0;
        }

        return {
          "id": result["id"] ?? 0,
          "name": result["name"] ?? "Unknown Food",
          "calories": result["calories"] is num ? (result["calories"] as num).toDouble() : 0.0,
          "protein": result["protein"] is num ? (result["protein"] as num).toDouble() : 0.0,
          "fat": result["fat"] is num ? (result["fat"] as num).toDouble() : 0.0,
          "carbs": result["carbs"] is num ? (result["carbs"] as num).toDouble() : 0.0,
          "fiber": result["fiber"] is num ? (result["fiber"] as num).toDouble() : 0.0,
          "servingAmount": servingAmount,
          "servingSize": result["servingSize"] ?? "100g",
          "createdAt": result["createdAt"] ?? DateTime.now().toIso8601String(),
          "updatedAt": result["updatedAt"] ?? DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception("Lỗi khi tải thông tin chi tiết món ăn");
      }
    } catch (e) {
      print("🔴 Lỗi fetchFoodDetail: $e");
      throw Exception("Lỗi fetchFoodDetail: $e");
    }
  }

  Future<Map<String, dynamic>> addFoodToMeal(Map<String, dynamic> data) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      print("🟡 Gửi request đến: $BASE_URL/meal-log/create");
      print("🔵 Dữ liệu gửi lên: ${jsonEncode(data)}");
      print("🟠 Token gửi kèm: $token");

      final response = await http.post(
        Uri.parse("$BASE_URL/meal-log/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Lỗi HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("🔴 Lỗi addFoodToMeal: $e");
      throw Exception("Lỗi addFoodToMeal: $e");
    }
  }

  Future<Map<String, dynamic>> fetchMealLogs(String date) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      final response = await http.get(
        Uri.parse('$BASE_URL/meal-log?date=$date'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi khi lấy meal logs');
      }
    } catch (e) {
      print("🔴 Lỗi fetchMealLogs: $e");
      throw Exception("Lỗi fetchMealLogs: $e");
    }
  }

  Future<Map<String, dynamic>> updateMealLogWeight(int mealLogId, String date, int foodId, int weightInGrams) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      final Map<String, dynamic> requestData = {
        "date": date,
        "foodId": foodId,
        "weightInGrams": weightInGrams
      };

      print("🟡 Gửi request đến: $BASE_URL/meal-log/$mealLogId");
      print("🔵 Dữ liệu cập nhật: ${jsonEncode(requestData)}");

      final response = await http.put(
        Uri.parse("$BASE_URL/meal-log/$mealLogId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Lỗi HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("🔴 Lỗi updateMealLogWeight: $e");
      throw Exception("Lỗi updateMealLogWeight: $e");
    }
  }

  Future<bool> deleteMealLog(int mealLogId, String date) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      print("🟡 Gửi request đến: $BASE_URL/meal-log/$mealLogId?date=$date");

      final response = await http.delete(
        Uri.parse("$BASE_URL/meal-log/$mealLogId?date=$date"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Lỗi HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("🔴 Lỗi deleteMealLog: $e");
      throw Exception("Lỗi deleteMealLog: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchMealSuggestions() async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) throw Exception("Không tìm thấy token!");

      final response = await http.get(
        Uri.parse('$BASE_URL/meal-log/suggest-meal'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data["result"]);
      } else {
        throw Exception("Lỗi khi tải gợi ý bữa ăn: ${response.statusCode}");
      }
    } catch (e) {
      print("🔴 Lỗi fetchMealSuggestions: $e");
      throw Exception("Lỗi fetchMealSuggestions: $e");
    }
  }

  // API predict mới
  Future<Map<String, dynamic>> predictFood(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL_AI/predict'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": content}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data["success"] == true && data["result"]["success"] == true) {
          final result = data["result"];
          final nutrition = result["nutrition_info"];
          
          return {
            "id": DateTime.now().millisecondsSinceEpoch,
            "name": result["food"] ?? "Unknown Food",
            "calories": (result["calories"] ?? 0).toDouble(),
            "protein": (nutrition["protein"] ?? 0).toDouble(),
            "fat": (nutrition["fat"] ?? 0).toDouble(),
            "carbs": (nutrition["carbs"] ?? 0).toDouble(),
            "fiber": (nutrition["fiber"] ?? 0).toDouble(),
            "servingAmount": (result["quantity"] ?? 100).toDouble(),
            "servingSize": "${result["quantity"] ?? 100}${result["unit"] ?? "g"}",
            "createdAt": DateTime.now().toIso8601String(),
            "updatedAt": DateTime.now().toIso8601String(),
            "isFromPredict": true,
          };
        } else {
          throw Exception("Predict API trả về lỗi: ${data["result"]["message"] ?? "Unknown error"}");
        }
      } else {
        throw Exception("Lỗi HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Lỗi predictFood: $e");
    }
  }
}