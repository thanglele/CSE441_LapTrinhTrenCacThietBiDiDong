import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mytlu/config/api_config.dart';
import 'package:mytlu/login/ForgetPassword.dart';
import 'package:mytlu/login/reset_password_screen.dart';
import 'package:mytlu/giaodienlichhoc/screens/scan_qr_screen.dart';

class OTPCodeScreen extends StatefulWidget {
  final bool permissionsGranted;
  final String username; // Nhận username (MSV) từ màn hình trước

  const OTPCodeScreen({Key? key, required this.permissionsGranted, required this.username}) : super(key: key);

  @override
  _OTPCodeScreenState createState() => _OTPCodeScreenState();
}

class _OTPCodeScreenState extends State<OTPCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  // 3. HÀM HIỂN THỊ LỖI
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 4. HÀM XỬ LÝ API
  Future<void> _handleVerifyOtp(String otp) async {
    if (otp.length < 6) {
      _showErrorSnackBar('Vui lòng nhập đủ 6 số OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Dùng Base URL toàn cục, không dùng localhost
    final String url = '${ApiConfig.baseUrl}/api/v1/auth/verify-otp';
    final Map<String, String> headers = {
      'accept': 'text/plain',
      'Content-Type': 'application/json',
    };
    final Map<String, String> body = {
      'username': widget.username,
      'otp': otp,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // THÀNH CÔNG (200)
        final String resetToken = responseBody['resetToken'];
        
        if (!mounted) return;
        // Chuyển sang màn hình Đặt lại mật khẩu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              permissionsGranted: widget.permissionsGranted,
              username: widget.username,
              resetToken: resetToken, // Truyền token mới
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        // LỖI (400)
        _showErrorSnackBar(responseBody['message']);
      } else {
        _showErrorSnackBar('Lỗi ${response.statusCode}: ${responseBody['message'] ?? 'Lỗi không xác định'}');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi kết nối mạng: $e');
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
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 60,
      textStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 20,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(94, 196, 230, 1),
              Color.fromRGBO(64, 124, 220, 1),
            ],
          ),
        ),

        child: Stack(
          children: [
            Positioned(
              top: 50.0,
              left: 10.0,
              child: Container(
                width: 206.0,
                height: 46.0,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16.0),

                child: Text(
                  'My TLU',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(0, 19, 122, 1),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment(0.0, 0.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 379.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Center(
                      child: Text(
                        "Quên mật khẩu?",
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
                  Container(
                    width: 379.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Center(
                      child: Text(
                        "Nhập mã OTP xác nhận được gửi qua Email",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    width: 379.0,
                    child: Pinput(
                      length: 6,
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: defaultPinTheme,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      keyboardType: TextInputType.number,
                      
                      // Tự động gọi API khi nhập xong
                      onCompleted: (pin) {
                        _handleVerifyOtp(pin);
                      },
                    ),
                  ),

                  SizedBox(height: 5),
                  Container(
                    width: 379.0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        // Vô hiệu hóa nút khi đang loading
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgetPasswordScreen(permissionsGranted: widget.permissionsGranted),
                                  ),
                                );
                              },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Nhập lại Mã Sinh Viên',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _pinFocusNode.unfocus(); // Tắt bàn phím
                                _handleVerifyOtp(_pinController.text);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A2A9B),
                          fixedSize: Size(180, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        // Hiển thị loading
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Xác thực OTP',
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanQRScreen(),
            ),
          );
        },
        backgroundColor: Color(0xFF0A2A9B),
        elevation: 4.0,
        child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 40.0),
        shape: CircleBorder(),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF0A2A9B),

        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        height: 86.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Item Hỗ trợ
            _buildNavItem(
              icon: Icons.headset_mic_outlined,
              label: 'Hỗ trợ',
              onTap: () {
                // TODO: Xử lý Hỗ trợ
              },
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20.0), // Đẩy text xuống
              child: Text(
                'Quét mã QR',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),

            // Item Thông báo
            _buildNavItem(
              icon: Icons.notifications_outlined,
              label: 'Thông báo',
              onTap: () {
                // TODO: Xử lý Thông báo
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(icon, color: Colors.white, size: 28.0),
            ),
            SizedBox(height: 4.0),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
