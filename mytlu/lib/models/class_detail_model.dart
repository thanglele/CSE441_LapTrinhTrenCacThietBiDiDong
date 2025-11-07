// File: lib/models/class_detail_model.dart

class ClassDetail {
  final String classCode;
  final String subjectCode;
  final String academicYear;
  final String room;
  final String type;
  final int studentCount;

  ClassDetail({
    required this.classCode,
    required this.subjectCode,
    required this.academicYear,
    required this.room,
    required this.type,
    required this.studentCount,
  });

  // ====================================================================
  // <<< PHƯƠNG THỨC BẮT BUỘC ĐỂ KHẮC PHỤC LỖI fromJson >>>
  // ====================================================================
  factory ClassDetail.fromJson(Map<String, dynamic> json) {
    // Các key JSON phải khớp CHÍNH XÁC với API /lecturer/my-classes

    return ClassDetail(
      classCode: json['classCode'] as String,
      subjectCode: json['subjectCode'] as String,
      academicYear: json['academicYear'] as String,
      room: json['roomName'] as String, // Giả định key là roomName
      type: json['classType'] as String, // Giả định key là classType
      // Sử dụng num.toInt() để xử lý các giá trị số có thể là int hoặc double
      studentCount: (json['studentCount'] as num).toInt(),
    );
  }
}