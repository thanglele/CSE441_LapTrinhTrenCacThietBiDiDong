// src/Students/attendance/models/check_in_response_model.dart
import 'dart:convert';

/// Hàm trợ giúp để parse chuỗi JSON thô từ Response thành object CheckInResponse.
CheckInResponse checkInResponseFromJson(String str) => CheckInResponse.fromJson(json.decode(str));

/// Model cho Response Body khi gọi POST /attendance/check-in thành công (200 OK).
/// Nó ánh xạ các trường: message, attendanceStatus, và checkinTime [cite: 321-323].
class CheckInResponse {
  final String message;
  final String attendanceStatus;
  final DateTime checkinTime;

  CheckInResponse({
    required this.message,
    required this.attendanceStatus,
    required this.checkinTime,
  });

  /// Factory constructor để parse Map<String, dynamic> (JSON) thành object CheckInResponse.
  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      message: json["message"] as String, // Ví dụ: "Điểm danh thành công!" [cite: 321]
      attendanceStatus: json["attendanceStatus"] as String, // Ví dụ: "present" [cite: 322]
      checkinTime: DateTime.parse(json["checkinTime"] as String), // Giờ điểm danh (ISO 8601 format) [cite: 323]
    );
  }

  /// Chuyển object thành Map (thường dùng cho debug hoặc lưu trữ cục bộ)
  Map<String, dynamic> toJson() => {
    "message": message,
    "attendanceStatus": attendanceStatus,
    "checkinTime": checkinTime.toIso8601String(),
  };
}