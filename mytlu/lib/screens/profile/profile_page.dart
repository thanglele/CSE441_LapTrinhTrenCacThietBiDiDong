import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // Import model User
import 'change_password_page.dart'; // Sẽ import ở bước sau
import 'user_info_page.dart'; // Sẽ import ở bước sau

// Màu chủ đạo (Copy từ các file khác)
const Color tluPrimaryColor = Color(0xFF0D47A1);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dữ liệu giả lập cho người dùng
  final User _currentUser = User(
    id: 'GV25082',
    fullName: 'Nguyễn Thị Dinh',
    email: 'GSntd@edu.tlu.vn',
    phone: '0392513985',
    department: 'Kỹ thuật phần mềm',
    faculty: 'Công nghệ thông tin',
    position: 'Giảng viên',
    academicRank: 'GS.TS',
    officeRoom: 'Phòng CNTT',
    dob: '12/04/2004',
    pob: 'Hà Nội',
    gender: 'Nữ',
    address: 'Hà Nội',
    imageUrl: 'https://i.pravatar.cc/150?img=4', // Ảnh giả
  );

  bool _notificationsEnabled = true; // Trạng thái bật/tắt thông báo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Cá nhân', style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card Thông tin cơ bản
            _buildUserInfoCard(),
            const SizedBox(height: 20),
            // Các tùy chọn thiết lập tài khoản
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  // Widget cho Card Thông tin cơ bản
  Widget _buildUserInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar và Tên
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_currentUser.imageUrl),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentUser.academicRank}. ${_currentUser.fullName}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currentUser.id,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    Text(
                      'Bộ môn: ${_currentUser.department}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 30),
            // Thông tin liên hệ
            _buildContactInfoRow(Icons.email_outlined, _currentUser.email),
            const SizedBox(height: 8),
            _buildContactInfoRow(Icons.phone_outlined, _currentUser.phone),
            const SizedBox(height: 8),
            _buildContactInfoRow(Icons.apartment_outlined, 'Khoa: ${_currentUser.faculty}'),
          ],
        ),
      ),
    );
  }

  // Widget helper cho hàng thông tin liên hệ
  Widget _buildContactInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: tluPrimaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  // Widget cho danh sách các tùy chọn cài đặt
  Widget _buildSettingsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Thiết lập tài khoản',
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _buildSettingsItem(
              title: 'Thông tin cá nhân',
              onTap: () {
                // Điều hướng đến trang thông tin chi tiết
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage(user: _currentUser),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              title: 'Thay đổi mật khẩu',
              onTap: () {
                // Điều hướng đến trang đổi mật khẩu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(user: _currentUser),
                  ),
                );
              },
            ),
            _buildSwitchItem(
              title: 'Bật thông báo',
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                // TODO: Xử lý logic bật/tắt thông báo thực tế
              },
            ),
            _buildSettingsItem(
              title: 'Cài đặt',
              onTap: () {
                // TODO: Xử lý logic Cài đặt
              },
            ),
            _buildLogoutItem(
              title: 'Đăng xuất',
              onTap: () {
                // TODO: Xử lý logic Đăng xuất
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper cho từng mục cài đặt có mũi tên
  Widget _buildSettingsItem({required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Widget helper cho mục cài đặt có nút switch
  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: tluPrimaryColor,
          ),
        ],
      ),
    );
  }

  // Widget helper cho mục Đăng xuất
  Widget _buildLogoutItem({required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
}