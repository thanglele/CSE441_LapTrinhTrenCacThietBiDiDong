// File: lib/models/schedule_session_dto.dart

/*
  Model này đã được sửa để khớp với Schema 'ScheduleSessionDto'
  (là một phần của 'LecturerDashboardDto'
  từ API GET /api/v1/lecturer/dashboard)
*/
class ScheduleSession {
  final int classSessionId;
  final String className;
  final String sessionTitle;
  final DateTime startTime; // C# DateTime -> Dart DateTime
  final DateTime endTime;
  final String location;
  final String attendanceStatus; // (VD: "pending", "in_progress", "completed")

  ScheduleSession({
    required this.classSessionId,
    required this.className,
    required this.sessionTitle,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.attendanceStatus,
  });

  // Hàm Factory để giải mã (parse) JSON từ API
  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      classSessionId: json['classSessionId'] as int,
      className: json['className'] as String,
      sessionTitle: json['sessionTitle'] as String,

      // API trả về Chuỗi (String) ISO 8601 (VD: "2025-11-07T08:00:00"),
      // chúng ta cần parse (chuyển) nó sang DateTime
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),

      location: json['location'] as String,
      attendanceStatus: json['attendanceStatus'] as String,
    );
  }
}