import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// 1. IMPORT CÁC "LINH KIỆN" MÀ BẠN ĐÃ CÓ
import 'package:mytlu/Students/schedule/widgets/week_calendar_bar.dart'; // Thanh 7 ngày
import 'package:mytlu/Students/schedule/models/schedule_model.dart';   // Model
import 'package:mytlu/Students/schedule/services/schedule_service.dart'; // Service
import 'package:mytlu/Students/schedule/widgets/class_session_card.dart'; // Card

/// Đây là màn hình cho Tab 0 (Lịch học)
/// Nó quản lý state (trạng thái) của riêng nó
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Service để gọi API lịch học
  final ScheduleService _scheduleService = ScheduleService();

  // Biến State (trạng thái)
  late DateTime _selectedDate;
  late Future<List<ScheduleModel>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo intl cho Tiếng Việt (nếu chưa có ở main.dart)
    initializeDateFormatting('vi_VN', null);

    // 1. Khởi tạo: Chọn ngày hôm nay
    _selectedDate = DateTime.now();
    // 2. Gọi API cho ngày hôm nay
    _loadScheduleForDate(_selectedDate);
  }

  // Hàm này được gọi khi người dùng chọn ngày mới (từ WeekCalendarBar)
  void _onDateSelected(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      // 3. Gọi LẠI API với ngày mới
      _loadScheduleForDate(newDate);
    });
  }

  // Hàm gọi API (để dễ quản lý)
  void _loadScheduleForDate(DateTime date) {
    _scheduleFuture = _scheduleService.getScheduleByDate(date);
  }

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView cho phép cuộn nếu nội dung dài
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thanh Lịch 7 Ngày
            WeekCalendarBar(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected, // <-- Gọi hàm này khi chọn ngày
            ),
            const SizedBox(height: 24),

            // 2. Tiêu đề (VD: Thứ Hai, 22/9/2025)
            Text(
              "Lớp học ngày ${DateFormat('E, d/M/yyyy', 'vi_VN').format(_selectedDate)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Danh sách Card (Dùng FutureBuilder)
            FutureBuilder<List<ScheduleModel>>(
              future: _scheduleFuture, // <-- Theo dõi API lịch học
              builder: (context, snapshot) {
                // Đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Bị Lỗi
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi tải lịch học: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Thành công (nhưng rỗng)
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Không có lịch học cho ngày này.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                  );
                }

                // Thành công (Có dữ liệu)
                final sessions = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Quan trọng khi lồng ListView trong Column
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    // Dùng Card "xịn" (ClassSessionCard)
                    return ClassSessionCard(session: sessions[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}