// File: lib/models/student_model.dart

class Student {
  final String id;
  final String name;
  final String className;
  final String imageUrl;
  final bool isRegistered; // true = Đã đăng ký, false = Chưa

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.imageUrl,
    required this.isRegistered,
  });

  // ====================================================================
  // <<< THÊM CONSTRUCTOR fromJson BỊ THIẾU VÀO ĐÂY >>>
  // ====================================================================
  factory Student.fromJson(Map<String, dynamic> json) {
    // LƯU Ý: Điều chỉnh các key JSON ('studentCode', 'fullName', etc.)
    // để khớp CHÍNH XÁC với phản hồi từ API /lecturer/classes/{classCode}/students

    return Student(
      id: json['studentCode'] as String,
      name: json['fullName'] as String,
      className: json['className'] as String,
      // Giả định key là 'profilePhotoUrl' và xử lý nếu giá trị là null/empty string
      imageUrl: json['profilePhotoUrl'] ?? '',
      // Giả định key là 'faceRegistered' (trạng thái đã đăng ký khuôn mặt)
      isRegistered: json['faceRegistered'] as bool,
    );
  }
}