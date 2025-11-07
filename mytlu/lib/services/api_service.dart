// File: lib/services/api_service.dart

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Import chung
import '../config/api_config.dart';
import '../models/class_detail_model.dart';
import '../models/schedule_session_dto.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/core/errors/exceptions.dart';
import '../models/class_model.dart'; // Import từ đồng đội

class ApiService {
  // ==== CẤU HÌNH CƠ BẢN ====
  static const String _apiPath = '/api/v1';
  static const int _timeoutInSeconds = 20;

  final UserSession _userSession = UserSession();

  // ==========================
  // === HÀM GET CHUNG ===
  // ==========================
  /// Dùng cho ProfileService, v.v...
  Future<http.Response> getRequest(String endpoint) async {
    final token = await _userSession.getToken();
    if (token == null) {
      throw ApiException(message: 'Token not found. User is not logged in.', statusCode: 401);
    }

    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: _timeoutInSeconds));

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out.', statusCode: 504);
    } on SocketException {
      throw ApiException(message: 'No Internet or server is down.', statusCode: 503);
    } catch (e) {
      throw ApiException(message: 'An unknown error occurred: $e', statusCode: 0);
    }
  }

  // ==========================
  // === HÀM POST CHUNG ===
  // ==========================
  /// Dùng cho FaceUploadService, start-attendance, check-in...
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    final token = await _userSession.getToken();
    if (token == null) {
      throw ApiException(message: 'Token not found. User is not logged in.', statusCode: 401);
    }

    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: _timeoutInSeconds));

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out.', statusCode: 504);
    } on SocketException {
      throw ApiException(message: 'No Internet or server is down.', statusCode: 503);
    } catch (e) {
      throw ApiException(message: 'An unknown error occurred: $e', statusCode: 0);
    }
  }

  // ================================
  // === HÀM XỬ LÝ PHẢN HỒI CHUNG ===
  // ================================
  http.Response _handleResponse(http.Response response) {
    // 2xx: Thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // 4xx, 5xx: Thất bại
    String errorMessage = 'An error occurred.';
    try {
      final responseBody = json.decode(response.body);
      errorMessage = responseBody['message'] ?? errorMessage;
    } on FormatException {
      errorMessage = response.body.isEmpty ? errorMessage : response.body;
    } catch (_) {
      errorMessage = response.body.isEmpty ? errorMessage : response.body;
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }

  // ==========================
  // === API CỤ THỂ CŨ ===
  // ==========================

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
        return jsonList.map((json) => ClassDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load classes. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }

  Future<List<Subject>> fetchAllMySubjects(String jwtToken) async {
    return fetchMySubjects(jwtToken);
  }

  Future<List<Student>> fetchStudentsInClass(String classCode, String jwtToken) async {
    const String _apiPath = '/api/v1'; // giữ nguyên trùng khai báo
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
        return jsonList.map((json) => Student.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403: Bạn không có quyền truy cập danh sách sinh viên.');
      } else {
        throw Exception('Failed to load students. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }

  Future<List<ScheduleSession>> fetchTodayClasses(String jwtToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_apiPath/lecturer/dashboard');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List jsonList = data['todaySessions'] as List;
        return jsonList.map((json) => ScheduleSession.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Failed to load schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<ScheduleSession>> fetchScheduleByDate(String jwtToken, DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse(
      '${ApiConfig.baseUrl}$_apiPath/lecturer/my-schedule-by-date?selectedDate=$formattedDate',
    );

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
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn.');
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Lỗi không xác định khi bắt đầu điểm danh.';
        throw Exception(
          'Failed to start attendance. Status: ${response.statusCode}. Lỗi: $errorMessage',
        );
      }
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: $e');
    }
  }
}
