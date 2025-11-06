import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytlu/Students/schedule/models/schedule_model.dart';


/// Widget này hiển thị 1 Card Lớp học (y hệt Figma 82f04a.png)
/// File này sử dụng LOGIC SO SÁNH GIỜ (Client-side) theo yêu cầu
class ClassSessionCard extends StatelessWidget {
  final ScheduleModel session;

  const ClassSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final String startTime = DateFormat('HH:mm').format(session.startTime);
    final String endTime = DateFormat('HH:mm').format(session.endTime);

    // === LOGIC THỜI GIAN THỰC (THEO YÊU CẦU CỦA BẠN) ===
    final DateTime now = DateTime.now();

    // 1. Kiểm tra trạng thái điểm danh (Ưu tiên cao nhất)
    bool hasAttended = session.attendanceStatus == 'present' || session.attendanceStatus == 'late';
    bool isAbsent = session.attendanceStatus == 'absent';

    // 2. Nếu chưa điểm danh (pending), thì mới so sánh giờ
    String statusText = '';
    // Color statusColor = Colors.grey; // <-- BIẾN NÀY ĐÃ BỊ XÓA (VÌ KHÔNG DÙNG)
    Color? chipBgColor;
    Color? chipTextColor;

    if (hasAttended) {
      statusText = 'Đã kết thúc';
      // statusColor = Colors.grey[700]!;
      chipBgColor = Colors.grey[300];
      chipTextColor = Colors.grey[700];
    } else if (isAbsent) {
      statusText = 'Đã kết thúc';
      // statusColor = Colors.grey[700]!;
      chipBgColor = Colors.grey[300];
      chipTextColor = Colors.grey[700];
    }
    // (Nếu 'pending', bắt đầu so sánh giờ)
    else if (now.isAfter(session.endTime)) {
      statusText = 'Đã kết thúc';
      // statusColor = Colors.grey[700]!;
      chipBgColor = Colors.grey[300];
      chipTextColor = Colors.grey[700];
    } else if (now.isAfter(session.startTime) && now.isBefore(session.endTime)) {
      statusText = 'Đang diễn ra';
      // statusColor = Colors.green[700]!;
      chipBgColor = Colors.green[100];
      chipTextColor = Colors.green[800];
    } else {
      statusText = 'Sắp diễn ra';
      // statusColor = Colors.blue[800]!;
      chipBgColor = Colors.blue[100];
      chipTextColor = Colors.blue[800];
    }
    // === KẾT THÚC LOGIC THỜI GIAN THỰC ===


    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1: Tên môn học và Status
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
                SizedBox(width: 10),
                // Hiển thị Tag (Chip) dựa trên logic thời gian
                Chip(
                  label: Text(
                      statusText,
                      style: TextStyle(color: chipTextColor, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                  backgroundColor: chipBgColor,
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hàng 2: Phòng học
            Text(
              session.location,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Hàng 3: Thời gian và Nút Hành động
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
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                // HIỂN THỊ NÚT BẤM (Logic của Sinh viên, không phải của Giảng viên)
                _buildActionRow(context, session.attendanceStatus, statusText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con cho Nút/Hành động (phần dưới cùng)
  // (Đã cập nhật để dùng 'statusText' (text 'Đang diễn ra') từ logic thời gian)
  Widget _buildActionRow(BuildContext context, String attendanceStatus, String statusText) {

    // 1. Đã điểm danh (Đúng giờ hoặc Muộn)
    if (attendanceStatus == 'present' || attendanceStatus == 'late') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
              attendanceStatus == 'late' ? 'Đã điểm danh (Muộn)' : 'Đã điểm danh',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)
          ),
        ],
      );
    }

    // 2. Vắng (Chưa điểm danh)
    if (attendanceStatus == 'absent') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text(
              'Chưa điểm danh',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)
          ),
        ],
      );
    }

    // 3. Nếu logic thời gian (statusText) là "Đã kết thúc"
    //    VÀ sinh viên vẫn "pending"
    if (statusText == 'Đã kết thúc' && attendanceStatus == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text(
              'Chưa điểm danh',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)
          ),
        ],
      );
    }

    // 4. Nếu logic thời gian (statusText) là "Sắp diễn ra" HOẶC "Đang diễn ra"
    //    VÀ sinh viên vẫn "pending"
    //    (Chúng ta giữ nút xám như bạn yêu cầu, "phần qr giữ nguyên nút xám")
    if ((statusText == 'Sắp diễn ra' || statusText == 'Đang diễn ra') && attendanceStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: null, // Bị vô hiệu hóa (disabled)
        icon: Icon(Icons.qr_code_scanner, size: 16),
        label: Text('Điểm danh', style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey[400],
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
    }

    // Mặc định (fallback)
    return Container();
  }
}