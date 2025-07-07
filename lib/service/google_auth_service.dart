import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloer_app/config/ApiConfig.dart';

class GoogleAuthService {
  final String baseUrl = ApiConfig().baseUrl;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '964864343394-e11qdu8cd67mjmapl8sij239i43k68nh.apps.googleusercontent.com',
  );
  Future<Map<String, dynamic>> signIn() async {
    try {
      print('🔍 Checking if already signed in...');
      final bool isSignedIn = await _googleSignIn.isSignedIn();
      print('👤 isSignedIn: $isSignedIn');
      if (isSignedIn) {
        print('🚪 Signing out existing session...');
        await _googleSignIn.signOut();
      }

      print('📲 Initiating Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return {"success": false, "message": "Đăng nhập Google bị hủy"};
      }

      print('🔑 Obtaining authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      print('🛡️ idToken: ${idToken?.substring(0, 10)}... (shortened for security)');

      if (idToken == null) {
        print('⚠️ Failed to retrieve ID token from Google');
        throw Exception('Không lấy được ID token từ Google');
      }

      print('📤 Sending idToken to backend: $baseUrl/auth/google');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('✅ Response data: $responseData');
        if (responseData['code'] == 200 && responseData['result'] != null) {
          final String token = responseData['result']['token'];
          final Map<String, dynamic> userData = responseData['result']['user'];

          print('💾 Saving token and user data to SharedPreferences');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user_data', json.encode(userData));

          return {
            "success": true,
            "result": {"token": token, "user": userData}
          };
        } else {
          print('❌ Authentication failed: ${responseData['message'] ?? "No message"}');
          return {
            "success": false,
            "message": responseData['message'] ?? "Đăng nhập Google thất bại"
          };
        }
      } else {
        print('🚨 Server error: ${response.statusCode} - ${response.body}');
        return {
          "success": false,
          "message": "Lỗi server: ${response.statusCode}"
        };
      }
    } on PlatformException catch (e) {
      print('🔴 PlatformException: ${e.code} - ${e.message} - ${e.details}');
      return {
        "success": false,
        "message": "Lỗi đăng nhập Google: $e"
      };
    } catch (e) {
      print('🔴 Unexpected error: $e');
      return {
        "success": false,
        "message": "Lỗi đăng nhập Google: $e"
      };
    }
  }

  Future<void> signOut() async {
    try {
      print('🔍 Checking sign-in status for sign-out...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_data');
      print('💾 Cleared SharedPreferences');

      final isSignedIn = await _googleSignIn.isSignedIn();
      print('👤 isSignedIn: $isSignedIn');
      if (isSignedIn) {
        try {
          print('🔌 Disconnecting Google session...');
          await _googleSignIn.disconnect();
        } catch (e) {
          print('⚠️ Disconnect failed: $e');
        }
        print('🚪 Signing out from Google...');
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('🔴 Sign-out error: $e');
    }
  }

  Future<String?> getToken() async {
    print('🔑 Retrieving token from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔐 Token: ${token?.substring(0, 10)}... (shortened for security)');
    return token;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    print('👤 Retrieving user data from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user_data');
    if (userData != null) {
      print('📋 User data: $userData');
      return json.decode(userData);
    }
    print('⚠️ No user data found');
    return null;
  }

  Future<bool> isLoggedIn() async {
    print('🔍 Checking login status...');
    final token = await getToken();
    final isLogged = token != null && token.isNotEmpty;
    print('👤 isLoggedIn: $isLogged');
    return isLogged;
  }
}