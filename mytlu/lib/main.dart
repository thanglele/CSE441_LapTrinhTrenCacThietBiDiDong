import 'package:flutter/material.dart';
// Đảm bảo đường dẫn này trỏ đến file home_page.dart của bạn
import 'screens/home_page_lecture.dart';

// Màu sắc chính (Cần thiết cho MaterialApp theme)
const Color tluPrimaryColor = Color(0xFF0D47A1);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Attendance System',
      debugShowCheckedModeBanner: false, // Tắt banner debug
      theme: ThemeData(
        // Định nghĩa màu sắc cơ bản cho ứng dụng
        primaryColor: tluPrimaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: tluPrimaryColor,
        ),
        // Sử dụng Primary Color cho các widget khác
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: tluPrimaryColor,
        ),
        // Cấu hình để loại bỏ hiệu ứng nhấn mặc định (nếu cần)
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),

      // GỌI THẲNG ĐẾN HOME PAGE LÀ MÀN HÌNH KHỞI CHẠY
      home: const HomePage(),
    );
  }
}