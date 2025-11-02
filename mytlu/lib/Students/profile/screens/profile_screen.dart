import 'package:flutter/material.dart';

// 1. IMPORT MODEL VÀ SERVICE BẠN ĐÃ TẠO
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/services/profile_service.dart';

// 2. IMPORT FILE THEME TỪ ĐƯỜNG DẪN CHÍNH XÁC
import 'package:mytlu/Students/theme/app_theme.dart';

/// Đây là màn hình "Hồ sơ" THẬT, hiển thị giao diện giống Figma
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
      // AppBar sẽ tự động lấy màu và font từ AppTheme
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Nút quay lại
        ),
        title: Text('Thông tin cá nhân'),
      ),

      // 5. Dùng FutureBuilder để tự động xử lý 3 trạng thái
      body: FutureBuilder<StudentProfile>(
        future: _profileFuture, // Theo dõi hàm gọi API
        builder: (context, snapshot) {

          // Trạng thái 1: ĐANG TẢI (chờ API)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Trạng thái 2: BỊ LỖI (mất mạng, server 500...)
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          // Trạng thái 3: THÀNH CÔNG (có dữ liệu)
          if (snapshot.hasData) {
            final profile = snapshot.data!; // Lấy dữ liệu profile

            // Vẽ lại giao diện từ Figma dùng dữ liệu thật
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? profile.avatarUrl!
                        : 'https://i.pravatar.cc/150'), // Ảnh dự phòng
                  ),
                ),
                SizedBox(height: 16),
                _buildEnrollmentStatus(profile.faceDataStatus),
                SizedBox(height: 24),

                // Hiển thị dữ liệu thật từ API
                // (LƯU Ý: API /auth/me chỉ trả về 5 trường)
                _buildReadOnlyField(label: "Mã sinh viên", value: profile.studentCode),
                _buildReadOnlyField(label: "Họ và tên", value: profile.fullName),
                _buildReadOnlyField(label: "Lớp", value: profile.adminClass),
                _buildReadOnlyField(label: "Ngành", value: profile.majorName),

                // (Bỏ comment các dòng này nếu bạn muốn thấy 'N/A'
                // cho đến khi Backend cập nhật API)
                // _buildReadOnlyField(label: "Khoa", value: 'N/A'),
                // _buildReadOnlyField(label: "Khóa", value: 'N/A'),
                // _buildReadOnlyField(label: "CCCD", value: 'N/A'),

                SizedBox(height: 20),
              ],
            );
          }

          return Center(child: Text('Không tìm thấy thông tin.'));
        },
      ),
    );
  }

  // Widget con cho Trạng thái Đăng ký (y hệt Figma)
  Widget _buildEnrollmentStatus(String status) {
    bool isVerified = status == 'verified';
    Color color = isVerified ? Colors.green : Colors.orange;
    IconData icon = isVerified ? Icons.check_circle : Icons.warning_amber;
    String text = isVerified ? 'Đã đăng ký nhận diện' : 'Chưa đăng ký';

    if (status == 'pending') {
      text = 'Đang chờ duyệt';
      color = Colors.blue;
      icon = Icons.hourglass_top;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Đăng ký nhận diện',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(icon, color: color, size: 18),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con để tạo ô "Chỉ Đọc" (giống Figma)
  Widget _buildReadOnlyField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            readOnly: true, // Chỉ để đọc
            decoration: InputDecoration(
              filled: true,
              // === ĐÃ SỬA LỖI UNUSED IMPORT ===
              // Giờ đây file này đã SỬ DỤNG AppTheme
              fillColor: AppTheme.lightGray,
              // ===================================
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none, // Không có viền
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}