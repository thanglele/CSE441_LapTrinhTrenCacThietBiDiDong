import 'package:intl/intl.dart'; // Dùng để format ngày
import 'package:mytlu/core/errors/exceptions.dart';
import 'package:mytlu/services/api_service.dart'; // Import services chung
import 'package:mytlu/Students/history/models/session_history_response.dart';

class HistoryService {
  final ApiService _apiService = ApiService();
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  /// Lấy lịch sử điểm danh cho một ngày cụ thể
  /// API này hỗ trợ lọc theo 'startDate' và 'endDate' (theo Tài liệu API Trang 18)
  Future<List<SessionHistoryItem>> getHistoryForDate(DateTime date) async {
    // Format ngày thành chuỗi 'yyyy-MM-dd'
    final dateString = _apiDateFormat.format(date);

    // Endpoint có thêm query params.
    // Lấy pageSize=100 để đảm bảo lấy hết các buổi học trong ngày
    final endpoint =
        '/api/v1/reports/session-history?startDate=$dateString&endDate=$dateString&page=1&pageSize=100';

    try {
      final response = await _apiService.getRequest(endpoint);

      // Parse JSON
      final historyResponse = paginatedSessionHistoryResponseFromJson(response.body);

      // Sắp xếp lại các buổi học theo thời gian bắt đầu
      historyResponse.sessions.sort((a, b) => a.sessionStart.compareTo(b.sessionStart));

      // Trả về danh sách các buổi học
      return historyResponse.sessions;
    } on ApiException {
      // Ném lại lỗi API để màn hình (screen) có thể bắt
      rethrow;
    } catch (e) {
      // Bắt các lỗi chung khác (ví dụ: lỗi parse, lỗi mạng)
      throw Exception('Lỗi không xác định khi tải lịch sử: $e');
    }
  }
}