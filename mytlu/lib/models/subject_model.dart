// lib/models/subject_model.dart

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

  // 1. Dạy cho Dart cách so sánh 2 Subject
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subject &&
        other.name == name &&
        other.code == code &&
        other.credits == credits &&
        other.classCount == classCount;
  }

  // 2. Dạy cho Dart cách băm (hash) Subject
  @override
  int get hashCode {
    return name.hashCode ^
    code.hashCode ^
    credits.hashCode ^
    classCount.hashCode;
  }
// === KẾT THÚC PHẦN DÁN THÊM ===
}