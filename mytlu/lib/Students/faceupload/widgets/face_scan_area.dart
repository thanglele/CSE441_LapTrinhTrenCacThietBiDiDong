// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// Widget hiển thị khu vực Camera Live hình tròn cho màn hình FaceScanScreen.
class FaceScanArea extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;
  final bool isFaceDetected;

  const FaceScanArea({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.isFaceDetected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || controller == null) {
      // Hiển thị khung chờ khi camera chưa sẵn sàng
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent, width: 4),
          color: Colors.grey.shade300,
        ),
        child: const Center(
          child: Text("Đang khởi tạo...", style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    // Màu viền thay đổi tùy theo trạng thái nhận diện
    final Color borderColor = isFaceDetected ? Colors.green.shade500 : Colors.blueAccent;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 300 * scale,
                    height: 300 * scale,
                    child: CameraPreview(controller!),
                  ),
                ),
              ),
            ),
          ),
          // Text "Camera hoạt động" (Overlay)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Màu nền #DCFCE7
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 5),
                    Text(
                      "Camera hoạt động",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}