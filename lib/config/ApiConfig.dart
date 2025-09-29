// lib/config/api_config.dart

class ApiConfig {
  // Singleton pattern
  static final ApiConfig _instance = ApiConfig._internal();

  factory ApiConfig() {
    return _instance;
  }

  ApiConfig._internal();

  // Base URL có thể truy cập từ mọi service
  // Wifi trường
  //String get baseUrl => "http://172.16.3.104:8080";

  // Iphone
  //String get baseUrl => "http://192.168.1.21:8080";

  String get baseUrl => "http://172.16.11.3:8080";

  //String get baseUrl => "http://192.168.100.127:8080";

}