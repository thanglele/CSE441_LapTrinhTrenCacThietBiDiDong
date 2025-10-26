import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mytlu/config/api_config.dart';
import 'package:mytlu/login/OTPCode.dart';
import 'package:mytlu/giaodienlichhoc/screens/scan_qr_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final bool permissionsGranted; // Nhận quyền từ LoginScreen

  const ForgetPasswordScreen({Key? key, required this.permissionsGranted})
    : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late TextEditingController _studentCodeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _studentCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _studentCodeController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleRequestReset() async {
    final String studentCode = _studentCodeController.text;
    if (studentCode.isEmpty) {
      _showErrorSnackBar("Vui lòng nhập Mã sinh viên.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String url = '${ApiConfig.baseUrl}/api/v1/auth/request-reset';
    final Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };
    final Map<String, String> body = {'username': studentCode};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // THÀNH CÔNG (200)
        if (!mounted) return;

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển sang màn hình Nhập OTP (theo yêu cầu)
        // Dùng pushReplacement để tránh bị luẩn quẩn (như đã bàn)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPCodeScreen(
              permissionsGranted: widget.permissionsGranted, // Truyền quyền
              username: studentCode, // Truyền MSV sang
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        // LỖI (400)
        _showErrorSnackBar(responseBody['message']);
      } else {
        _showErrorSnackBar(
          'Lỗi ${response.statusCode}: ${responseBody['message'] ?? 'Lỗi không xác định'}',
        );
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
                        "Nhập mã sinh viên để lấy mã OTP của bạn",
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
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TextField(
                      controller: _studentCodeController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mã sinh viên',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 18.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Gửi mã OTP
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRequestReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A2A9B),
                          fixedSize: Size(180, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Gửi mã OTP',
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
            MaterialPageRoute(builder: (context) => ScanQRScreen()),
          );
          // TODO: Xử lý logic Quét QR
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
