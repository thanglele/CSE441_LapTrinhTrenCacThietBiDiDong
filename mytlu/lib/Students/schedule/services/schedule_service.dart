import 'dart:convert'; // Cần cho utf8
import 'package:intl/intl.dart'; // Cần để format ngày
import 'package:mytlu/services/api_service.dart'; // Import ApiService chung
import 'package:mytlu/Students/schedule/models/schedule_model.dart';
import 'package:mytlu/core/errors/exceptions.dart'; // Import ApiException

class ScheduleService {
  final ApiService _apiService = ApiService();

  /// Gọi API lấy lịch học theo ngày
  /// SỬA LỖI: Đổi tên "ByDate" -> "ForDate" để khớp với schedule_screen.dart
  Future<List<ScheduleModel>> getScheduleForDate(DateTime selectedDate) async {
    try {
      // 1. Chuyển ngày (DateTime) thành chuỗi (String) YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      // 2. Tạo endpoint (đường dẫn)
      final String endpoint =
          '/api/v1/sessions/my-schedule-by-date?selectedDate=$formattedDate';

      // 3. Gọi API (dùng hàm "chuẩn" getRequest)
      final response = await _apiService.getRequest(endpoint);

      // 4. Sửa lỗi UTF-8 (để đọc tiếng Việt, ví dụ: "Buổi học")
      // (ApiService "chuẩn" sẽ tự ném lỗi 4xx, 5xx nên không cần check 200)
      final String utf8Body = utf8.decode(response.bodyBytes);

      // 5. Chuyển JSON thành Model
      return scheduleModelFromJson(utf8Body);

    } on ApiException {
      rethrow; // Ném lại lỗi API (4xx, 5xx)
    } catch (e) {
      // Bắt lỗi (mạng, parse...) và ném ra
      throw Exception('Lỗi tải lịch học: $e');
    }
  }
}