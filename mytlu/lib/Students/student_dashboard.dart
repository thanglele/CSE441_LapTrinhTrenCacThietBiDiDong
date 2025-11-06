import 'package:flutter/material.dart';

// 1. IMPORT CÁC THÀNH PHẦN "VỎ" (Shell)
import 'package:mytlu/Students/common_widgets/student_header.dart';
import 'package:mytlu/Students/common_widgets/student_footer.dart';

// 2. IMPORT THEME (Để bọc)
import 'package:mytlu/Students/theme/app_theme.dart';

// 3. IMPORT LOGIC ĐỂ GỌI API HEADER
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

// 4. IMPORT 4 MÀN HÌNH CON (TỪ 4 FILE RIÊNG BIỆT)
import 'package:mytlu/Students/schedule/screens/schedule_screen.dart';
import 'package:mytlu/Students/attendance/screens/qr_scanner_screen.dart';
import 'package:mytlu/Students/history/screens/history_screen.dart';
import 'package:mytlu/Students/profile/screens/profile_menu_screen.dart';


/// Đây là màn hình "vỏ" (shell) chính của Sinh viên.
/// Nó quản lý Header, Footer và việc chuyển đổi giữa 4 tab.
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // --- NHIỆM VỤ 1: QUẢN LÝ TAB ---
  int _currentIndex = 0; // Tab hiện tại (0 = Lịch học)

  // --- NHIỆM VỤ 2: GỌI API CHO HEADER & CÁC TAB CON ---
  final ProfileService _profileService = ProfileService();
  late Future<StudentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API GET /auth/me 1 lần duy nhất khi mở màn hình này
    _profileFuture = _profileService.getStudentProfile();
  }

  // Hàm callback để chuyển tab (dùng cho nút back trong ProfileMenu)
  void _onSwitchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // === BỌC WIDGET BẰNG THEME CỦA STUDENT ===
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Màu nền chung

        // 1. HEADER (Luôn cố định ở trên)
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120), // Chiều cao của Header
          child: FutureBuilder<StudentProfile>(
            future: _profileFuture, // Theo dõi hàm gọi API
            builder: (context, snapshot) {

              // Khi đang tải hoặc bị lỗi, hiển thị Header chờ
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                return StudentHeader(
                  studentCode: "Loading...",
                  fullName: "Đang tải...",
                  avatarUrl: null,
                );
              }

              // Khi thành công, truyền dữ liệu thật vào Header
              final profile = snapshot.data!;
              return StudentHeader(
                studentCode: profile.studentCode,
                fullName: profile.fullName,
                avatarUrl: profile.avatarUrl,
              );
            },
          ),
        ),

        // 2. NỘI DUNG (Thay đổi theo tab)
        // Body cũng phải "chờ" API /auth/me xong
        // vì các tab con (như ProfileMenu) cần dữ liệu 'profile'
        body: FutureBuilder<StudentProfile>(
            future: _profileFuture,
            builder: (context, snapshot) {

              // Nếu đang chờ API (lần đầu), chỉ hiển thị loading
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // Nếu lỗi
              if (snapshot.hasError) {
                return Center(child: Text("Lỗi tải dữ liệu Profile: ${snapshot.error}"));
              }

              // Khi có dữ liệu, tạo danh sách tab
              final profile = snapshot.data!;

              final List<Widget> tabs = [
                ScheduleScreen(),     // Index 0 (Lịch học)
                QrScannerScreen(),    // Index 1 (Quét QR)
                HistoryScreen(),      // Index 2 (Lịch sử)
                ProfileMenuScreen(    // Index 3 (Hồ sơ - Truyền dữ liệu & callback)
                  profile: profile,
                  onSwitchTab: _onSwitchTab,
                ),
              ];

              // Dùng IndexedStack để giữ trạng thái (state) của các tab
              return IndexedStack(
                index: _currentIndex,
                children: tabs,
              );
            }
        ),

        // 3. FOOTER (Luôn cố định ở dưới)
        bottomNavigationBar: AppFooter(
          currentIndex: _currentIndex,
          onTap: _onSwitchTab, // Dùng hàm callback
        ),
      ),
    );
  }
}