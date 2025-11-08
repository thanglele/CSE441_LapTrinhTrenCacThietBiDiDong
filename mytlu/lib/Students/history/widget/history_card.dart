import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytlu/Students/history/models/session_history_response.dart';

// Import file chứa HistoryStatusTag
import 'package:mytlu/Students/history/widget/history_filter_bar.dart';

class HistoryCard extends StatelessWidget {
  final SessionHistoryItem session;

  // Format giờ:phút
  final DateFormat _timeFormat = DateFormat('HH:mm');
  // Format ngày/tháng/năm
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  HistoryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // Giả định thời gian kết thúc
    final DateTime sessionEnd =
    session.sessionStart.add(const Duration(hours: 1, minutes: 40));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1: Tên môn học và Status (Giống ClassSessionCard)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.className,
                    style: const TextStyle(
                      fontSize: 17, // Lấy style từ ClassSessionCard
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ubuntu',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                HistoryStatusTag(status: session.sessionStatus),
              ],
            ),
            const SizedBox(height: 8),

            // Hàng 2: Giảng viên (Giống hàng "Location" của ClassSessionCard)
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  session.lecturerName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600], // Lấy style từ ClassSessionCard
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hàng 3: Thời gian và Nút "Chi tiết" (Giống ClassSessionCard)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cụm Ngày & Giờ
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      // Gộp ngày giờ
                      "${_dateFormat.format(session.sessionStart)} (${_timeFormat.format(session.sessionStart)})",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                // Nút Chi tiết (thay cho Action Button)
                TextButton(
                  onPressed: () {
                    // TODO: Điều hướng đến màn hình chi tiết (giống mockup image_a089e2.png)
                    // Navigator.push(context, MaterialPageRoute(builder: ...));
                  },
                  child: const Text(
                    "Chi tiết",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}