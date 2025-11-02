import 'dart:convert';

StudentProfile studentProfileFromJson(String str) => StudentProfile.fromJson(json.decode(str));


class StudentProfile {
  final String studentCode;
  final String fullName;
  final String adminClass;
  final String majorName;
  final String faceDataStatus;
  final String? avatarUrl; // Thêm trường này (API có thể có hoặc không)

  StudentProfile({
    required this.studentCode,
    required this.fullName,
    required this.adminClass,
    required this.majorName,
    required this.faceDataStatus,
    this.avatarUrl,
  });

  /// Factory này chỉ đọc các trường từ API GET /auth/me
  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentCode: json["studentCode"] ?? 'N/A',
      fullName: json["fullName"] ?? 'N/A',
      adminClass: json["adminClass"] ?? 'N/A',
      majorName: json["majorName"] ?? 'N/A',
      faceDataStatus: json["faceDataStatus"] ?? 'none',
      avatarUrl: json["avatarUrl"], // Sẽ là null nếu API không có
    );
  }
}