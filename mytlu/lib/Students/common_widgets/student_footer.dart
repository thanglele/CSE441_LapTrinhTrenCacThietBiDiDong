import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  // Sử dụng cú pháp super.key để code gọn gàng
  const AppFooter({super.key, required this.currentIndex, required this.onTap});

  // Hàm private để tạo 1 item, giúp code gọn hơn
  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon), // Màu sắc sẽ được tự động quản lý bởi BottomNavigationBar
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Luôn hiển thị label
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF407CDC),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, // Luôn hiển thị label của tab không được chọn


      selectedLabelStyle: TextStyle(fontFamily: 'Ubuntu', fontSize: 12),
      unselectedLabelStyle: TextStyle(fontFamily: 'Ubuntu', fontSize: 12),

      items: [
        _buildNavItem(Icons.calendar_today, 'Lịch học'),
        _buildNavItem(Icons.qr_code, 'Quét QR'),
        _buildNavItem(Icons.history, 'Lịch sử'),
        _buildNavItem(Icons.person, 'Hồ sơ'),
      ],
    );
  }
}