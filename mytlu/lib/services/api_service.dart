import 'dart:convert';
import 'dart:async'; // Timeout
import 'dart:io';    //  SocketException (lỗi mạng)
import 'package:http/http.dart' as http;


import '../models/class_model.dart';


import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/config/api_config.dart';

import 'package:mytlu/core/errors/exceptions.dart';

class ApiService {
  final UserSession _userSession = UserSession();
  static const int _timeoutInSeconds = 15; // Thời gian chờ (15 giây)


  static const String _baseUrl = 'https://your-dotnet-api.com/api/lecturer';

  // Lưu ý: Cần truyền JWT token trong Header để xác thực

  Future<List<ClassModel>> fetchTodayClasses(String lecturerId, String jwtToken) async {
    final url = Uri.parse('$_baseUrl/today-schedule/$lecturerId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Thêm token xác thực
        },
      );

      if (response.statusCode == 200) {
        // Giải mã JSON
        List jsonList = json.decode(response.body);

        // Chuyển đổi List JSON thành List ClassModel
        return jsonList.map((json) => ClassModel.fromJson(json)).toList();
      } else {
        // Xử lý các mã lỗi HTTP khác (ví dụ: 401 Unauthorized)
        throw Exception('Failed to load schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc lỗi phân tích cú pháp
      throw Exception('Failed to connect to server: $e');
    }
  }


  /// === HÀM GET CHUNG ===
  /// (Dùng cho ProfileService)
  Future<http.Response> getRequest(String endpoint) async {
    final token = await _userSession.getToken();
    if (token == null) {
      // Lỗi 401: Người dùng chưa đăng nhập
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
      ).timeout(const Duration(seconds: _timeoutInSeconds)); //  Xử lý Timeout

      // Gửi response đến hàm xử lý chung
      return _handleResponse(response);

    } on TimeoutException {
      // Lỗi 504: Hết thời gian chờ
      throw ApiException(message: 'Connection timed out. Please try again.', statusCode: 504);
    } on SocketException {
      // Lỗi 503: Lỗi mạng (mất internet) hoặc server sập
      throw ApiException(message: 'No Internet connection or server is down.', statusCode: 503);
    } catch (e) {
      // Các lỗi khác
      throw ApiException(message: 'An unknown error occurred: $e', statusCode: 0);
    }
  }

  /// === HÀM XỬ LÝ PHẢN HỒI (Private) ===
  /// Kiểm tra status code và ném ra lỗi tùy chỉnh nếu thất bại
  http.Response _handleResponse(http.Response response) {
    // 2xx: Thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // 4xx, 5xx: Thất bại
    // Cố gắng đọc thông báo lỗi từ body của API
    String errorMessage = 'An error occurred. Please try again.';
    try {
      final responseBody = json.decode(response.body);
      errorMessage = responseBody['message'] ?? errorMessage;
    } catch (e) {
      // Nếu body không phải JSON hoặc không có 'message'
      errorMessage = response.body.isEmpty ? errorMessage : response.body;
    }

    // Ném ra lỗi tùy chỉnh với status code
    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }
}