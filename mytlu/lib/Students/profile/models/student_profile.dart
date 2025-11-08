import 'dart:convert';
import 'package:intl/intl.dart';

StudentProfile studentProfileFromJson(String str) =>
    StudentProfile.fromJson(json.decode(str));

class StudentProfile {
  final String studentCode;
  final String fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String gender;
  final String adminClass;
  final String majorName;
  final String intakeYear;
  final String email;
  final String phoneNumber;
  final String uploadStatus; // Đã đổi tên từ faceDataStatus
  final Identification? identification;
  final StudentDetails? details;

  StudentProfile({
    required this.studentCode,
    required this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    required this.gender,
    required this.adminClass,
    required this.majorName,
    required this.intakeYear,
    required this.email,
    required this.phoneNumber,
    required this.uploadStatus,
    this.identification,
    this.details,
  });

  /// Logic mới để parse trạng thái từ mảng faceDataHistory
  static String _parseFaceDataStatus(List<dynamic>? historyList) {
    if (historyList == null || historyList.isEmpty) {
      return 'none';
    }
    try {
      // Tìm bản ghi đang active (theo API Trang 4)
      final activeEntry = historyList.firstWhere(
            (entry) => entry['isActive'] == true,
        orElse: () => null,
      );
      if (activeEntry != null) {
        return activeEntry['uploadStatus'] ?? 'none';
      }
      return 'none'; // Không có bản ghi nào active
    } catch (e) {
      return 'none'; // Lỗi parse
    }
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    // Định dạng ngày (API có thể trả về "2002-01-01" hoặc "2002-01-01T00:00:00")
    DateTime? dob;
    if (json["dateOfBirth"] != null) {
      try {
        dob = DateTime.parse(json["dateOfBirth"]);
      } catch (e) {
        dob = null;
      }
    }

    return StudentProfile(
      studentCode: json["studentCode"] ?? 'N/A',
      fullName: json["fullName"] ?? 'N/A',
      avatarUrl: json["avatarUrl"],
      dateOfBirth: dob,
      gender: json["gender"] ?? 'N/A',
      adminClass: json["adminClass"] ?? 'N/A',
      majorName: json["majorName"] ?? 'N/A',
      intakeYear: json["intakeYear"] ?? 'N/A',
      email: json["email"] ?? 'N/A',
      phoneNumber: json["phoneNumber"] ?? 'N/A',
      // SỬA LỖI: Gọi hàm helper mới
      uploadStatus: _parseFaceDataStatus(json["faceDataHistory"]),
      identification: json["identification"] != null
          ? Identification.fromJson(json["identification"])
          : null,
      details: json["details"] != null
          ? StudentDetails.fromJson(json["details"])
          : null,
    );
  }

  // Helper để format ngày sinh
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(dateOfBirth!);
  }
}

/// Chi tiết (API Trang 4, mục "details")
class StudentDetails {
  final String ethnicity;
  final String contactAddress;
  // SỬA LỖI: Đã xóa facultyName (Không có trong API "details" của Student)

  StudentDetails({
    required this.ethnicity,
    required this.contactAddress,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) => StudentDetails(
    ethnicity: json["ethnicity"] ?? 'N/A',
    contactAddress: json["contactAddress"] ?? 'N/A',
  );
}

/// CCCD (API Trang 4, mục "identification")
class Identification {
  final String placeOfBirth;
  final String nationalId;

  Identification({
    required this.placeOfBirth,
    required this.nationalId,
  });

  factory Identification.fromJson(Map<String, dynamic> json) => Identification(
    placeOfBirth: json["placeOfBirth"] ?? 'N/A',
    nationalId: json["nationalId"] ?? 'N/A',
  );
}