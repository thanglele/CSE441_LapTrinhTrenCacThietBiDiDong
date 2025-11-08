import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytlu/Students/history/models/session_history_response.dart';
import 'package:mytlu/Students/history/services/history_service.dart';
import 'package:mytlu/Students/history/widget/history_card.dart';
// import 'package:mytlu/Students/history/widgets/history_filter_bar.dart'; // ĐÃ XÓA
import 'package:mytlu/Students/schedule/widgets/week_calendar_bar.dart'; // IMPORT MỚI

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  final HistoryService _historyService = HistoryService();

  DateTime _selectedDate = DateTime.now();
  Future<List<SessionHistoryItem>>? _sessionsFuture;

  // final DateFormat _headerFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN'); // ĐÃ XÓA

  @override
  void initState() {
    super.initState();
    _fetchDataForSelectedDate();
  }

  /// Gọi services để tải dữ liệu cho ngày đã chọn
  void _fetchDataForSelectedDate() {
    setState(() {
      _sessionsFuture = _historyService.getHistoryForDate(_selectedDate);
    });
  }

  /// Hàm callback khi chọn ngày mới từ WeekCalendarBar
  void _onDateSelected(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    // Tải lại dữ liệu cho ngày mới
    _fetchDataForSelectedDate();
  }

  // Widget _buildDateNavigator() { ... } // ĐÃ XÓA

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Thanh tiêu đề
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 10.0),
          child: const Center(
            child: Text(
              "Lịch sử điểm danh",
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ),

        // Bộ lọc (Dropdowns)
        // HistoryFilterBar( ... ), // ĐÃ XÓA

        // Điều hướng ngày (ĐÃ THAY THẾ BẰNG WeekCalendarBar)
        WeekCalendarBar(
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
        ),

        // Vạch kẻ ngang
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

        // Danh sách kết quả
        Expanded(
          child: FutureBuilder<List<SessionHistoryItem>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              // Trạng thái Tải
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Trạng thái Lỗi
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Lỗi tải dữ liệu: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // Trạng thái Thành công
              final sessions = snapshot.data;
              if (sessions == null || sessions.isEmpty) {
                return const Center(
                  child: Text("Không có buổi học nào trong ngày này."),
                );
              }

              // Hiển thị ListView
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return HistoryCard(session: sessions[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}