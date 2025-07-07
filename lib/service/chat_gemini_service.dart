import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:caloer_app/config/ApiConfig.dart';
class ChatGeminiService {
  static final String BASE_URL = ApiConfig().baseUrl;

  Future<String> sendMessage(String message) async {
    final Uri url = Uri.parse("$BASE_URL/api/gemini/generate");

    final Map<String, dynamic> body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": message}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data["result"] ?? "Lỗi: Không có phản hồi từ AI.";
      } else {
        return "Lỗi: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Lỗi khi gọi API: $e";
    }
  }
}
