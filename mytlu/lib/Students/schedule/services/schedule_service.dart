import 'dart:convert'; // Cần cho utf8
import 'package:intl/intl.dart';
import 'package:mytlu/services/api_service.dart';
import 'package:mytlu/Students/schedule/models/schedule_model.dart';

class ScheduleService {
  final ApiService _apiService = ApiService();

  Future<List<ScheduleModel>> getScheduleByDate(DateTime selectedDate) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      final String endpoint = '/api/v1/sessions/my-schedule-by-date?selectedDate=$formattedDate';

      final response = await _apiService.getRequest(endpoint);

      if (response.statusCode == 200) {
        // === SỬA LỖI HIỂN THỊ "Bu?i h?c" ===
        // Dùng utf8.decode để đọc tiếng Việt chuẩn
        final String utf8Body = utf8.decode(response.bodyBytes);
        return scheduleModelFromJson(utf8Body);
        // ===================================
      } else {
        throw Exception('Lỗi tải lịch học (Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi tải lịch học: $e');
    }
  }
}

