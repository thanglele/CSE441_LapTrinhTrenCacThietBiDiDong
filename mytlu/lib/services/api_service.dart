import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';

class ApiService {
  // Thay thế bằng URL Backend .NET Core của bạn
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
}