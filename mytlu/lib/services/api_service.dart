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

  // ==========================================================
  // === BẮT ĐẦU: HÀM POST BỊ THIẾU MÀ BẠN CẦN THÊM ===
  // (Dùng cho 'start-attendance' của Giảng viên)
  // ==========================================================
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
  // ==========================================================
  // === KẾT THÚC: HÀM POST BỊ THIẾU ===
  // ==========================================================


  /// === HÀM XỬ LÝ PHẢN HỒI (Private) ===
  /// (Bạn cũng cần thêm hàm này nếu chưa có)
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
    } catch (e) {
      errorMessage = response.body.isEmpty ? errorMessage : response.body;
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }
}