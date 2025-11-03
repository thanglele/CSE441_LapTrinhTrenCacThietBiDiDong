import 'package:flutter/material.dart';
import 'package:mytlu/Students/profile/models/student_profile.dart';
import 'package:mytlu/Students/profile/screens/profile_screen.dart'; // Màn hình "Thông tin cá nhân"
// (Bạn cũng cần import màn hình "Thay đổi mật khẩu" ở đây)
// import 'package:mytlu/Students/profile/screens/change_password_screen.dart';

/// Màn hình "Menu Hồ sơ" (Tab 3)
/// Nó nhận dữ liệu profile và 1 hàm callback để quay về tab "Lịch học"
class ProfileMenuScreen extends StatefulWidget {
  final StudentProfile profile;
  final ValueChanged<int> onSwitchTab; // Hàm callback để đổi tab

  const ProfileMenuScreen({
    super.key,
    required this.profile,
    required this.onSwitchTab,
  });

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  bool _notificationsEnabled = true; // State cho nút gạt

  @override
  Widget build(BuildContext context) {
    // Lấy màu từ Theme (Giả sử theme của bạn có màu này)
    final Color primaryColor = Theme.of(context).primaryColor; // #407CDC

    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // Màu nền xám nhạt
      body: Column(
        children: [
          // 1. THANH TITLE "HỒ SƠ" (Theo yêu cầu của bạn)
          Container(
            color: primaryColor,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Yêu cầu: "khi bấm mũi tên quay về thì quay về lịch học"
                        // Gọi hàm callback, truyền vào index 0 (Lịch học)
                        widget.onSwitchTab(0);
                      },
                    ),
                    Text(
                      'Hồ sơ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. NỘI DUNG CHÍNH (Cuộn được)
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                // Thẻ thông tin sinh viên
                _buildProfileCard(widget.profile),

                SizedBox(height: 24),

                // Danh sách cài đặt
                Text(
                  'Thiết lập tài khoản',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMenuRow(
                        context: context,
                        text: 'Thông tin cá nhân',
                        icon: Icons.person_outline,
                        onTap: () {
                          // ĐÃ THÊM: Điều hướng đến màn hình chi tiết
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
                          // (Điều hướng đến màn hình Thay đổi mật khẩu)
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (context) => ChangePasswordScreen(),
                          // ));
                        },
                      ),
                      _buildDivider(),

                      // Hàng đặc biệt cho Nút gạt
                      SwitchListTile(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        title: Text(
                          'Bật thông báo',
                          style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu'),
                        ),
                        secondary: Icon(Icons.notifications_none, color: Colors.grey[700]),
                        // 'activeColor' is deprecated. Use 'activeThumbColor' and 'activeTrackColor'.
                        activeThumbColor: primaryColor,
                        activeTrackColor: primaryColor.withAlpha(128), // 50% opacity
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),

                      _buildDivider(),
                      _buildMenuRow(
                        context: context,
                        text: 'Cài đặt',
                        icon: Icons.settings_outlined,
                        onTap: () {},
                      ),
                      _buildDivider(),

                      // Hàng đặc biệt cho Đăng xuất
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Ubuntu',
                            color: Colors.red, // Màu đỏ
                          ),
                        ),
                        onTap: () {
                          // (Gọi hàm đăng xuất từ UserSession)
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget con: Thẻ thông tin SV
  Widget _buildProfileCard(StudentProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // 'withOpacity' is deprecated. Use 'withAlpha'.
            color: Colors.black.withAlpha(13), // (0.05 * 255 = 12.75, rounded to 13)
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                ? profile.avatarUrl!
                : 'https://i.pravatar.cc/150'), // Ảnh dự phòng
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã sinh viên: ${profile.studentCode}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Ubuntu',
                ),
              ),
              SizedBox(height: 4),
              Text(
                profile.fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                ),
              ),
              SizedBox(height: 4),
              Text(
                profile.adminClass,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontFamily: 'Ubuntu',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con: Một hàng trong Menu
  Widget _buildMenuRow({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu'),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Widget con: Dấu gạch ngang
  Widget _buildDivider() {
    return Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]);
  }
}