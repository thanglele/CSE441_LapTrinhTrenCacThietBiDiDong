import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import thư viện SVG
import 'package:mytlu/Students/theme/app_theme.dart';
import 'package:mytlu/Students/attendance/screens/face_recognition_screen.dart';

class AttendanceTitleScreen extends StatelessWidget {
  final String sessionId;
  final String qrToken;
  final VoidCallback? onBack;

  const AttendanceTitleScreen({
    super.key,
    required this.sessionId,
    required this.qrToken,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Hàm để điều hướng đến màn hình nhận diện
    void _navigateToFaceRecognition() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FaceRecognitionScreen(
            sessionId: sessionId,
            qrToken: qrToken,
            onBack: () {
              // Khi màn hình nhận diện (FaceRecognitionScreen) đóng,
              // nó sẽ gọi hàm onBack này.
              // Chúng ta gọi Navigator.pop(context) ở đây để
              // đóng nốt màn hình "Chuẩn bị" (AttendanceTitleScreen) này.
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng cho nội dung
      appBar: AppBar(
        title: const Text(
          "Nhận diện khuôn mặt",
          style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        backgroundColor: AppTheme.primaryColor, // Áp dụng theme
        elevation: 1,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. ICON SVG MỚI
            SvgPicture.asset(
              'assets/faceid_scan_icon.svg', // Đường dẫn asset
              width: 120,
              height: 120,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 32),

            // 2. TIÊU ĐỀ MỚI
            const Text(
              "Nhận diện khuôn mặt",
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor, // Màu từ theme
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 3. PHỤ ĐỀ 1 MỚI
            const Text(
              "Không dùng kính, khẩu trang... các phụ kiện che mặt",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                color: Color(0xFF4B5563), // Màu xám đậm
              ),
            ),
            const Text(
              "Hãy nhận diện khuôn mặt của bạn ở nơi có ánh sáng tốt",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                color: Color(0xFF4B5563), // Màu xám đậm
              ),
            ),
            const Text(
              "Thiết bị sẽ truy cập camera và bắt đầu thực hiện nhận diện khuôn mặt của bạn",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                color: Color(0xFF4B5563), // Màu xám đậm
              ),
            ),
            const SizedBox(height: 40),

            // 4. PHỤ ĐỀ 2 MỚI (Mô tả)
            const Text(
              "Thiết bị sẽ truy cập camera và bắt đầu thực hiện nhận diện khuôn mặt của bạn.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 14,
                color: Color(0xFF6B7280), // Màu xám nhạt
              ),
            ),
            const Spacer(), // Đẩy 2 nút xuống dưới

            // 5. NÚT "THỰC HIỆN" (VỚI TEXT MỚI)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToFaceRecognition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, // Màu từ theme
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  "Thực hiện",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. NÚT "HỦY"
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onBack,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Hủy",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}