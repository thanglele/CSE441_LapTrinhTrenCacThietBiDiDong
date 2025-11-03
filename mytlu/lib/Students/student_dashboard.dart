import 'package:flutter/material.dart';

// IMPORT CÁC THÀNH PHẦN (VỎ)
import 'package:mytlu/Students/common_widgets/student_header.dart';
import 'package:mytlu/Students/common_widgets/student_footer.dart';

//  IMPORT LOGIC ĐỂ GỌI API HEADER
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

//  IMPORT 4 MÀN HÌNH CON (TƯƠNG ỨNG 4 TAB)
import 'package:mytlu/Students/profile/screens/profile_menu_screen.dart';



class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0; // Tab hiện tại (0 = Lịch học)

  // Service và Future để gọi API cho Header
  final ProfileService _profileService = ProfileService();
  late Future<StudentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API GET /auth/me
    _profileFuture = _profileService.getStudentProfile();
  }

  void _onSwitchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. HEADER (Luôn cố định ở trên)

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: FutureBuilder<StudentProfile>(
          future: _profileFuture, // Theo dõi hàm gọi API
          builder: (context, snapshot) {
            // Khi đang tải hoặc bị lỗi, hiển thị Header chờ
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return StudentHeader(
                studentCode: "Loading...",
                fullName: "Đang tải...",
                avatarUrl: null, // Không có avatar
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

      // 2. NỘI DUNG (SỬA LẠI BODY)
      body: FutureBuilder<StudentProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {

          // Khi đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Khi bị lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
          }

          // Khi thành công (snapshot CÓ DỮ LIỆU)
          if (snapshot.hasData) {
            final profile = snapshot.data!;

            // TẠO DANH SÁCH TAB Ở ĐÂY (SAU KHI CÓ DỮ LIỆU)
            final List<Widget> tabs = [
              ScheduleScreen(),     // Index 0
              QrScannerScreen(),    // Index 1
              HistoryScreen(),      // Index 2
              ProfileMenuScreen(    // Index 3:
                profile: profile,
                onSwitchTab: _onSwitchTab,
              ),
            ];

            // Hiển thị tab hiện tại
            return IndexedStack(
              index: _currentIndex,
              children: tabs,
            );
          }

          // Trường hợp khác
          return Center(child: Text("Không tìm thấy dữ liệu."));
        },
      ),

      // 3. FOOTER (Luôn cố định ở dưới)
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onSwitchTab, // Dùng hàm callback
      ),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Nội dung Tab LỊCH HỌC"));
  }
}

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Nội dung Tab QUÉT QR"));
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Nội dung Tab LỊCH SỬ"));
  }
}