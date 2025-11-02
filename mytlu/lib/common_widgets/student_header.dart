import 'package:flutter/material.dart';

/// Đây là Header "động" dùng chung cho các màn hình của Sinh viên.
/// Nó yêu cầu "cha" của nó (ví dụ: StudentDashboard)
/// phải cung cấp thông tin sinh viên để hiển thị.
class StudentHeader extends StatelessWidget {
  // 1. ĐỊNH NGHĨA CÁC THAM SỐ ĐẦU VÀO
  final String studentCode;
  final String fullName;
  final String? avatarUrl; // String? (có thể null, nên ta dùng '?' )

  // 2. YÊU CẦU TRUYỀN CÁC THAM SỐ NÀY KHI GỌI WIDGET
  // (Sử dụng cú pháp super.key để tránh cảnh báo)
  const StudentHeader({
    super.key,
    required this.studentCode,
    required this.fullName,
    this.avatarUrl, // avatarUrl là tùy chọn, không bắt buộc
  });

  @override
  Widget build(BuildContext context) {
    // Container này dùng màu #407CDC và font Ubuntu (từ AppTheme)
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF407CDC), // Màu #407CDC
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      // SafeArea để đảm bảo nội dung không bị che bởi tai thỏ/thanh trạng thái
      child: SafeArea(
        bottom: false, // Chỉ áp dụng padding an toàn cho phần top
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Điều chỉnh padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cột chứa tiêu đề và thông tin sinh viên
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "My TLU",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ubuntu',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // 3. SỬ DỤNG DỮ LIỆU ĐỘNG ĐƯỢC TRUYỀN VÀO
                  Text(
                    "MSV: $studentCode", // <-- Lấy từ biến
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9), // Hơi mờ đi
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                  Text(
                    fullName, // <-- Lấy từ biến
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Biểu tượng thông báo + avatar
              Row(
                children: [
                  const Icon(Icons.notifications_none,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 16),

                  // 4. XỬ LÝ LOGIC HIỂN THỊ AVATAR
                  CircleAvatar(
                    radius: 16, // Kích thước avatar
                    backgroundColor: Colors.white24, // Màu nền khi chờ tải

                    // Nếu avatarUrl CÓ GIÁ TRỊ VÀ KHÔNG RỖNG -> dùng NetworkImage
                    backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? NetworkImage(avatarUrl!)
                        : null, // Nếu không, để là null

                    // Nếu backgroundImage là null (tức là không có ảnh)
                    // -> Hiển thị icon thay thế
                    child: (avatarUrl == null || avatarUrl!.isEmpty)
                        ? Icon(
                      Icons.person_outline, // Icon avatar phù hợp
                      size: 20, // Kích thước icon
                      color: Colors.white70,
                    )
                        : null, // Nếu có ảnh thì không cần child
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}