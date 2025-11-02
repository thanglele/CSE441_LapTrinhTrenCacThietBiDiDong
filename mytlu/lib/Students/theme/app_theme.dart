import 'package:flutter/material.dart';

class AppTheme {
  // 1. ĐỊNH NGHĨA MÀU CHỦ ĐẠO
  static const Color primaryColor = Color(0xFF407CDC); // <-- Màu #407CDC
  static const Color lightGray = Color(0xFFF0F0F0); // <-- Màu xám nhạt

  // 2. ĐỊNH NGHĨA THEME SÁNG
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Ubuntu', // <-- ÁP DỤNG FONT UBUNTU MẶC ĐỊNH

      // 3. TÙY CHỈNH APPBAR (Thanh tiêu đề)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor, // Màu nền AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Màu icon (nút back)
        titleTextStyle: TextStyle(
          fontFamily: 'Ubuntu',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
      ),
    );
  }
}