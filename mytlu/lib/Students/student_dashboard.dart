import 'package:flutter/material.dart';
import 'package:mytlu/Students/attendance/screens/qr_scanner_screen.dart';

// 1. IMPORT CÁC WIDGET CHUNG (HEADER / FOOTER)
import 'package:mytlu/Students/common_widgets/student_header.dart';
import 'package:mytlu/Students/common_widgets/student_footer.dart';

// 2. IMPORT THEME
import 'package:mytlu/Students/theme/app_theme.dart';

// 3. IMPORT LOGIC LẤY PROFILE
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

// 4. IMPORT 4 TAB CON
import 'package:mytlu/Students/schedule/screens/schedule_screen.dart';
import 'package:mytlu/Students/attendance/screens/qr_scanner_screen.dart';
import 'package:mytlu/Students/history/screens/history_screen.dart';
import 'package:mytlu/Students/profile/screens/profile_menu_screen.dart';

/// Màn hình "vỏ" của sinh viên, quản lý Header, Footer và tab
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // Tab hiện tại: 0 = Lịch học
  int _currentIndex = 0;

  // Dịch vụ lấy profile
  final ProfileService _profileService = ProfileService();
  late Future<StudentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API lấy profile 1 lần khi mở dashboard
    _profileFuture = _profileService.getStudentProfile();
  }

  /// Hàm callback để chuyển tab từ ProfileMenu hoặc Footer
  void _onSwitchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

        // HEADER (luôn cố định)
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: FutureBuilder<StudentProfile>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                return const StudentHeader(
                  studentCode: "Loading...",
                  fullName: "Đang tải...",
                  avatarUrl: null,
                );
              }

              if (snapshot.hasError) {
                return const StudentHeader(
                  studentCode: "Error",
                  fullName: "Lỗi tải profile",
                  avatarUrl: null,
                );
              }

              final profile = snapshot.data!;
              return StudentHeader(
                studentCode: profile.studentCode,
                fullName: profile.fullName,
                avatarUrl: null,
              );
            },
          ),
        ),

        // BODY: IndexedStack giữ trạng thái tab
        body: FutureBuilder<StudentProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Lỗi tải dữ liệu profile: ${snapshot.error}"),
              );
            }

            final profile = snapshot.data!;

            final List<Widget> tabs = [
              const ScheduleScreen(),              // Tab 0: Lịch học
              ScanQRScreen(onSwitchTab: _onSwitchTab),  // Tab 1: Quét mã
              const HistoryScreen(),               // Tab 2: Lịch sử
              ProfileMenuScreen(                   // Tab 3: Hồ sơ
                profile: profile,
                onSwitchTab: _onSwitchTab,
              ),
            ];

            return IndexedStack(
              index: _currentIndex,
              children: tabs,
            );
          },
        ),

        // FOOTER
        bottomNavigationBar: AppFooter(
          currentIndex: _currentIndex,
          onTap: _onSwitchTab,
        ),
      ),
    );
  }
}
