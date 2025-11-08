import 'package:flutter/material.dart';
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/theme/app_theme.dart';
// TODO: Import màn hình Splash/Login của bạn để điều hướng khi đăng xuất
// import 'package:mytlu/presentation/splash_screen.dart';
import 'package:mytlu/services/user_session.dart';

/// Thẻ (Card) hiển thị thông tin cá nhân (giống mockup)
class ProfileInfoCard extends StatefulWidget {
  final StudentProfile profile;
  const ProfileInfoCard({super.key, required this.profile});

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  // Hàm helper xây dựng 1 hàng thông tin (Label + Value)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 8),
        ],
      ),
    );
  }

  // Hàm helper xây dựng chip trạng thái (verified, uploaded, none)
  Widget _buildStatusChip(String uploadStatus) {
    IconData icon;
    String text;
    Color color;

    // SỬA LỖI: Dùng 'uploadStatus' (từ logic mới)
    switch (uploadStatus) {
      case 'verified':
        icon = Icons.check_circle;
        text = 'Đã đăng ký nhận diện';
        color = Colors.green;
        break;
      case 'uploaded':
        icon = Icons.warning_amber;
        text = 'Chờ duyệt nhận diện';
        color = Colors.orange;
        break;
      default: // 'none' hoặc lỗi
        icon = Icons.error_outline;
        text = 'Chưa đăng ký nhận diện';
        color = Colors.red;
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile; // Lấy profile từ widget

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Avatar và Tên)
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (profile.avatarUrl != null)
                        ? NetworkImage(profile.avatarUrl!)
                        : const AssetImage('assets/images/avatar_default.png')
                    as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 2. Trạng thái nhận diện
            _buildStatusChip(profile.uploadStatus), // SỬA LỖI: Dùng uploadStatus
            const SizedBox(height: 16),

            // 3. Danh sách thông tin
            _buildInfoRow("Mã sinh viên:", profile.studentCode),
            _buildInfoRow("Họ và tên:", profile.fullName),
            _buildInfoRow("Lớp:", profile.adminClass),
            // SỬA LỖI: ĐÃ XÓA "Khoa:" (vì API GET /me không cung cấp)
            _buildInfoRow("Ngành:", profile.majorName),
            _buildInfoRow("Khóa:", profile.intakeYear),
            _buildInfoRow(
                "CCCD:", profile.identification?.nationalId ?? 'N/A'),
            _buildInfoRow("Ngày sinh:", profile.formattedDateOfBirth),
            _buildInfoRow(
                "Nơi sinh:", profile.identification?.placeOfBirth ?? 'N/A'),
            _buildInfoRow("Giới tính:", profile.gender),
            _buildInfoRow(
                "Địa chỉ:", profile.details?.contactAddress ?? 'N/A'),
            _buildInfoRow("Số điện thoại:", profile.phoneNumber),
            _buildInfoRow("Email:", profile.email),
          ],
        ),
      ),
    );
  }
}

/// Nút Đăng xuất
class LogoutButton extends StatelessWidget {
  final Function(int) onSwitchTab;
  const LogoutButton({super.key, required this.onSwitchTab});

  // Hàm xử lý đăng xuất
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // 1. Xóa session đã lưu
      await UserSession().clearSession();

      // 2. Điều hướng về màn hình Splash/Login
      // (Đảm bảo màn hình Splash/Login có thể xử lý việc không có session)
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
            const Scaffold(body: Center(child: Text("Đã đăng xuất"))),
            // TODO: Thay thế Scaffold bằng màn hình Splash/Login thật
            // builder: (context) => const SplashScreen(),
          ),
              (route) => false, // Xóa tất cả các màn hình cũ
        );
      }
    } catch (e) {
      // Xử lý lỗi (hiếm khi xảy ra)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi đăng xuất: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          "Đăng xuất",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Ubuntu',
          ),
        ),
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Nút màu đỏ
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}