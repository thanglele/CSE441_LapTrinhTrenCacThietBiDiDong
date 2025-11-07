// ignore_for_file: unused_import

import 'package:flutter/material.dart';
// Import các màn hình nội dung
// ✅ GỌI FILE ENUM (ĐƯỢC ĐẶT TRONG THƯ MỤC CON)
import 'package:mytlu/Students/faceupload/face_enrollment_steps.dart';
// ✅ GỌI WIDGET CON (ĐƯỢC ĐẶT TRONG THƯ MỤC CON)
import 'package:mytlu/Students/faceupload/screens/face_enrollment_prompt_screen.dart';
import 'package:mytlu/Students/faceupload/screens/face_scan_screen.dart';

// 1. IMPORT CÁC THÀNH PHẦN "VỎ" (Shell)
import 'package:mytlu/Students/common_widgets/student_header.dart';
import 'package:mytlu/Students/theme/app_theme.dart';

// 2. IMPORT LOGIC ĐỂ GỌI API HEADER
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

/// File này là "vỏ" (shell) cho màn hình Yêu cầu Đăng ký Khuôn mặt.
/// Nó đảm bảo hiển thị Header và Theme nhất quán với StudentDashboard.
class AuthWrapperScreen extends StatefulWidget {

  const AuthWrapperScreen({ super.key });

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {

  // ✅ BƯỚC 1: Quản lý trạng thái của nội dung Body (Bắt đầu từ Prompt)
  FaceEnrollmentStep _currentStep = FaceEnrollmentStep.prompt;

  // --- NHIỆM VỤ: GỌI API CHO HEADER ---
  final ProfileService _profileService = ProfileService();
  late Future<StudentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API GET /auth/me 1 lần duy nhất khi mở màn hình này
    _profileFuture = _profileService.getStudentProfile();
  }

  // ✅ BƯỚC 2: Hàm chuyển đổi trạng thái Body (Được gọi từ FaceEnrollmentPromptScreen)
  void _moveToScanScreen() {
    setState(() {
      _currentStep = FaceEnrollmentStep.scan;
    });
  }

  // ✅ BƯỚC 2b: Hàm chuyển đổi trạng thái Body QUAY LẠI PROMPT
  void _moveToPromptScreen() {
    setState(() {
      _currentStep = FaceEnrollmentStep.prompt;
    });
  }


  // ✅ BƯỚC 3: Hàm chọn Widget Body dựa trên trạng thái hiện tại
  Widget _getBodyContent() {
    switch (_currentStep) {
      case FaceEnrollmentStep.prompt:
      // Truyền hàm chuyển sang màn hình Scan
        return FaceEnrollmentPromptScreen(onEnrollPressed: _moveToScanScreen);
      case FaceEnrollmentStep.scan:
      // ✅ SỬA: Dùng FaceScanScreen và truyền hàm quay lại Prompt
        return FaceScanScreen(onCompleted: _moveToPromptScreen);
      case FaceEnrollmentStep.review:
      // Thêm các bước khác nếu cần
        return const Center(child: Text("Màn hình Review sẽ ở đây..."));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: AppTheme.lightTheme, // Dùng theme từ file cũ
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Màu nền chung từ file cũ

        // 1. HEADER (KHÔNG ĐỔI)
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120), // Chiều cao của Header (const)
          child: FutureBuilder<StudentProfile>(
            future: _profileFuture, // Theo dõi hàm gọi API
            builder: (context, snapshot) {

              // Khi đang tải hoặc bị lỗi, hiển thị Header chờ
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                return const StudentHeader( // (const)
                  studentCode: "Loading...",
                  fullName: "Đang tải...",
                  avatarUrl: null,
                );
              }

              // Khi thành công, truyền dữ liệu thật vào Header
              final StudentProfile profile = snapshot.data!;
              return StudentHeader(
                studentCode: profile.studentCode,
                fullName: profile.fullName,
                avatarUrl: profile.avatarUrl,
              );
            },
          ),
        ),

        // 2. NỘI DUNG (Sử dụng hàm _getBodyContent() để hiển thị nội dung)
        body: Padding(
          // Dùng Padding để đẩy Card ra và cách lề
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView( // Cho phép cuộn nếu màn hình quá nhỏ
              child: _getBodyContent(), // ✅ Dùng hàm để lấy nội dung hiện tại
            ),
          ),
        ),

        // 3. KHÔNG CÓ FOOTER
        // bottomNavigationBar: null,
      ),
    );
  }
}