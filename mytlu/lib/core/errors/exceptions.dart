/// Lớp Exception tùy chỉnh để xử lý các lỗi trả về từ API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'ApiException (Code: $statusCode): $message';
  }
}