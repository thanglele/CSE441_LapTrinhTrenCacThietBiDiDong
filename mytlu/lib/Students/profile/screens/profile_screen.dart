import 'package:flutter/material.dart';

// 1. IMPORT MODEL VÀ SERVICE
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

// 2. IMPORT WIDGET GIAO DIỆN ĐÃ SỬA LỖI
import 'package:mytlu/Students/profile/widgets/profile_widgets.dart';

/// Đây là màn hình "Thông tin cá nhân"
/// (Phiên bản này là một màn hình riêng lẻ, có AppBar,
/// không phải là màn hình Tab 3)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 3. Khởi tạo Service và một biến 'Future'
  final ProfileService _profileService = ProfileService();
  late Future<StudentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // 4. Bắt đầu gọi API ngay khi màn hình này được mở
    _profileFuture = _profileService.getStudentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Nút quay lại
        ),
        title: const Text('Thông tin cá nhân'),
      ),

      // 5. Dùng FutureBuilder để tự động xử lý 3 trạng thái
      body: FutureBuilder<StudentProfile>(
        future: _profileFuture, // Theo dõi hàm gọi API
        builder: (context, snapshot) {
          // Trạng thái 1: ĐANG TẢI (chờ API)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái 2: BỊ LỖI (mất mạng, server 500...)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi tải dữ liệu: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Trạng thái 3: THÀNH CÔNG (có dữ liệu)
          if (snapshot.hasData) {
            final profile = snapshot.data!; // Lấy dữ liệu profile

            // 6. TÁI SỬ DỤNG WIDGET ĐÃ SỬA
            // Chỉ cần gọi ProfileInfoCard, nó đã chứa toàn bộ UI
            // (Avatar, Chip trạng thái, và tất cả các trường thông tin)
            return ListView(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: [
                ProfileInfoCard(profile: profile),
                // Xóa các hàm _buildReadOnlyField và _buildEnrollmentStatus
                // vì chúng đã nằm trong ProfileInfoCard.
              ],
            );
          }

          return const Center(child: Text('Không tìm thấy thông tin.'));
        },
      ),
    );
  }

// KHÔNG CẦN CÁC HÀM _buildEnrollmentStatus VÀ _buildReadOnlyField
// VÌ ĐÃ CHUYỂN VÀO file profile_widgets.dart (ProfileInfoCard)
}