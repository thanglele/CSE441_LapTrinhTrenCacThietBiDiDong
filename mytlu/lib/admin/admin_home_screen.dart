import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF3080F8);
const Color kBackgroundGray = Color(0xFFF0F0F0);
const Color kTextTitle = Color(0xFF333333);
const Color kTextSubtitle = Color(0xFF888888);

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundGray,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),

            const SizedBox(height: 16),

            _buildMenuCard(
              title: 'Quản lý giảng viên',
              subtitle: 'Quản lý thông tin giảng viên',
            ),

            _buildMenuCard(
              title: 'Quản lý môn học',
              subtitle: 'Quản lý thông tin môn học',
            ),

            _buildMenuCard(
              title: 'Tổng quan hệ thống / Thống kê',
              subtitle: 'Tra cứu và Báo cáo',
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kPrimaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My TLU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/Avatar.jpg'),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Bùi Viết Hiển',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kTextTitle,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: kTextSubtitle,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}