import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// 1. IMPORT CÁC "LINH KIỆN"
import 'package:mytlu/Students/schedule/widgets/week_calendar_bar.dart';
import 'package:mytlu/Students/schedule/models/schedule_model.dart';
import 'package:mytlu/Students/schedule/services/schedule_service.dart';
import 'package:mytlu/Students/schedule/widgets/class_session_card.dart';

/// Đây là màn hình cho Tab 0 (Lịch học)
class ScheduleScreen extends StatefulWidget {
  // --- SỬA 1: THÊM LẠI THAM SỐ NÀY ---
  // (Để nhận hàm chuyển tab từ StudentDashboard)
  final Function(int)? onSwitchTab;

  const ScheduleScreen({super.key, this.onSwitchTab});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

// --- SỬA 2: THÊM LẠI "with AutomaticKeepAliveClientMixin" ---
// (Để giữ trạng thái tab khi chuyển)
class _ScheduleScreenState extends State<ScheduleScreen>
    with AutomaticKeepAliveClientMixin {
  final ScheduleService _scheduleService = ScheduleService();
  late DateTime _selectedDate;
  late Future<List<ScheduleModel>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _selectedDate = DateTime.now();
    _loadScheduleForDate(_selectedDate);
  }

  // --- SỬA 3: Giữ trạng thái của tab ---
  @override
  bool get wantKeepAlive => true;

  void _onDateSelected(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _loadScheduleForDate(newDate);
    });
  }

  void _loadScheduleForDate(DateTime date) {
    setState(() {
      // --- SỬA 4: SỬA TÊN HÀM TỪ 'By' -> 'For' ---
      _scheduleFuture = _scheduleService.getScheduleForDate(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- SỬA 5: THÊM super.build(context) ---
    // (Bắt buộc khi dùng AutomaticKeepAliveClientMixin)
    super.build(context);

    // Dùng Column + Expanded thay vì SingleChildScrollView
    // để đảm bảo ListView cuộn đúng cách
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thanh Lịch 7 Ngày
          WeekCalendarBar(
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),
          const SizedBox(height: 24),

          // 2. Tiêu đề (VD: Thứ Hai, 22/9/2025)
          Text(
            "Lớp học ngày ${DateFormat('E, d/M/yyyy', 'vi_VN').format(_selectedDate)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // 3. Danh sách Card (Dùng FutureBuilder)
          Expanded( // <-- Dùng Expanded
            child: FutureBuilder<List<ScheduleModel>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi tải lịch học: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Không có lịch học cho ngày này.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final sessions = snapshot.data!;
                return ListView.builder(
                  // Xóa shrinkWrap và physics
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    // --- SỬA 6: THÊM LẠI LOGIC NÚT ĐIỂM DANH ---
                    return ClassSessionCard(
                      session: sessions[index],
                      onAttendPressed: () {
                        widget.onSwitchTab?.call(1); // Chuyển sang Tab 1 (Quét QR)
                      },
                    );
                    // --- KẾT THÚC SỬA 6 ---
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}