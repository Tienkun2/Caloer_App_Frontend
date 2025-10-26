// lib/config/api_config.dart

class ApiConfig {
  // Singleton pattern
  static final ApiConfig _instance = ApiConfig._internal();

  factory ApiConfig() {
    return _instance;
  }

  ApiConfig._internal();

  // Main Backend Service URL (Java Spring Boot)
  // Wifi trường
  //String get baseUrl => "http://172.16.3.104:8080";

  // Iphone
  //String get baseUrl => "http://192.168.1.21:8080";

  String get baseUrl => "http://192.168.1.11:8080";

  //String get baseUrl => "http://192.168.100.127:8080";

  // AI Service URL (Python FastAPI) - chạy trên port khác
  String get baseUrlAi => "http://127.0.0.1:8000";

}