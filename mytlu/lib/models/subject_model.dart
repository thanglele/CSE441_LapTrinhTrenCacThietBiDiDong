// File: lib/models/subject_model.dart

class Subject {
  final String name;
  final String code;
  final int credits;
  final int classCount;

  Subject({
    required this.name,
    required this.code,
    required this.credits,
    required this.classCount,
  });

  // ====================================================================
  // <<< THÊM CONSTRUCTOR fromJson BỊ THIẾU VÀO ĐÂY >>>
  // ====================================================================
  factory Subject.fromJson(Map<String, dynamic> json) {
    // LƯU Ý: Điều chỉnh các key JSON ('subjectName', 'credits', etc.)
    // để khớp CHÍNH XÁC với API /api/v1/lecturer/my-subjects

    return Subject(
      name: json['subjectName'] as String,
      code: json['subjectCode'] as String,
      // API có thể trả về Credits dưới dạng số (num), ta cần chuyển sang int
      credits: (json['credits'] as num).toInt(),
      // Giả định API tính toán và trả về số lớp
      classCount: json['classCount'] as int,
    );
  }
  // ====================================================================


  // 1. Dạy cho Dart cách so sánh 2 Subject (Đã có)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subject &&
        other.code == code; // Chỉ cần so sánh mã code là đủ để xác định sự độc nhất
  }

  // 2. Dạy cho Dart cách băm (hash) Subject (Đã có)
  @override
  int get hashCode {
    return code.hashCode; // Chỉ cần băm theo code là đủ
  }
}