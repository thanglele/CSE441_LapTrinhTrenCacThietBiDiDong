// File: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart'; // <<< Dùng cấu hình
import '../models/class_detail_model.dart';
import '../models/schedule_session_dto.dart';
import 'package:intl/intl.dart';

import '../models/student_model.dart';
import '../models/subject_model.dart';

class ApiService {
  // Dùng ApiConfig và thêm path '/api/v1'
  static const String _apiPath = '/api/v1';

  
  Future<List<Subject>> fetchMySubjects(String jwtToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/lecturer/my-subjects');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body) as List;

        // <<< LƯU Ý: Phải sử dụng Subject.fromJson(json) trong Model của bạn
        return jsonList.map((json) => Subject.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Xác thực thất bại hoặc không có quyền truy cập.');
      } else {
        throw Exception('Failed to load subjects. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }
  Future<List<ClassDetail>> fetchMyClasses(String jwtToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/lecturer/my-classes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body) as List;
        // <<< LƯU Ý: Phải sử dụng ClassDetail.fromJson(json) >>>
        return jsonList.map((json) => ClassDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load classes. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }

  /// API (Thật) Lấy danh sách TẤT CẢ môn học của giảng viên (Lặp lại hàm SubjectManagement)
  Future<List<Subject>> fetchAllMySubjects(String jwtToken) async {
    // Dùng lại endpoint SubjectManagement đã có, nhưng đặt tên khác cho rõ ràng
    return fetchMySubjects(jwtToken);
  }
  Future<List<Student>> fetchStudentsInClass(String classCode, String jwtToken) async {
    // Đảm bảo import Student model nếu chưa có
    // import '../models/student_model.dart';

    const String _apiPath = '/api/v1'; // Đảm bảo khai báo _apiPath hoặc dùng trực tiếp ApiConfig
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/lecturer/classes/$classCode/students');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body) as List;

        // <<< LƯU Ý: Yêu cầu Model Student phải có Student.fromJson() >>>
        return jsonList.map((json) => Student.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403: Bạn không có quyền truy cập danh sách sinh viên.');
      }
      else {
        throw Exception('Failed to load students. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }
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
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/lecturer/my-schedule-by-date?selectedDate=$formattedDate');

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