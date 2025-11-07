// lib/models/session_data.dart
class SessionData {
  final int id;                   // ID buổi học
  final String classCode;         // Mã lớp học phần
  final String title;             // Tiêu đề buổi học (#1, #2,...)
  final String sessionDate;       // Ngày diễn ra buổi học
  final String startTime;         // Giờ bắt đầu
  final String endTime;           // Giờ kết thúc
  final String sessionLocation;   // Địa điểm học thực tế
  final String qrCodeData;        // Dữ liệu QR (nếu có)
  final String sessionStatus;     // Trạng thái (scheduled, completed,...)

  // Liên kết thêm từ lớp học (class)
  final String? subjectName;      // Tên môn học
  final String? lecturerName;     // Tên giảng viên
  final String? semester;         // Học kỳ
  final String? academicYear;     // Năm học

  SessionData({
    required this.id,
    required this.classCode,
    required this.title,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.sessionLocation,
    required this.qrCodeData,
    required this.sessionStatus,
    this.subjectName,
    this.lecturerName,
    this.semester,
    this.academicYear,
  });

  /// Tạo từ JSON (API trả về)
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json['id'] ?? 0,
      classCode: json['classCode'] ?? '',
      title: json['title'] ?? '',
      sessionDate: json['sessionDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      sessionLocation: json['sessionLocation'] ?? '',
      qrCodeData: json['qrCodeData'] ?? '',
      sessionStatus: json['sessionStatus'] ?? '',
      subjectName: json['subjectName'],    // có thể null
      lecturerName: json['lecturerName'],
      semester: json['semester'],
      academicYear: json['academicYear'],
    );
  }

  /// Chuyển sang JSON (nếu cần gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classCode': classCode,
      'title': title,
      'sessionDate': sessionDate,
      'startTime': startTime,
      'endTime': endTime,
      'sessionLocation': sessionLocation,
      'qrCodeData': qrCodeData,
      'sessionStatus': sessionStatus,
      'subjectName': subjectName,
      'lecturerName': lecturerName,
      'semester': semester,
      'academicYear': academicYear,
    };
  }
}
