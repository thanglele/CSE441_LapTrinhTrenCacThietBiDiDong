import 'package:flutter/material.dart';

/// Widget thanh bộ lọc (Dropdowns)
class HistoryFilterBar extends StatelessWidget {
  final ValueChanged<String> onTimeFilterChanged;
  final ValueChanged<String> onSubjectFilterChanged;

  const HistoryFilterBar({
    super.key,
    required this.onTimeFilterChanged,
    required this.onSubjectFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white, // Nền trắng
      child: Row(
        children: [
          // Lọc thời gian (ví dụ)
          Expanded(
            child: _buildDropdown("Ngày", Icons.calendar_today, onTimeFilterChanged),
          ),
          const SizedBox(width: 16),
          // Lọc môn học (ví dụ)
          Expanded(
            child: _buildDropdown("Tất cả môn học", Icons.school, onSubjectFilterChanged),
          ),
        ],
      ),
    );
  }

  /// Helper build dropdown (giống mockup)
  Widget _buildDropdown(String hint, IconData icon, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Nền xám nhạt
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 18.0, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: [
            // TODO: Thay thế bằng danh sách filter thật
            DropdownMenuItem(value: "item1", child: Text(hint)),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

/// Widget hiển thị Tag trạng thái dựa trên dữ liệu API
class HistoryStatusTag extends StatelessWidget {
  final String status;
  const HistoryStatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    String text;
    IconData iconData;

    // MAP DỮ LIỆU API ("completed", "in_progress", "scheduled")
    // SANG GIAO DIỆN MOCKUP ("Đúng giờ", "Vắng mặt", "Đi muộn")
    //
    // **LƯU Ý:** Đây là phỏng đoán. API không trả về "late" (Đi muộn).
    // Tôi sẽ map "completed" -> "Đã HT"
    // "in_progress" -> "Đang diễn ra"
    // "scheduled" -> "Chưa diễn ra"

    switch (status.toLowerCase()) {
      case "completed":
        backgroundColor = Colors.green.shade50;
        foregroundColor = Colors.green.shade700;
        text = "Đã hoàn thành";
        iconData = Icons.check_circle_outline;
        break;
      case "in_progress":
        backgroundColor = Colors.orange.shade50;
        foregroundColor = Colors.orange.shade700;
        text = "Đang diễn ra";
        iconData = Icons.hourglass_top_outlined;
        break;
      case "scheduled":
        backgroundColor = Colors.grey.shade200;
        foregroundColor = Colors.grey.shade700;
        text = "Chưa diễn ra";
        iconData = Icons.schedule_outlined;
        break;
      default:
      // Các trạng thái khác (absent, late... nếu API có)
        backgroundColor = Colors.red.shade50;
        foregroundColor = Colors.red.shade700;
        text = status; // Hiển thị trạng thái lạ
        iconData = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14.0, color: foregroundColor),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}