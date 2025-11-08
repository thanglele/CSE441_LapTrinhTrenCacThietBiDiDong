// Import ApiService CHUNG (chuẩn hệ thống)
import 'package:mytlu/services/api_service.dart';
import 'package:mytlu/core/errors/exceptions.dart'; // Import ApiException

// Import Model CheckIn (đã tạo ở bước trước)
import 'package:mytlu/Students/attendance/models/check_in_request_model.dart';
import 'package:mytlu/Students/attendance/models/check_in_response_model.dart';

class CheckInService {
  final ApiService _apiService = ApiService();

  /// Gửi yêu cầu điểm danh sinh viên
  Future<CheckInResponse> checkInStudent(CheckInRequest request) async {
    // ---- SỬA LẠI KHỐI TRY...CATCH Ở ĐÂY ----
    try {
      final response = await _apiService.postRequest(
        '/api/v1/attendance/check-in',
        request.toJson(),
      );

      // response.statusCode đã được xử lý bên trong _apiService.postRequest
      // Nếu code là 200, nó sẽ chạy tiếp. Nếu không, _apiService đã ném ApiException.
      return checkInResponseFromJson(response.body);
    } on ApiException {
      // Nếu là lỗi API (400, 401, 500...), ném nó lên
      rethrow;
    } catch (e) {
      // Nếu là lỗi MẠNG hoặc lỗi CHUNG, bọc nó lại
      throw Exception('Lỗi khi điểm danh: $e');
    }
    // ---- KẾT THÚC SỬA ĐỔI ----
  }
}