// lib/models/session_data.dart

class SessionData {
  final int id;
  final String className;
  final String title;
  final String startTime;
  final String endTime;
  final String location;
  final String sessionStatus;
  final String? lecturerName;

  SessionData({
    required this.id,
    required this.className,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.sessionStatus,
    this.lecturerName,
  });

  /// Tạo từ JSON (API trả về)
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json['id'] ?? 0,
      className: json['className'] ?? '',
      title: json['title'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      sessionStatus: json['sessionStatus'] ?? '',
      lecturerName: json['lecturerName'],
    );
  }

  /// Chuyển sang JSON (nếu cần gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'sessionStatus': sessionStatus,
      'lecturerName': lecturerName,
    };
  }

  /// **PHẦN THÊM MỚI**
  /// Tạo một bản sao của đối tượng với các trường được cập nhật.
  SessionData copyWith({
    int? id,
    String? className,
    String? title,
    String? startTime,
    String? endTime,
    String? location,
    String? sessionStatus,
    String? lecturerName,
  }) {
    return SessionData(
      id: id ?? this.id,
      className: className ?? this.className,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      lecturerName: lecturerName ?? this.lecturerName,
    );
  }
}