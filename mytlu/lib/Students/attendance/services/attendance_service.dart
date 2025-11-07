// Import ApiService CHUNG (chuẩn hệ thống)
import 'package:mytlu/services/api_service.dart';

// Import Model CheckIn (đã tạo ở bước trước)
import 'package:mytlu/Students/attendance/models/check_in_request_model.dart';
import 'package:mytlu/Students/attendance/models/check_in_response_model.dart ';
class CheckInService {
  final ApiService _apiService = ApiService();

  /// Gửi yêu cầu điểm danh sinh viên
  Future<CheckInResponse> checkInStudent(CheckInRequest request) async {
    try {
      // 1️⃣ Gọi API POST /attendance/check-in (chuẩn)
      final response = await _apiService.postRequest(
        '/api/v1/attendance/check-in',
        request.toJson(),
      );

      // 2️⃣ Kiểm tra phản hồi
      if (response.statusCode == 200) {
        // Parse JSON thành model
        return checkInResponseFromJson(response.body);
      } else {
        throw Exception('Điểm danh thất bại (Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi khi điểm danh: $e');
    }
  }
}
