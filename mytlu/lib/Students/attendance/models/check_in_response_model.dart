// Model cho response 200
class CheckInResponse {
  final String message;
  final String attendanceStatus;
  final String checkInTime; // Bạn có thể dùng DateTime nếu muốn parse

  CheckInResponse({
    required this.message,
    required this.attendanceStatus,
    required this.checkInTime,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      message: json['message'] ?? '',
      attendanceStatus: json['attendanceStatus'] ?? '',
      checkInTime: json['checkInTime'] ?? '',
    );
  }
}