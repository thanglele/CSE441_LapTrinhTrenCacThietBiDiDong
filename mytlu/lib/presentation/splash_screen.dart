// MÀN HÌNH CHỜ SPLASH SCREEN
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/login/login.dart';

import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserSession _session = UserSession();

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate(); // Đổi tên hàm
  }

  // HÀM MỚI: Yêu cầu quyền
  Future<bool> _requestPermissions() async {
    // Yêu cầu cả 2 quyền cùng lúc
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
    ].request();

    // Kiểm tra xem CẢ HAI quyền đã được cấp chưa
    bool locationGranted = statuses[Permission.location] == PermissionStatus.granted;
    bool cameraGranted = statuses[Permission.camera] == PermissionStatus.granted;
    
    return locationGranted && cameraGranted;
  }

  // HÀM CHÍNH: Sửa lại
  _initializeAndNavigate() async {
    // Chạy song song 3 tác vụ: Yêu cầu quyền, Đợi 3s, Kiểm tra session
    final results = await Future.wait([
      _requestPermissions(),
      Future.delayed(Duration(seconds: 3)), // Giữ 3 giây delay
      _session.getUserProfile(),
    ]);

    // Lấy kết quả
    final bool permissionsGranted = results[0] as bool;
    final UserProfile? user = results[2] as UserProfile?;

    if (!mounted) return;

    // 2. ĐIỀU HƯỚNG SANG LOGIN (Luôn luôn)
    // Truyền trạng thái quyền và thông tin user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          permissionsGranted: permissionsGranted,
          userName: user?.fullName,
          userAvatarAsset: user?.avatarPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/Logo_TLU.png', width: 150),

            Text(
              'My TLU',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(25, 49, 175, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
