// MÀN HÌNH CHỜ SPLASH SCREEN
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mytlu/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3));

    // TODO: Kiểm tra SharedPreferences hoặc Secure Storage
    String? savedUserName = await _getSavedUserName(); // Hàm giả định
    String? savedAvatar = await _getSavedAvatar(); // Hàm giả định

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            // Nếu không có tên, gọi LoginScreen bình thường
            if (savedUserName == null) {
              return const LoginScreen();
            }
            // Nếu có tên, truyền tên và avatar vào
            else {
              return LoginScreen(
                userName: savedUserName,
                userAvatarAsset: savedAvatar,
              );
            }
          },
        ),
      );
    }
  }

  Future<String?> _getSavedUserName() async {
    return "Nguyễn Thị Dinh";
  }

  Future<String?> _getSavedAvatar() async {
    //return "assets/images/avatar_rabbit.png";
    return null;
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
