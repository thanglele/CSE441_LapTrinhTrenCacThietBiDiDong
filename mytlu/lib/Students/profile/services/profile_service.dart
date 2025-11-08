import 'package:mytlu/core/errors/exceptions.dart';
import 'package:mytlu/services/api_service.dart'; // Import service chung
import 'package:mytlu/Students/profile/models/student_profile.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  /// Lấy thông tin chi tiết (profile) của sinh viên đã đăng nhập
  Future<StudentProfile> getStudentProfile() async {
    const endpoint = '/api/v1/auth/me';

    try {
      final response = await _apiService.getRequest(endpoint);

      // Giao cho Model parse
      return studentProfileFromJson(response.body);
    } on ApiException {
      // Ném lại lỗi API (401, 404, 500...)
      rethrow;
    } catch (e) {
      // Bắt các lỗi chung khác (mạng, parse...)
      throw Exception('Lỗi không xác định khi tải hồ sơ: $e');
    }
  }
}