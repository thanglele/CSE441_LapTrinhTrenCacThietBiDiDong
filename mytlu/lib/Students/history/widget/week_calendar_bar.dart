import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytlu/Students/theme/app_theme.dart'; // Import Theme

/// Widget này hiển thị 1 thanh 7 ngày (Thứ 2 - CN)
class WeekCalendarBar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeekCalendarBar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<WeekCalendarBar> createState() => _WeekCalendarBarState();
}

class _WeekCalendarBarState extends State<WeekCalendarBar> {
  late DateTime _startOfWeek;

  @override
  void initState() {
    super.initState();
    _calculateStartOfWeek(widget.selectedDate);
  }

  @override
  void didUpdateWidget(covariant WeekCalendarBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật tuần nếu ngày được chọn từ bên ngoài thay đổi
    if (widget.selectedDate.day != oldWidget.selectedDate.day) {
      _calculateStartOfWeek(widget.selectedDate);
    }
  }

  void _calculateStartOfWeek(DateTime date) {
    // Bắt đầu từ Thứ 2 (weekday == 1)
    _startOfWeek = date.subtract(Duration(days: date.weekday - 1));
  }

  void _changeWeek(int days) {
    final newStartOfWeek = _startOfWeek.add(Duration(days: days));
    setState(() {
      _startOfWeek = newStartOfWeek;
    });
    // Khi đổi tuần, tự động chọn ngày đầu tuần đó và báo cho cha
    widget.onDateSelected(newStartOfWeek);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh điều hướng tuần
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () => _changeWeek(-7),
              ),
              Text(
                DateFormat('MMMM, yyyy', 'vi_VN').format(_startOfWeek),
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => _changeWeek(7),
              ),
            ],
          ),
        ),

        // === GIAO DIỆN THANH 7 NGÀY (ĐÃ SỬA LỖI OVERFLOW) ===
        SizedBox(
          height: 90,
          child: Row(
            // Dùng Row thay vì ListView
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final day = _startOfWeek.add(Duration(days: index));
              final bool isSelected = DateFormat('yyyy-MM-dd').format(day) ==
                  DateFormat('yyyy-MM-dd').format(widget.selectedDate);

              // Dùng Expanded để các item tự chia sẻ không gian
              return Expanded(
                child: _buildDayItem(day, isSelected),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Widget con cho từng ô ngày (Th 2, 22/9)
  Widget _buildDayItem(DateTime day, bool isSelected) {
    String weekDay = DateFormat('E', 'vi_VN').format(day); // "Th 2"
    String dayOfMonth = DateFormat('d').format(day); // "22"
    String month = DateFormat('M').format(day); // "9"

    return GestureDetector(
      onTap: () => widget.onDateSelected(day),
      child: Container(
        // Xóa width: 60, để Expanded tự co dãn
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Giảm margin
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekDay, // "Th 2"
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayOfMonth, // "22"
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              month, // "9"
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}