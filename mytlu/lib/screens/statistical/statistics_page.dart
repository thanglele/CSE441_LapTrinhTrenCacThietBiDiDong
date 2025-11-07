import 'package:flutter/material.dart';

// Màu chủ đạo (Copy từ các file khác)
const Color tluPrimaryColor = Color(0xFF0D47A1);

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Thống kê', style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hàng Thẻ Tóm tắt (3 thẻ)
            _buildSummaryRow(),

            const SizedBox(height: 20),

            // 2. Thống kê điểm danh
            _buildAttendanceStatsCard(),

            const SizedBox(height: 20),

            // 3. Điểm danh gần đây
            _buildRecentAttendanceSection(),
          ],
        ),
      ),
    );
  }

  // Widget cho Hàng 1: 3 Thẻ Tóm tắt
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _buildSummaryCard(
            title: 'Tổng số môn học', value: '04', icon: Icons.book_outlined),
        const SizedBox(width: 12),
        _buildSummaryCard(
            title: 'Tổng số lớp học', value: '05', icon: Icons.class_outlined),
        const SizedBox(width: 12),
        _buildSummaryCard(
            title: 'Tổng số sinh viên', value: '300', icon: Icons.person_outline),
      ],
    );
  }

  // Widget helper cho từng thẻ tóm tắt
  Widget _buildSummaryCard(
      {required String title, required String value, required IconData icon}) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Icon(icon, color: tluPrimaryColor, size: 28),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho Hàng 2: Thẻ Thống kê Điểm danh
  Widget _buildAttendanceStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê điểm danh:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Hàng hiển thị %
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatPercentage(label: 'Đúng giờ', percentage: '85 %', color: Colors.green),
                _StatPercentage(label: 'Đi muộn', percentage: '7 %', color: Colors.orange),
                _StatPercentage(label: 'Vắng mặt', percentage: '8 %', color: Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            // Thanh Progress Bar
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  // Widget con cho thanh ProgressBar
  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Expanded(
            flex: 85, // Tỷ lệ 85%
            child: Container(color: Colors.green, height: 12),
          ),
          Expanded(
            flex: 7, // Tỷ lệ 7%
            child: Container(color: Colors.orange, height: 12),
          ),
          Expanded(
            flex: 8, // Tỷ lệ 8%
            child: Container(color: Colors.red, height: 12),
          ),
        ],
      ),
    );
  }

  // Widget cho Hàng 3: Điểm danh gần đây
  Widget _buildRecentAttendanceSection() {
    return Column(
      children: [
        // Tiêu đề
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Điểm danh gần đây',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text('Xem tất cả'),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ],
        ),
        // Danh sách
        _buildRecentClassCard(
          subjectName: 'Lập trình python',
          room: 'Phòng 305 - B5',
          time: '07:00 - 07:50',
          stats: '51 / 4 / 5 | 60 sinh viên',
        ),
        _buildRecentClassCard(
          subjectName: 'Cơ sở dữ liệu',
          room: 'Phòng 305 - B5',
          time: '07:00 - 07:50',
          stats: '51 / 4 / 5 | 60 sinh viên',
        ),
        _buildRecentClassCard(
          subjectName: 'Cấu trúc dữ liệu và giải thuật',
          room: 'Phòng 305 - B5',
          time: '07:00 - 07:50',
          stats: '51 / 4 / 5 | 60 sinh viên',
        ),
      ],
    );
  }

  // Widget helper cho từng thẻ Lớp học gần đây
  Widget _buildRecentClassCard({
    required String subjectName,
    required String room,
    required String time,
    required String stats,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(room, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
                Text(
                  stats,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget helper nhỏ cho các mục %
class _StatPercentage extends StatelessWidget {
  final String label;
  final String percentage;
  final Color color;
  const _StatPercentage({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          percentage,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
      ],
    );
  }
}