import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mytlu/Students/attendance/services/attendance_service.dart';
import 'package:mytlu/Students/theme/app_theme.dart';
import 'package:mytlu/services/user_session.dart';

// Import 2 file widget mới
import 'package:mytlu/Students/attendance/widgets/qr_title_bar.dart';
import 'package:mytlu/Students/attendance/widgets/qr_camera_frame.dart';

// === THÊM IMPORT NÀY VÀO ===
// Đây là màn hình "Chuẩn bị nhận diện" mà bạn muốn chuyển đến
import 'package:mytlu/Students/attendance/screens/attendance_title_screen.dart';

class ScanQRScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;
  const ScanQRScreen({super.key, this.onSwitchTab});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen>
    with AutomaticKeepAliveClientMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  // ignore: unused_field
  final UserSession _userSession = UserSession();
  // ignore: unused_field
  final CheckInService _checkInService = CheckInService();
  // ignore: unused_field
  final ImagePicker _picker = ImagePicker();

  bool _cameraGranted = false;
  bool _isScanning = true;
  bool _isCounting = false;
  int _countdown = 3;
  Timer? _timer;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    _ensureCameraPermission();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (!mounted) return;
      setState(() => _cameraGranted = true);
      _scannerController.start();
      return;
    }

    final result = await Permission.camera.request();
    if (!mounted) return;
    if (result.isGranted) {
      setState(() => _cameraGranted = true);
      _scannerController.start();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần cấp quyền camera để quét mã QR.')),
      );
    }
  }

  void _handleDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = false;
      _scannedData = code;
      _isCounting = true;
      _countdown = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        _finishScan();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _finishScan() async {
    setState(() => _isCounting = false);

    try {
      final jsonData = jsonDecode(_scannedData!);
      final sessionId = jsonData['sessionId'].toString();
      final qrToken = jsonData['qrToken'].toString();

      if (sessionId.isEmpty || qrToken.isEmpty) {
        _showResultDialog(success: false, message: "QR không hợp lệ!");
        _resetScan();
        return;
      }

      // Dừng camera trước khi chuyển màn hình
      _scannerController.stop();

      // === BẠN BỊ THIẾU ĐOẠN CODE NÀY ===
      // Chuyển sang màn hình nhận diện khuôn mặt
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AttendanceTitleScreen(
            sessionId: sessionId,
            qrToken: qrToken,
            onBack: _resetScan,
          ),
        ),
      );
      // === KẾT THÚC PHẦN BỊ THIẾU ===

    } catch (e) {
      _showResultDialog(success: false, message: "Lỗi khi xử lý QR: $e");
      _resetScan();
    }
  }

  void _resetScan() {
    _timer?.cancel();
    setState(() {
      _isScanning = true;
      _isCounting = false;
      _countdown = 3;
      _scannedData = null;
    });
    if (_cameraGranted) _scannerController.start();
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(success ? "🎉 Thành công" : "⚠️ Thất bại"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetScan();
            },
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- GỌI WIDGET MỚI ---
            QrTitleBar(
              onBackPress: () => widget.onSwitchTab?.call(0),
            ),
            const SizedBox(height: 10),
            // --- GỌI WIDGET MỚI ---
            QrCameraFrame(
              cameraGranted: _cameraGranted,
              scannerController: _scannerController,
              onDetect: _handleDetect,
              isCounting: _isCounting,
              countdown: _countdown,
              onCancel: () {
                _scannerController.stop(); // Dừng camera
                widget.onSwitchTab?.call(0); // Quay về tab Lịch học
              },
            ),
          ],
        ),
      ),
    );
  }
}