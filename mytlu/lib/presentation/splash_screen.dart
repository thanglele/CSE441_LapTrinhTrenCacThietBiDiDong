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
    await Future.delayed(Duration(seconds: 3), () {});

    if (mounted) {
      // Chuyển sang màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/Logo_TLU.png',
              width: 150,
            ),

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