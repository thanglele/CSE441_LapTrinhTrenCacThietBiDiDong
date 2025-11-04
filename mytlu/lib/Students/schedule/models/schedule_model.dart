import 'dart:convert';

// Hàm helper để parse danh sách JSON
List<ScheduleModel> scheduleModelFromJson(String str) => List<ScheduleModel>.from(json.decode(str).map((x) => ScheduleModel.fromJson(x)));

/// Model này khớp với DTO (MyScheduleDto)
/// mà API (GET /my-schedule-by-date) trả về (phiên bản CHƯA CÓ sessionStatus)
class ScheduleModel {
  final int classSessionId;
  final String className;
  final String sessionTitle;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String attendanceStatus; // pending, present, late, absent

  ScheduleModel({
    required this.classSessionId,
    required this.className,
    required this.sessionTitle,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.attendanceStatus,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      classSessionId: json["classSessionId"] ?? 0,
      className: json["className"] ?? "N/A",
      sessionTitle: json["sessionTitle"] ?? "N/A",
      startTime: DateTime.tryParse(json["startTime"] ?? "") ?? DateTime.now(),
      endTime: DateTime.tryParse(json["endTime"] ?? "") ?? DateTime.now(),
      location: json["location"] ?? "N/A",
      attendanceStatus: json["attendanceStatus"] ?? "pending",
      // (Đã xóa sessionStatus vì API chưa có)
    );
  }
}

