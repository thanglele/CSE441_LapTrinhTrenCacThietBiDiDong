import 'dart:convert';
import 'dart:async'; // Timeout
import 'dart:io';    //  SocketException (lỗi mạng)
import 'package:http/http.dart' as http;

// Import code của đồng đội (Giảng viên)
import '../models/class_model.dart';

// Import các file chung
import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/config/api_config.dart';

// Import file Lỗi tùy chỉnh
import 'package:mytlu/core/errors/exceptions.dart';

class ApiService {
  final UserSession _userSession = UserSession();
  static const int _timeoutInSeconds = 15; // Thời gian chờ (15 giây)

  // --- PHẦN CODE CŨ CỦA ĐỒNG ĐỘI (Giữ nguyên) ---
  static const String _baseUrl = 'https://your-dotnet-api.com/api/lecturer';
  Future<List<ClassModel>> fetchTodayClasses(String lecturerId, String jwtToken) async {
    // (Toàn bộ code của hàm này... GIỮ NGUYÊN)
    throw UnimplementedError(); // (Placeholder)
  }
  // --- KẾT THÚC PHẦN CODE CỦA ĐỒNG ĐỘI ---


  /// === HÀM GET CHUNG ===
  /// (Dùng cho ProfileService)
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

  /// === HÀM POST CHUNG ===
  /// (Dùng cho FaceUploadService, start-attendance, check-in...)
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


  /// === HÀM XỬ LÝ PHẢN HỒI (Private) ===
  http.Response _handleResponse(http.Response response) {
    // 2xx: Thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // 4xx, 5xx: Thất bại
    String errorMessage = 'An error occurred.';
    try {
      final responseBody = json.decode(response.body);
      // Cố gắng lấy message từ body response
      errorMessage = responseBody['message'] ?? errorMessage;
    } on FormatException {
      // Nếu body không phải JSON
      errorMessage = response.body.isEmpty ? errorMessage : response.body;
    } catch (e) {
      // Lỗi không xác định
      errorMessage = response.body.isEmpty ? errorMessage : response.body;
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }
}