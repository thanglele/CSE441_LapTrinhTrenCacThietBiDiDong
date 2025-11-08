import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:async'; // Dùng cho Timeout

import 'package:mytlu/config/api_config.dart';
import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/core/errors/exceptions.dart'; // Sử dụng Custom Exception
import '../models/face_upload_response_model.dart';

// Giả định bạn có ApiService chứa hàm postRequest chung
// Nếu FaceUploadService là API Service chính, bạn giữ nguyên.

class FaceUploadService {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Thực hiện đăng ký khuôn mặt (Luồng 2) bằng cách gửi ảnh Live Selfie Base64.
  /// Ảnh: File ảnh đã được chụp (3D/Live).
  Future<FaceUploadResponseModel> uploadFaceData({
    required File imageFile,
  }) async {
    const String endpoint = '/api/v1/enrollment/upload';
    final String url = '$_baseUrl$endpoint';

    // LẤY TOKEN (Sử dụng cách gọn nhất)
    final String? token = await UserSession().getToken();

    if (token == null) {
      throw Exception("Lỗi xác thực: Không tìm thấy Token đăng nhập.");
    }

    // 1. Đọc file và chuyển đổi sang Base64
    final bytes = await imageFile.readAsBytes();
    final String? mimeType = lookupMimeType(imageFile.path);

    if (mimeType == null) {
      // Dùng ApiException nếu bạn có class này
      throw Exception("Lỗi định dạng file: Không thể xác định loại MIME.");
    }

    final String base64String = base64Encode(bytes);

    // 2. TẠO DATA URI: Bắt buộc phải có tiền tố "data:mime/type;base64,"
    final String liveSelfieBase64 = "data:$mimeType;base64,$base64String";

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {
      'liveSelfieBase64': liveSelfieBase64,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 20)); // Thêm timeout an toàn

      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // Trả về { "uploadStatus": "verified" } hoặc { "uploadStatus": "uploaded" }
        return FaceUploadResponseModel.fromJson(responseBody);
      } else if (response.statusCode == 400) {
        // Lỗi 400 (Ví dụ: "Hồ sơ sinh trắc học gốc chưa được tạo.")
        throw Exception(responseBody['message'] ?? "Lỗi: Bad Request.");
      } else if (response.statusCode == 401) {
        // Lỗi 401
        throw Exception("Lỗi xác thực: Token không hợp lệ hoặc đã hết hạn.");
      } else {
        throw Exception("Lỗi máy chủ: ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("Lỗi kết nối: Yêu cầu bị hết thời gian chờ (20s).");
    } on SocketException {
      throw Exception("Lỗi kết nối mạng: Không có Internet hoặc máy chủ đang ngoại tuyến.");
    } catch (e) {
      // Bắt lỗi mạng hoặc lỗi từ services
      throw Exception("Lỗi kết nối API Upload: ${e.toString()}");
    }
  }
}