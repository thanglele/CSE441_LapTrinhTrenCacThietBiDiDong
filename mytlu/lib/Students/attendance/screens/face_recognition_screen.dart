import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

// Service và Models
import 'package:mytlu/Students/attendance/services/attendance_service.dart';
import 'package:mytlu/Students/attendance/models/check_in_request_model.dart';
import 'package:mytlu/Students/attendance/models/check_in_response_model.dart';
import 'package:mytlu/core/errors/exceptions.dart';

// Import Widget UI
import 'package:mytlu/Students/attendance/widgets/face_recognition_frame.dart';
// THÊM IMPORT THEME
import 'package:mytlu/Students/theme/app_theme.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final String sessionId;
  final String qrToken;
  final VoidCallback? onBack;

  const FaceRecognitionScreen({
    super.key,
    required this.sessionId,
    required this.qrToken,
    this.onBack,
  });

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  // --- TOÀN BỘ LOGIC GIỮ NGUYÊN ---
  // (initState, dispose, _initializeCamera, _processCameraImage,
  // _startCountdown, _getGpsCoordinates, _captureAndCheckIn,
  // _showResultDialog, _showErrorDialog, _inputImageFromCameraImage)
  // ...
  // ... (Toàn bộ code logic từ file trước của bạn được giữ nguyên ở đây) ...
  // ...
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  late final FaceDetector _faceDetector;
  final CheckInService _checkInService = CheckInService();

  bool _isProcessing = false; // Đang gọi API
  bool _isDetecting = false; // Đang xử lý 1 frame
  bool _isFaceDetected = false; // Đã thấy mặt
  int _countdown = 3;
  Timer? _timer;

  // --- TOÀN BỘ LOGIC GIỮ NGUYÊN ---

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableTracking: true,
      ),
    );
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector.close();
    _timer?.cancel();
    super.dispose();
  }

  /// Khởi tạo camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first);

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;
      setState(() {});

      // Bắt đầu stream ảnh cho ML Kit
      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      if (mounted) _showErrorDialog("Lỗi camera: ${e.toString()}");
    }
  }

  /// Xử lý từng frame camera
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _isProcessing || !mounted) return;

    _isDetecting = true;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isDetecting = false;
      return;
    }

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.length == 1 && !_isProcessing) {
      if (!_isFaceDetected) setState(() => _isFaceDetected = true);
      if (_timer == null) _startCountdown();
    } else {
      if (_timer != null) {
        _timer?.cancel();
        _timer = null;
        setState(() {
          _countdown = 3;
          _isFaceDetected = false;
        });
      }
    }

    _isDetecting = false;
  }

  /// Chạy đếm ngược trước khi chụp ảnh
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        _timer = null;
        _captureAndCheckIn();
      } else if (mounted) {
        setState(() => _countdown--);
      }
    });
  }

  /// Lấy GPS coordinates
  Future<Position> _getGpsCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Dịch vụ vị trí đã bị tắt.');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn.');
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    return await Geolocator.getCurrentPosition(locationSettings: settings);
  }

  /// Chụp ảnh và gọi API điểm danh
  Future<void> _captureAndCheckIn() async {
    if (_isProcessing || !mounted || _cameraController == null) return;

    setState(() => _isProcessing = true);

    try {
      await _cameraController!.stopImageStream();

      // final pos = await _getGpsCoordinates();
      // final gps = "${pos.latitude},${pos.longitude}";
      const gps = "21.0065,105.8249"; // TỌA ĐỘ TEST CỐ ĐỊNH

      final XFile imageFile = await _cameraController!.takePicture();
      final imageBytes = await File(imageFile.path).readAsBytes();
      final base64Image = "data:image/jpeg;base64,${base64Encode(imageBytes)}";

      final request = CheckInRequest(
        classSessionId: int.parse(widget.sessionId),
        qrToken: widget.qrToken,
        liveSelfieBase64: base64Image,
        clientGpsCoordinates: gps,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang xử lý khuôn mặt...')),
        );
      }

      final response = await _checkInService.checkInStudent(request);

      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        _showResultDialog(true, response.message);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        _showResultDialog(false, "Điểm danh thất bại: ${e.message}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        _showResultDialog(false, "Đã xảy ra lỗi: ${e.toString()}");
      }
    }
  }

  /// Dialog kết quả
  void _showResultDialog(bool success, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(success ? "Thành công" : "Thất bại"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (success) {
                widget.onBack?.call();
              } else {
                setState(() {
                  _countdown = 3;
                  _isProcessing = false;
                  _isFaceDetected = false;
                });
                if (_cameraController != null) {
                  _cameraController!.startImageStream(_processCameraImage);
                }
              }
            },
            child: Text(success ? "OK" : "Thử lại"),
          ),
        ],
      ),
    );
  }

  /// Dialog lỗi nghiêm trọng
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Lỗi nghiêm trọng"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onBack?.call();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Cancel button
  void _onCancelPress() {
    if (_isProcessing) return;
    _timer?.cancel();
    widget.onBack?.call();
  }

  /// Chuyển CameraImage -> InputImage
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    try {
      final camera = _cameraController!.description;
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21;

      final bytes = Platform.isIOS
          ? image.planes.first.bytes
          : (() {
        final buffer = WriteBuffer();
        for (final p in image.planes) {
          buffer.putUint8List(p.bytes);
        }
        return buffer.done().buffer.asUint8List();
      })();

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (_) {
      return null;
    }
  }

  // --- HÀM BUILD ĐÃ ĐƯỢC CẬP NHẬT ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. XÓA APPBAR CŨ
      // appBar: ...

      // 2. THÊM MÀU NỀN
      backgroundColor: Colors.white,

      // 3. THÊM SAFEAREA VÀ COLUMN
      body: SafeArea(
        child: Column(
          children: [
            // 4. THÊM THANH TIÊU ĐỀ TÙY CHỈNH
            Container(
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
                    onPressed: _onCancelPress, // Dùng logic cũ
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Nhận diện khuôn mặt", // Tiêu đề mới
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Để căn giữa
                ],
              ),
            ),

            // 5. BỌC WIDGET FRAME TRONG EXPANDED
            Expanded(
              child: FaceRecognitionFrame(
                initializeControllerFuture: _initializeControllerFuture,
                cameraController: _cameraController,
                isProcessing: _isProcessing,
                isFaceDetected: _isFaceDetected,
                countdown: _countdown,
                onCancelPress: _onCancelPress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}