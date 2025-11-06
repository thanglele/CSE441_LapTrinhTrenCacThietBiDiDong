import 'dart:convert'; // Cần cho utf8
import 'package:intl/intl.dart'; // Cần để format ngày
import 'package:mytlu/services/api_service.dart'; // Import ApiService chung
import 'package:mytlu/Students/schedule/models/schedule_model.dart';

class ScheduleService {
  final ApiService _apiService = ApiService();

  /// Gọi API lấy lịch học theo ngày
  Future<List<ScheduleModel>> getScheduleByDate(DateTime selectedDate) async {

    // ==========================================================
    // === API THẬT (ĐÃ BẬT) ===
    // ==========================================================

    try {
      // 1. Chuyển ngày (DateTime) thành chuỗi (String) YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      // 2. Tạo endpoint (đường dẫn)
      // (Endpoint này LẤY TỪ C# CONTROLLER BẠN ĐÃ VIẾT)
      final String endpoint = '/api/v1/sessions/my-schedule-by-date?selectedDate=$formattedDate';

      // 3. Gọi API (dùng hàm "chuẩn" getRequest)
      final response = await _apiService.getRequest(endpoint);

      if (response.statusCode == 200) {
        // 4. Sửa lỗi UTF-8 (để đọc tiếng Việt, ví dụ: "Buổi học")
        final String utf8Body = utf8.decode(response.bodyBytes);

        // 5. Chuyển JSON thành Model
        return scheduleModelFromJson(utf8Body);
      } else {
        // (ApiService "chuẩn" sẽ tự ném lỗi 4xx, 5xx)
        throw Exception('Lỗi tải lịch học (Code: ${response.statusCode})');
      }
    } catch (e) {
      // Bắt lỗi (từ ApiService) và ném ra
      throw Exception('Lỗi tải lịch học: $e');
    }
  }
}