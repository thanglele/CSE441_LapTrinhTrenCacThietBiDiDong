// lib/models/user_model.dart

class User {
  final String id; // Mã giảng viên, mã sinh viên
  final String fullName;
  final String email;
  final String phone;
  final String department; // Bộ môn
  final String faculty; // Khoa
  final String position; // Chức vụ (Giảng viên, Sinh viên)
  final String academicRank; // Học hàm (GS.TS, ThS...)
  final String officeRoom; // Phòng làm việc
  final String dob; // Ngày sinh
  final String pob; // Nơi sinh (Place of birth)
  final String gender; // Giới tính
  final String address; // Địa chỉ
  final String imageUrl; // URL ảnh đại diện

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.faculty,
    required this.position,
    required this.academicRank,
    required this.officeRoom,
    required this.dob,
    required this.pob,
    required this.gender,
    required this.address,
    required this.imageUrl,
  });
}