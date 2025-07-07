import 'package:flutter/material.dart';
import "package:caloer_app/service/user_service.dart";

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _otpSent = false; // Kiểm tra xem OTP đã gửi chưa

  final UserService _userService = UserService();

  // 📨 Yêu cầu gửi OTP
  void _sendOtp() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) return;

    bool success = await _userService.requestPasswordReset(email);
    if (success) {
      setState(() {
        _otpSent = true; // Chuyển sang bước nhập OTP
      });
    }
  }

  // ✅ Xác thực OTP và đặt lại mật khẩu
  void _resetPassword() async {
    String otp = _otpController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty) return;

    bool success = await _userService.verifyOtpAndResetPassword(otp, newPassword);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu đã được đặt lại thành công!')),
      );
      Navigator.pop(context); // Quay về màn hình đăng nhập
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  height: 150,
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: 40),

                // Nhập Email
                if (!_otpSent) ...[
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 24),
                  _buildButton('Gửi OTP', _sendOtp),
                ]
                // Nhập OTP & Mật khẩu mới
                else ...[
                  _buildTextField(_otpController, 'Nhập OTP', Icons.lock),
                  const SizedBox(height: 16),
                  _buildTextField(_newPasswordController, 'Mật khẩu mới', Icons.lock, obscureText: true),
                  const SizedBox(height: 24),
                  _buildButton('Xác nhận', _resetPassword),
                ],

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Đã nhớ mật khẩu? Đăng nhập',
                    style: const TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
