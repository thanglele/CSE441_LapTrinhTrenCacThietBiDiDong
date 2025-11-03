import 'package:flutter/material.dart';

//  IMPORT CÁC THÀNH PHẦN (VỎ)
import 'package:mytlu/Students/common_widgets/student_header.dart';
import 'package:mytlu/Students/common_widgets/student_footer.dart';

//  IMPORT LOGIC ĐỂ GỌI API HEADER
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

import 'package:mytlu/Students/profile/screens/profile_screen.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // QUẢN LÝ TAB ---
  int _currentIndex = 0; // Tab hiện tại (0 = Lịch học)

  // Danh sách các màn hình (nội dung)
  final List<Widget> _tabs = [
    ScheduleScreen(),     // Index 0: Lịch học
    QrScannerScreen(),    // Index 1: Quét QR
    HistoryScreen(),      // Index 2: Lịch sử
    ProfileScreen(),      // Index 3: HỒ SƠ (File bạn đã code)
  ];

  //  GỌI API CHO HEADER ---
  final ProfileService _profileService = ProfileService();
  late Future<StudentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API GET /auth/me 1 lần duy nhất khi mở màn hình này
    _profileFuture = _profileService.getStudentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  XÂY DỰNG BỐ CỤC ---

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

      // 2. NỘI DUNG (Thay đổi theo tab)
      // Dùng IndexedStack để giữ trạng thái (state) của các tab
      // (ví dụ: giữ vị trí cuộn của tab Lịch sử)
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // 3. FOOTER (Luôn cố định ở dưới)
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Khi nhấn tab, cập nhật lại state
          setState(() {
            _currentIndex = index;
          });
        },
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
