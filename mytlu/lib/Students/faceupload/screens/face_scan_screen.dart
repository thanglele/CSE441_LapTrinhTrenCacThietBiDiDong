// ignore_for_file: file_names, use_build_context_synchronously, unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/widgets.dart';

import 'face_review_screen.dart'; // Màn hình xem lại ảnh
import '../widgets/face_scan_area.dart'; // ✅ IMPORT WIDGET MỚI

// Danh sách camera toàn cục (để tránh gọi availableCameras nhiều lần)
List<CameraDescription>? _cameras;

class FaceScanScreen extends StatefulWidget {
  final VoidCallback onCompleted;
  const FaceScanScreen({super.key, required this.onCompleted});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose(); // Đảm bảo dispose controller
    super.dispose();
  }

  /// Khởi tạo camera và xin quyền truy cập
  Future<void> _initializeCamera() async {
    if (!await _requestCameraPermission()) {
      // Nếu không có quyền, thoát màn hình
      widget.onCompleted();
      return;
    }

    try {
      _cameras ??= await availableCameras(); // Lấy danh sách camera

      final frontCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first, // Mặc định là camera đầu tiên nếu không tìm thấy
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Độ phân giải vừa đủ
        enableAudio: false, // Không cần âm thanh
      );

      await _controller!.initialize(); // Khởi tạo controller

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Camera initialization error: $e");
      }
      if(mounted) {
        _showErrorSnackBar("Lỗi: Không thể khởi tạo camera. Vui lòng thử lại.");
        widget.onCompleted(); // Quay về màn hình trước
      }
    }
  }

  /// Hàm kiểm tra và yêu cầu quyền Camera
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isDenied || status.isPermanentlyDenied) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quyền Camera bị từ chối. Vui lòng cấp quyền trong Cài đặt.")),
        );
      }
      if (status.isPermanentlyDenied) {
        openAppSettings(); // Mở cài đặt ứng dụng
      }
    }
    return false;
  }

  /// Chụp ảnh và điều hướng sang màn hình Review
  Future<void> _takePictureAndNavigate() async {
    // Chỉ kiểm tra Camera đã sẵn sàng và không đang chụp ảnh
    if (!_isCameraInitialized || _controller!.value.isTakingPicture) {
      _showErrorSnackBar("Camera chưa sẵn sàng hoặc đang bận.");
      return;
    }

    setState(() { _isTakingPicture = true; }); // Đặt trạng thái đang chụp

    try {
      final XFile file = await _controller!.takePicture(); // Chụp ảnh
      final File imageFile = File(file.path); // Chuyển XFile sang File

      if (mounted) {
        // Điều hướng đến màn hình Review và chờ kết quả (bool)
        final bool? reviewResult = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => FaceReviewScreen(imageFile: imageFile),
          ),
        );

        // Nếu ReviewScreen trả về TRUE (người dùng đã xác nhận),
        // thì màn hình này pop và gọi callback hoàn thành.
        if (reviewResult == true) {
          widget.onCompleted();
        }
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi chụp ảnh: ${e.toString()}");
    } finally {
      setState(() { _isTakingPicture = false; }); // Kết thúc trạng thái chụp
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    // FIX: Sử dụng Color hằng số thay vì Colors.redAccent (giải quyết lỗi withOpacity/deprecated)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFE57373)), // Màu đỏ nhạt
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: SỬ DỤNG WillPopScope (Cấu trúc cũ an toàn) để thay thế PopScope đang lỗi
    return PopScope(
      canPop: true, // Cho phép pop màn hình
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        widget.onCompleted();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100, // Màu nền nhẹ nhàng
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // FIX: Dùng withAlpha hoặc Color hằng số
                BoxShadow(
                  color: const Color(0xFF9E9E9E).withAlpha(38),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Nội dung sẽ chiếm ít không gian nhất có thể
              children: [
                const Text(
                  "Chụp ảnh Khuôn mặt",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Đưa khuôn mặt của bạn vào trong khung hình",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // KHU VỰC CAMERA LIVE
                FaceScanArea( // ✅ DÙNG WIDGET ĐÃ TÁCH
                  controller: _controller,
                  isInitialized: _isCameraInitialized,
                  isFaceDetected: false, // Không dùng ML Kit, nên luôn là false
                ),

                const SizedBox(height: 30),

                const Text(
                  "Vui lòng chụp ảnh khuôn mặt thật rõ ràng.", // Thông báo hướng dẫn
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Nút "Chụp ảnh"
                ElevatedButton(
                  onPressed: _isTakingPicture ? null : _takePictureAndNavigate, // ✅ Gọi hàm
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isTakingPicture ? "Đang chụp..." : "Bắt đầu Chụp",
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 15),
                // Nút "Hủy"
                TextButton(
                  onPressed: _isTakingPicture ? null : () => widget.onCompleted(),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Widget _buildFaceScanArea đã được chuyển sang file face_scan_area.dart
}