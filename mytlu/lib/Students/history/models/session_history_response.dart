import 'dart:convert';

// Hàm helper để parse JSON
PaginatedSessionHistoryResponse paginatedSessionHistoryResponseFromJson(String str) =>
    PaginatedSessionHistoryResponse.fromJson(json.decode(str));

/// Mô hình cho toàn bộ phản hồi API, bao gồm cả phân trang
class PaginatedSessionHistoryResponse {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final List<SessionHistoryItem> sessions;

  PaginatedSessionHistoryResponse({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.sessions,
  });

  factory PaginatedSessionHistoryResponse.fromJson(Map<String, dynamic> json) =>
      PaginatedSessionHistoryResponse(
        page: json["page"],
        pageSize: json["pageSize"],
        totalCount: json["totalCount"],
        totalPages: json["totalPages"],
        sessions: List<SessionHistoryItem>.from(
            json["sessions"].map((x) => SessionHistoryItem.fromJson(x))),
      );
}

/// Mô hình cho một mục (session) trong lịch sử
class SessionHistoryItem {
  final int classSessionId;
  final String sessionTitle;
  final String classCode;
  final String className;
  final String lecturerName;
  final DateTime sessionStart;
  final String sessionStatus; // "completed", "in_progress", "scheduled"
  final int totalEnrolled;
  final int totalPresent;

  SessionHistoryItem({
    required this.classSessionId,
    required this.sessionTitle,
    required this.classCode,
    required this.className,
    required this.lecturerName,
    required this.sessionStart,
    required this.sessionStatus,
    required this.totalEnrolled,
    required this.totalPresent,
  });

  factory SessionHistoryItem.fromJson(Map<String, dynamic> json) =>
      SessionHistoryItem(
        classSessionId: json["classSessionId"],
        sessionTitle: json["sessionTitle"],
        classCode: json["classCode"],
        className: json["className"],
        lecturerName: json["lecturerName"],
        // Parse chuỗi thời gian thành đối tượng DateTime
        sessionStart: DateTime.parse(json["sessionStart"]),
        sessionStatus: json["sessionStatus"],
        totalEnrolled: json["totalEnrolled"],
        totalPresent: json["totalPresent"],
      );
}