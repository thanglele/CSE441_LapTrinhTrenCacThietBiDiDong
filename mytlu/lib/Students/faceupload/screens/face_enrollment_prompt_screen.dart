// ignore_for_file: file_names

import 'package:flutter/material.dart';
// import 'face_scan_screen.dart'; // Không cần import vì AuthWrapperScreen quản lý việc chuyển đổi.

/// Đây LÀ WIDGET NỘI DUNG (giữa màn hình)
/// Widget này nhận một callback để chuyển trạng thái sang Scan.
class FaceEnrollmentPromptScreen extends StatelessWidget {
  // ✅ Tham số callback để khi nhấn nút, nó kích hoạt chuyển trạng thái ở AuthWrapperScreen.
  final VoidCallback onEnrollPressed;

  const FaceEnrollmentPromptScreen({super.key, required this.onEnrollPressed}); // ✅ BẮT BUỘC: onEnrollPressed

  // Widget con để hiển thị 1 dòng thông tin
  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor, // Dùng màu xanh
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54, // Chữ màu xám
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    // Dùng Theme.of(context) để lấy màu xanh TLU Blue từ theme
    final Color tluBlue = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 4,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Bạn cần phải đăng ký nhận diện khuôn mặt",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            const Icon(
              Icons.face_unlock_outlined,
              size: 100,
              color: Colors.black54,
            ),
            const SizedBox(height: 32),

            // Các dòng thông tin (icon màu xanh)
            _buildInfoRow(
              Icons.visibility_off_outlined,
              "Không dùng kính, khẩu trang... các phụ kiện che mặt",
              tluBlue,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.wb_sunny_outlined,
              "Hãy nhận diện khuôn mặt của bạn ở nơi có ánh sáng tốt",
              tluBlue,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.shield_outlined,
              "Thiết bị sẽ truy cập camera và bắt đầu thực hiện nhận diện khuôn mặt của bạn",
              tluBlue,
            ),

            const SizedBox(height: 40),

            // Nút bấm (Gradient)
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tluBlue, Color.lerp(tluBlue, Colors.blueAccent, 0.5)!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: tluBlue.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
              ),
              child: ElevatedButton(
                // ✅ GỌI HÀM CALLBACK TỪ MÀN HÌNH CHA
                onPressed: onEnrollPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Nút trong suốt để thấy gradient
                  shadowColor: Colors.transparent, // Bỏ shadow
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  "Đăng ký",
                  style: TextStyle(color: Colors.white), // Chữ trắng
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}