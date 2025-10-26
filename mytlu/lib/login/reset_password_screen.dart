// lib/presentation/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mytlu/config/api_config.dart';
import 'package:mytlu/login/login.dart';

class ResetPasswordScreen extends StatefulWidget {
  final bool permissionsGranted;
  final String username;
  final String resetToken; // Nhận từ màn hình OTP

  const ResetPasswordScreen({
    Key? key,
    required this.permissionsGranted,
    required this.username,
    required this.resetToken,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Controller cho 2 ô
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  // Trạng thái ẩn/hiện cho 2 ô
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Montserrat')),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Hàm xử lý logic khi nhấn nút
  Future<void> _handleResetPassword() async {
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ mật khẩu.");
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar("Mật khẩu xác nhận không khớp.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String url = '${ApiConfig.baseUrl}/api/v1/auth/reset-password';
    final Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };
    final Map<String, String> body = {
      'username': widget.username,
      'resetToken': widget.resetToken,
      'newPassword': password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // THÀNH CÔNG (200)
        _showSnackBar(
          "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.",
          isError: false,
        );

        if (!mounted) return;
        // Quay về màn hình Login và xóa hết các màn hình cũ
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(permissionsGranted: widget.permissionsGranted),
          ),
          (route) => false,
        );
      } else if (response.statusCode == 400) {
        // LỖI (400)
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        _showSnackBar(responseBody['message']);
      } else {
        _showSnackBar('Lỗi không xác định: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối mạng: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dùng lại nền gradient
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(94, 196, 230, 1), // Giống màn hình OTP
              Color.fromRGBO(64, 124, 220, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  'Tạo mật khẩu mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              // Form
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      width: 379.0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Center(
                        child: Text(
                          "Khôi phục mật khẩu",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      'Vui lòng nhập mật khẩu mới của bạn.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),

                    // Ô nhập Mật khẩu mới
                    _buildPasswordField(
                      hintText: 'Mật khẩu mới',
                      controller: _passwordController,
                      isVisible: _isPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Ô nhập Xác nhận mật khẩu
                    _buildPasswordField(
                      hintText: 'Xác nhận mật khẩu mới',
                      controller: _confirmPasswordController,
                      isVisible: _isConfirmVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isConfirmVisible = !_isConfirmVisible;
                        });
                      },
                    ),
                    SizedBox(height: 30),

                    // Nút Xác nhận
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0A2A9B),
                        fixedSize: Size(309, 63), // Giống màn hình Login
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Xác nhận',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tái sử dụng cho ô nhập mật khẩu (giống LoginScreen)
  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      width: 379.0,
      height: 82.0,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(color: Colors.black, fontSize: 18),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: (82.0 - 24.0) / 2, // Căn giữa
          ),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}
