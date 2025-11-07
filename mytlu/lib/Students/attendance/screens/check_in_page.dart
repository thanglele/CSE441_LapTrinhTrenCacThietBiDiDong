import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mytlu/Students/attendance/services/attendance_service.dart';
import 'package:mytlu/Students/theme/app_theme.dart';
import 'package:mytlu/services/user_session.dart';
//import 'package:mytlu/Students/attendance/screens/attendance_title.dart';

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
      _countdown = 5;
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

      // Chuyển sang màn hình nhận diện khuôn mặt
      // if (!mounted) return;
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => AttendanceTitleScreen(
      //       sessionId: sessionId,
      //       qrToken: qrToken,
      //       onBack: _resetScan,
      //     ),
      //   ),
      // );
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
      _countdown = 5;
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

  Widget _buildTitleBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => widget.onSwitchTab?.call(0),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Quét mã QR buổi học",
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCameraFrame() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
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
              const Text(
                "Tìm kiếm mã QR",
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Đưa mã QR truy cập điểm danh của bạn vào trong khung hình ở dưới",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _cameraGranted
                          ? MobileScanner(
                        controller: _scannerController,
                        fit: BoxFit.cover,
                        onDetect: _handleDetect,
                      )
                          : Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Text(
                            "Chưa có quyền Camera",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF16A34A), width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    if (_isCounting)
                      Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$_countdown",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Giữ yên 5 giây trong khi chúng tôi xác nhận mã QR truy cập trang điểm danh của bạn...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  _scannerController.stop(); // Dừng camera
                  widget.onSwitchTab?.call(0); // Quay về tab Lịch học
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
            _buildTitleBar(),
            const SizedBox(height: 10),
            _buildCameraFrame(),
          ],
        ),
      ),
    );
  }
}
