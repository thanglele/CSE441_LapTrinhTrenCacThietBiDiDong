import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LichHocTuan extends StatefulWidget {
  final Function(DateTime) onSelectDate;

  const LichHocTuan({super.key, required this.onSelectDate});

  @override
  State<LichHocTuan> createState() => _LichHocTuanState();
}

class _LichHocTuanState extends State<LichHocTuan> {
  DateTime _currentWeekStart = DateTime.now();
  DateTime? _selectedDate;
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentWeekStart = _getMondayOfWeek(DateTime.now());
    // Initialize locale data for 'vi' to avoid DateFormat locale errors.
    initializeDateFormatting('vi').then((_) {
      if (mounted) {
        setState(() {
          _localeReady = true;
        });
      }
    });
  }

  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * offset));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> daysOfWeek = List.generate(7, (index) {
      return _currentWeekStart.add(Duration(days: index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: calendar icon + title (above the week controls)
        Row(
          children: const [
            Icon(Icons.calendar_month, color: Color(0xFF407CDC), size: 28),
            SizedBox(width: 8),
            Text(
              "Lịch học",
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Below the title: week-range with left/right arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: Colors.black87),
              onPressed: () => _changeWeek(-1),
            ),
            Text(
              "Tuần ${DateFormat('dd/MM').format(daysOfWeek.first)} - ${DateFormat('dd/MM').format(daysOfWeek.last)}",
              style: const TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, color: Colors.black87),
              onPressed: () => _changeWeek(1),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Hiển thị 7 ngày trong tuần
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek.map((day) {
            bool isSelected = _selectedDate != null &&
                DateUtils.isSameDay(_selectedDate, day);
            // safe weekday label: use intl when locale data ready, otherwise fallback
            String weekdayLabel;
            if (_localeReady) {
              weekdayLabel = DateFormat.E('vi').format(day).toUpperCase();
            } else {
              const fallback = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
              weekdayLabel = fallback[day.weekday % 7];
            }
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = day;
                });
                widget.onSelectDate(day);
              },
              child: Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      weekdayLabel,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
