import 'package:flutter/material.dart';
import '../../models/user_model.dart';

// Màu chủ đạo
const Color tluPrimaryColor = Color(0xFF0D47A1);

class UserInfoPage extends StatelessWidget {
  final User user;

  const UserInfoPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Thông tin giảng viên', // Đặt tên phù hợp với vai trò
            style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ảnh đại diện lớn
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
            ),
            const SizedBox(height: 20),
            // Các trường thông tin
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // Widget cho Card chứa các thông tin chi tiết
  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoField('Mã giảng viên', user.id), // Có thể đổi thành "Mã sinh viên"
            _buildInfoField('Họ và tên', user.fullName),
            _buildInfoField('Khoa', user.faculty),
            _buildInfoField('Bộ môn', user.department),
            _buildInfoField('Học hàm', user.academicRank),
            _buildInfoField('Chức vụ', user.position),
            _buildInfoField('Phòng làm việc', user.officeRoom),
            _buildInfoField('Ngày sinh', user.dob),
            _buildInfoField('Nơi sinh', user.pob),
            _buildInfoField('Giới tính', user.gender),
            _buildInfoField('Địa chỉ', user.address),
            _buildInfoField('Số điện thoại', user.phone),
            _buildInfoField('Email', user.email),
          ],
        ),
      ),
    );
  }

  // Widget helper cho từng hàng thông tin (Label + Value)
  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}