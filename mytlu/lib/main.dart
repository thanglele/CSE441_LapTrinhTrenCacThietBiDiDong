// lib/main.dart
import 'package:flutter/material.dart';
// Import file splash screen của bạn
import 'presentation/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My TLU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // Màn hình bắt đầu của ứng dụng
      home: const SplashScreen(),
    );
  }
}