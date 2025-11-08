import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mytlu/Students/theme/app_theme.dart';

/// Widget này chỉ chứa UI cho màn hình nhận diện khuôn mặt.
/// Nó nhận toàn bộ trạng thái (state) từ FaceRecognitionScreen.
class FaceRecognitionFrame extends StatelessWidget {
  final Future<void>? initializeControllerFuture;
  final CameraController? cameraController;
  final bool isProcessing;
  final bool isFaceDetected;
  final int countdown;
  final VoidCallback onCancelPress;

  const FaceRecognitionFrame({
    super.key,
    required this.initializeControllerFuture,
    required this.cameraController,
    required this.isProcessing,
    required this.isFaceDetected,
    required this.countdown,
    required this.onCancelPress,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initializeControllerFuture,
      builder: (ctx, snapshot) {
        // Giao diện khi camera chưa sẵn sàng
        if (snapshot.connectionState != ConnectionState.done ||
            cameraController == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Giao diện chính (giống ScanQR)
        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB), // Màu nền thẻ
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TIÊU ĐỀ VÀ CHIP (ĐÃ SỬA)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Nhận diện khuôn mặt",
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    // CHIP "CAMERA HOẠT ĐỘNG" ĐÃ DI CHUYỂN
                    Chip(
                      label: const Text('Camera hoạt động'),
                      backgroundColor: Colors.green.withAlpha(180),
                      labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 2. Hướng dẫn (thay đổi theo trạng thái)
                Text(
                  isFaceDetected
                      ? "Giữ yên khuôn mặt của bạn..."
                      : "Đưa khuôn mặt vào trong khung hình",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Khung Camera (Stack)
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lớp 1: Camera Preview (Hình OVAL)
                      ClipOval(
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CameraPreview(cameraController!),
                        ),
                      ),

                      // Lớp 2: Đếm ngược
                      if (isFaceDetected && !isProcessing)
                        Text(
                          "$countdown",
                          style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 10.0, color: Colors.black45)
                              ]),
                        ),

                      // Lớp 3: Vòng tròn Loading khi gọi API
                      if (isProcessing)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),

                      // LỚP 4: CHIP ĐÃ BỊ XÓA KHỎI ĐÂY
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Text mô tả thêm
                const Text(
                  "Giữ yên khuôn mặt để chúng tôi xác nhận danh tính của bạn...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Nút Hủy
                ElevatedButton(
                  onPressed: isProcessing ? null : onCancelPress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 44), // Full width
                  ),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Ubuntu',
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}