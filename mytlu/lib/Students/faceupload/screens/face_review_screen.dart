// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/face_upload_service.dart';

class FaceReviewScreen extends StatefulWidget {
  final File imageFile;
  const FaceReviewScreen({super.key, required this.imageFile});

  @override
  State<FaceReviewScreen> createState() => _FaceReviewScreenState();
}

class _FaceReviewScreenState extends State<FaceReviewScreen> {
  bool _isUploading = false;
  String? _uploadResultMessage;

  Future<void> _uploadFace() async {
    setState(() {
      _isUploading = true;
      _uploadResultMessage = null;
    });

    final faceService = FaceUploadService();

    try {
      final response = await faceService.uploadFaceData(imageFile: widget.imageFile);

      setState(() {
        _uploadResultMessage = response.message;
      });

      // Nếu status = verified/uploaded -> hiện thông báo thành công
      if (response.uploadStatus == "verified" || response.uploadStatus == "uploaded") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ ${response.uploadStatus.toUpperCase()} - ${response.message}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // quay lại FaceScanScreen với kết quả true
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ ${response.message}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi upload: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text("Xác nhận khuôn mặt"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Xác nhận ảnh khuôn mặt của bạn trước khi tải lên",
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            ClipOval(
              child: Image.file(
                widget.imageFile,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 30),

            if (_isUploading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Đang tải ảnh lên máy chủ..."),
                ],
              )
            else ...[
              ElevatedButton.icon(
                onPressed: _uploadFace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                label: const Text(
                  "Xác nhận & Tải lên",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Chụp lại",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ),
            ],

            if (_uploadResultMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _uploadResultMessage!,
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
