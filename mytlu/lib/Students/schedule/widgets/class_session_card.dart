import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytlu/Students/schedule/models/schedule_model.dart';
import 'package:mytlu/Students/theme/app_theme.dart'; // Import AppTheme

class ClassSessionCard extends StatelessWidget {
  final ScheduleModel session;
  // 1. Thêm callback
  final VoidCallback? onAttendPressed;

  const ClassSessionCard({
    super.key,
    required this.session,
    this.onAttendPressed, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    final String startTime = DateFormat('HH:mm').format(session.startTime);
    final String endTime = DateFormat('HH:mm').format(session.endTime);

    final DateTime now = DateTime.now();
    bool hasAttended = session.attendanceStatus == 'present' ||
        session.attendanceStatus == 'late';
    bool isAbsent = session.attendanceStatus == 'absent';

    String statusText = '';
    Color? chipBgColor;
    Color? chipTextColor;

    if (hasAttended || isAbsent || now.isAfter(session.endTime)) {
      statusText = 'Đã kết thúc';
      chipBgColor = Colors.grey[300];
      chipTextColor = Colors.grey[700];
    } else if (now.isAfter(session.startTime) &&
        now.isBefore(session.endTime)) {
      statusText = 'Đang diễn ra';
      chipBgColor = Colors.green[100];
      chipTextColor = Colors.green[800];
    } else {
      statusText = 'Sắp diễn ra';
      chipBgColor = Colors.blue[100];
      chipTextColor = Colors.blue[800];
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.className,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(statusText,
                      style: TextStyle(
                          color: chipTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  backgroundColor: chipBgColor,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hàng 2
            Text(
              session.location,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Hàng 3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "$startTime - $endTime",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                // 2. Sửa logic của hàm _buildActionRow
                _buildActionRow(context, session.attendanceStatus, statusText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context, String attendanceStatus, String statusText) {
    // 1. Đã điểm danh
    if (attendanceStatus == 'present' || attendanceStatus == 'late') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(
              attendanceStatus == 'late'
                  ? 'Đã điểm danh (Muộn)'
                  : 'Đã điểm danh',
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      );
    }

    // 2. Vắng (Đã kết thúc VÀ pending)
    if (attendanceStatus == 'absent' ||
        (statusText == 'Đã kết thúc' && attendanceStatus == 'pending')) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          const Text('Chưa điểm danh',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      );
    }

    // --- 3. SỬA ĐỔI CHÍNH (LOGIC NÚT BẤM) ---

    // 3a. Nếu ĐANG DIỄN RA
    if (statusText == 'Đang diễn ra' && attendanceStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: onAttendPressed, // <--- GỌI CALLBACK
        icon: const Icon(Icons.qr_code_scanner, size: 16),
        label:
        const Text('Điểm danh', style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor, // <--- MÀU XANH
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
    }

    // 3b. Nếu SẮP DIỄN RA
    if (statusText == 'Sắp diễn ra' && attendanceStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: null, // Bị vô hiệu hóa (disabled)
        icon: const Icon(Icons.qr_code_scanner, size: 16),
        label: const Text('Điểm danh', style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey[400],
          disabledForegroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
    }

    // Mặc định
    return Container();
  }
}