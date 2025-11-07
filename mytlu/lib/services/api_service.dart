// File: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart'; // <<< Dùng cấu hình
import '../models/schedule_session_dto.dart';

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

// (Các hàm API khác như startAttendance sẽ được thêm vào đây)
}