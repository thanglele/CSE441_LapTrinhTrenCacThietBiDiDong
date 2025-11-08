import 'dart:async'; // <-- Thêm dòng này
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mytlu/core/errors/exceptions.dart'; // File exception của bạn
import '../models/check_in_request_model.dart';
import '../models/check_in_response_model.dart';

class CheckInService {
  final String _baseUrl = "https://mytlu.thanglele.cloud/api/v1";
  final int _timeoutInSeconds = 20; // Tăng thời gian chờ cho việc upload ảnh

  /// Gọi API điểm danh
  Future<CheckInResponse> checkInStudent(CheckInRequest request, String token) async {
    final url = Uri.parse('$_baseUrl/attendance/check-in');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token', // <-- SỬ DỤNG TOKEN
          'Content-Type': 'application/json',
          'accept': 'text/plain', // Theo curl
        },
        body: jsonEncode(request.toJson()), // Gửi request model
      ).timeout(Duration(seconds: _timeoutInSeconds));

      // Giải mã response
      final responseBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // Thành công, trả về model response
        return CheckInResponse.fromJson(responseData);
      } else {
        // Thất bại, ném ra ApiException để UI (FaceRecognitionScreen) bắt
        throw ApiException(
          statusCode: response.statusCode,
          message: responseData['message'] ?? 'Lỗi không xác định từ server.',
        );
      }
    } on SocketException {
      throw ApiException(statusCode: 503, message: "Lỗi kết nối mạng. Vui lòng kiểm tra lại.");
    } on TimeoutException {
       throw ApiException(statusCode: 408, message: "Hết thời gian chờ xử lý. Vui lòng thử lại.");
    } on http.ClientException {
      throw ApiException(statusCode: 503, message: "Lỗi kết nối tới máy chủ.");
    } catch (e) {
      // Bắt lại lỗi từ 'throw ApiException'
      if (e is ApiException) rethrow; 
      // Bắt các lỗi khác (như parsing JSON)
      throw ApiException(statusCode: 500, message: "Lỗi xử lý dữ liệu: ${e.toString()}");
    }
  }
}