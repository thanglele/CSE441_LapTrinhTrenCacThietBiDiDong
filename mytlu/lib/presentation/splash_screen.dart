// MÀN HÌNH CHỜ SPLASH SCREEN
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/login/login.dart';

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
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Đợi 3 giây

    // Kiểm tra session
    UserProfile? user = await _session.getUserProfile();

    if (!mounted) return;

    if (user != null) {
      // TRƯỜNG HỢP 1: ĐÃ CÓ SESSION
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            userName: user.fullName,
            userAvatarAsset: user.avatarPath,
          ),
        ),
      );

    } else {
      // TRƯỜNG HỢP 2: CHƯA CÓ SESSION
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  // _navigateToLogin() async {
  //   await Future.delayed(Duration(seconds: 3));

  //   String? savedUserName = await _getSavedUserName(); // Hàm giả định
  //   String? savedAvatar = await _getSavedAvatar(); // Hàm giả định

  //   if (mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) {
  //           // Nếu không có tên, gọi LoginScreen bình thường
  //           if (savedUserName == null) {
  //             return const LoginScreen();
  //           }
  //           // Nếu có tên, truyền tên và avatar vào
  //           else {
  //             return LoginScreen(
  //               userName: savedUserName,
  //               userAvatarAsset: savedAvatar,
  //             );
  //           }
  //         },
  //       ),
  //     );
  //   }
  // }

  // Future<String?> _getSavedUserName() async {
  //   return "Nguyễn Thị Dinh";
  //   // return null;
  // }

  // Future<String?> _getSavedAvatar() async {
  //   //return "assets/images/avatar_rabbit.png";
  //   return null;
  // }

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
                fontFamily: 'Ubuntu',
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
