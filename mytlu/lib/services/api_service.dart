// File: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart'; // <<< Dùng cấu hình
import '../models/schedule_session_dto.dart';
import 'package:intl/intl.dart';

class ApiService {
  // Dùng ApiConfig và thêm path '/api/v1'
  static const String _apiPath = '/api/v1';

  /// API (Thật) Lấy lịch học hôm nay của Giảng viên
  Future<List<ScheduleSession>> fetchTodayClasses(String jwtToken) async {
    // URL được tạo từ Base URL + Path API + Endpoint
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/lecturer/dashboard');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Gửi token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List jsonList = data['todaySessions'] as List;

        return jsonList.map((json) => ScheduleSession.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
            'Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Failed to load schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  Future<List<ScheduleSession>> fetchScheduleByDate(String jwtToken, DateTime date) async {
    // Định dạng ngày thành chuỗi 'YYYY-MM-DD' cho query parameter
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // URL được tạo từ Base URL + Path API + Endpoint
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/sessions/my-schedule-by-date?date=$formattedDate');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken', // Gửi token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // API này có thể trả về List trực tiếp
        final List jsonList = json.decode(response.body) as List;

        return jsonList.map((json) => ScheduleSession.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn.');
      } else {
        throw Exception('Failed to load schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  Future<void> startAttendance(String sessionId, String jwtToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/sessions/$sessionId/start-attendance');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          // API này thường không cần body, nhưng vẫn nên khai báo Content-Type
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Thành công, không cần trả về gì (nếu bạn không cần mã QR từ đây)
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn.');
      } else {
        // Xử lý các lỗi khác (ví dụ: 400 Bad Request nếu session đã kết thúc)
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Lỗi không xác định khi bắt đầu điểm danh.';
        throw Exception('Failed to start attendance. Status: ${response.statusCode}. Lỗi: $errorMessage');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }
// (Các hàm API khác như startAttendance sẽ được thêm vào đây)
}