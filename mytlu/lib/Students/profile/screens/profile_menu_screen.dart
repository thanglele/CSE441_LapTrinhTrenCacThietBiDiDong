import 'package:flutter/material.dart';
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/theme/app_theme.dart';

import 'package:mytlu/Students/profile/screens/profile_screen.dart';

import 'package:mytlu/services/user_session.dart';

import 'package:mytlu/presentation/splash_screen.dart';

/// Đây là màn hình "Menu Hồ sơ" (nội dung của Tab 3)
class ProfileMenuScreen extends StatelessWidget {

  final StudentProfile profile;
  final Function(int) onSwitchTab; // Hàm để quay về 'Lịch học'

  const ProfileMenuScreen({
    super.key,
    required this.profile,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 12),

            // 1. Thanh TitleBar "<-- Hồ sơ"
            _buildTitleBar(context),

            const SizedBox(height: 16),

            // 2. Thẻ thông tin (UserCard)
            _buildProfileCard(profile),

            const SizedBox(height: 24),

            // 3. Menu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildMenuRow(
                    context: context,
                    text: 'Thông tin cá nhân',
                    icon: Icons.person_outline,
                    onTap: () {
                      // Điều hướng đến màn hình profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    context: context,
                    text: 'Thay đổi mật khẩu',
                    icon: Icons.lock_outline,
                    onTap: () {
                      // TODO: Điều hướng đến ChangePasswordScreen
                    },
                  ),
                  _buildDivider(),

                  //  Nút gạt
                  SwitchListTile(
                    title: const Text(
                      'Bật thông báo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    value: true, // (Bạn sẽ cần biến state ở đây sau)
                    onChanged: (bool value) {
                      // TODO: Xử lý bật/tắt thông báo
                    },
                    secondary: Icon(Icons.notifications_none, color: Colors.grey[700]),
                    activeThumbColor: AppTheme.primaryColor,
                    activeTrackColor: AppTheme.primaryColor.withAlpha(128),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),

                  _buildDivider(),
                  _buildMenuRow(
                    context: context,
                    text: 'Cài đặt',
                    icon: Icons.settings_outlined,
                    onTap: () {
                      // TODO: Điều hướng đến SettingsScreen
                    },
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    context: context,
                    text: 'Đăng xuất',
                    icon: Icons.logout,
                    color: Colors.red,
                    onTap: () {
                      //  2. GỌI HÀM XỬ LÝ ĐĂNG XUẤT
                      _handleLogout(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // HÀM XỬ LÝ ĐĂNG XUẤT

  /// Hiển thị dialog xác nhận và xử lý đăng xuất
  Future<void> _handleLogout(BuildContext context) async {
    // lấy Navigator TRƯỚC khi await, để tránh lỗi "async gap"
    // kiểm tra xem widget có còn trên cây không
    if (!context.mounted) return;
    final navigator = Navigator.of(context);

    // Hiển thị Dialog xác nhận
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Xác nhận Đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.pop(dialogContext, false); // Trả về false
              },
            ),
            TextButton(
              child: Text('Đăng xuất', style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.pop(dialogContext, true); // Trả về true
              },
            ),
          ],
        );
      },
    );

    // 3. Nếu người dùng không xác nhận (nhấn Hủy hoặc bấm ra ngoài), thì dừng lại
    if (confirmed == null || confirmed == false) {
      return;
    }

    // 4. (Nếu xác nhận) Xóa Session (Token)
    await UserSession().clearSession();

    // 5. Quay về SplashScreen.
    // SplashScreen sẽ tự động kiểm tra (không còn token) và đẩy về LoginScreen.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false, // Xóa tất cả các màn hình cũ
    );
  }
  /// Widget con cho Thanh Title "<-- Hồ sơ"
  Widget _buildTitleBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(100),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Quay về Tab 0 (Lịch học)
              onSwitchTab(0);
            },
          ),
          const Text(
            'Hồ sơ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget con cho Thẻ User (Card)
  Widget _buildProfileCard(StudentProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 5% opacity
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            // Dùng avatarUrl từ profile (nếu có)
            backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                ? Icon(Icons.person_outline, size: 30, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName, // <-- Dữ liệu động
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Mã sinh viên: ${profile.studentCode}", // <-- Dữ liệu động
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 2),
              Text(
                profile.adminClass, // <-- Dữ liệu động
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget con cho các hàng trong Menu
  Widget _buildMenuRow({
    required BuildContext context,
    required String text,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[700], size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            if (onTap != null && text != 'Đăng xuất') // Chỉ hiển thị > cho các mục điều hướng
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  /// Widget con cho đường kẻ ngang
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }
}
