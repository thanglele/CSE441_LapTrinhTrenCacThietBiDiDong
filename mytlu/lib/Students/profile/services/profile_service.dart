// Import ApiService CHUNG (từ file "chuẩn")
import 'package:mytlu/services/api_service.dart';
// Import Model (khuôn) bạn vừa tạo
import 'package:mytlu/Students/profile/models/student_profile.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<StudentProfile> getStudentProfile() async {
    try {
      // 1. Gọi API (Dùng hàm "chuẩn" getRequest)
      final response = await _apiService.getRequest('/api/v1/auth/me');

      if (response.statusCode == 200) {
        // 2. Chuyển JSON thành Model
        return studentProfileFromJson(response.body);
      } else {
        // 3. Ném lỗi nếu thất bại (ApiService đã xử lý 401, 404)
        throw Exception('Lỗi tải Profile (Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi tải Profile: $e');
    }
  }
}