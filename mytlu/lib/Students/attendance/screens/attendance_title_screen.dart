import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import thư viện SVG
import 'package:mytlu/Students/theme/app_theme.dart';
import 'package:mytlu/Students/attendance/screens/face_recognition_screen.dart';

class AttendanceTitleScreen extends StatelessWidget {
  final String sessionId;
  final String qrToken;
  final VoidCallback? onBack; // Đây là hàm _resetScan từ ScanQRScreen

  const AttendanceTitleScreen({
    super.key,
    required this.sessionId,
    required this.qrToken,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // --- LOGIC MỚI (1) ---
    // Hàm này được gọi khi FaceRecognitionScreen (màn hình 3) hoàn thành.
    // Nó sẽ đóng TẤT CẢ các màn hình (FaceRec, Title)
    // để quay về màn hình gốc (ScanQR) và gọi _resetScan.
    void handleFaceScanCompletion() {
      // 1. Gọi _resetScan (nếu có)
      // SỬA LỖI: Bỏ 'widget.'
      onBack?.call();
      // 2. Pop về màn hình đầu tiên (ScanQRScreen) của Navigator lồng
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    // --- LOGIC MỚI (2) ---
    // Hàm này được gọi khi nhấn "Hủy" hoặc "Back" trên màn hình Title (màn hình 2).
    // Nó chỉ đóng màn hình Title và gọi _resetScan.
    void handleBackToQR() {
      // 1. Gọi _resetScan (nếu có)
      // SỬA LỖI: Bỏ 'widget.'
      onBack?.call();
      // 2. Pop màn hình hiện tại (AttendanceTitleScreen)
      Navigator.of(context).pop();
    }

    // --- LOGIC MỚI (3) ---
    // Hàm để điều hướng đến màn hình nhận diện (màn hình 3)
    void _navigateToFaceRecognition() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FaceRecognitionScreen(
            sessionId: sessionId, // Truy cập trực tiếp
            qrToken: qrToken, // Truy cập trực tiếp
            onBack: handleFaceScanCompletion,
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
          // Sửa: Dùng logic handleBackToQR
          onPressed: handleBackToQR,
        ),
        backgroundColor: AppTheme.primaryColor, // Áp dụng theme
        elevation: 1,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          // Căn lề trái cho nội dung văn bản
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ICON SVG
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

            // 2. TIÊU ĐỀ
            const Text(
              "Nhận diện khuôn mặt",
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor, // Màu từ theme
              ),
              textAlign: TextAlign.center, // Tiêu đề căn giữa
            ),
            const SizedBox(height: 24),

            // 3. PHỤ ĐỀ MỚI (Căn lề trái - mặc định của Column)
            const Text(
              "Không dùng kính, khẩu trang... các phụ kiện che mặt",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                color: Color(0xFF4B5563), // Màu xám đậm
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hãy nhận diện khuôn mặt của bạn ở nơi có ánh sáng tốt",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                color: Color(0xFF4B5563), // Màu xám đậm
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Thiết bị sẽ truy cập camera và bắt đầu thực hiện nhận diện khuôn mặt của bạn",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                color: Color(0xFF4B5563), // Màu xám đậm
              ),
            ),

            // Xóa văn bản mô tả trùng lặp

            const Spacer(), // Đẩy 2 nút xuống dưới

            // 5. NÚT "THỰC HIỆN"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Sửa: Dùng logic _navigateToFaceRecognition
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
                // Sửa: Dùng logic handleBackToQR
                onPressed: handleBackToQR,
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