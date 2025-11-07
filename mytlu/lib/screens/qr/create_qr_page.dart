import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/session_data.dart'; // Đảm bảo SessionData có các trường cần thiết
import '../../services/user_session.dart';
import 'qr_display_page.dart';

// Màu sắc phụ (Nếu cần)
const Color tluAccentColor = Color(0xFF42A5F5);

class CreateQrPage extends StatefulWidget {
  final String sessionId; // truyền từ HomePage
  const CreateQrPage({super.key, required this.sessionId});

  @override
  State<CreateQrPage> createState() => _CreateQrPageState();
}

class _CreateQrPageState extends State<CreateQrPage> {
  String? _jwtToken;
  bool _isLoading = true;
  SessionData? _sessionData;
  Exception? _loadError; // Biến để lưu lỗi tải

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================================
  // HÀM 1: TẢI THÔNG TIN SESSION VÀ TOKEN
  // ==========================================================
  Future<void> _loadData() async {
    try {
      final session = UserSession();
      final token = await session.getToken();

      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      setState(() => _jwtToken = token);

      // Gọi API /api/v1/sessions/{sessionId}
      final url = Uri.parse('https://mytlu.thanglele.cloud/api/v1/sessions/${widget.sessionId}');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // <<< GIẢ ĐỊNH: Bạn cần có SessionData.fromJson(Map<String, dynamic> json) >>>
        final sessionData = SessionData.fromJson(data);

        setState(() {
          _sessionData = sessionData;
        });
      } else {
        throw Exception('Lỗi khi tải dữ liệu (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi tải session: $e');
      setState(() {
        _loadError = e is Exception ? e : Exception(e.toString());
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================================
  // HÀM 2: GỌI API BẮT ĐẦU ĐIỂM DANH
  // ==========================================================
  Future<void> _startAttendance() async {
    if (_jwtToken == null || _sessionData == null) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(
        'https://mytlu.thanglele.cloud/api/v1/sessions/${widget.sessionId}/start-attendance');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body); // Bạn có thể dùng data này nếu cần mã QR code

        // <<< SỬA CHÍNH: CHUYỂN ĐỔI KIỂU DỮ LIỆU VÀ ĐIỀU HƯỚNG >>>
        // Chuyển đổi DateTime sang String (HH:mm) trước khi truyền vào QrDisplayPage
        final String formattedStartTime = _sessionData!.startTime.split('T')[1].substring(0, 5); // VD: '08:00'
        final String formattedEndTime = _sessionData!.endTime.split('T')[1].substring(0, 5); // VD: '09:30'

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bắt đầu điểm danh và tạo QR!')),
        );

        if (mounted) {
          Navigator.pushReplacement( // Dùng Replacement để không quay lại trang tạo QR
            context,
            MaterialPageRoute(
              builder: (_) => QrDisplayPage(
                sessionData: _sessionData!,
                startTime: formattedStartTime, // Truyền String
                endTime: formattedEndTime,   // Truyền String
              ),
            ),
          );
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Lỗi không xác định.';
        debugPrint('❌ Lỗi start-attendance: ${response.statusCode} - $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể bắt đầu điểm danh: $errorMessage')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi mạng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối mạng: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================================
  // GIAO DIỆN
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo mã QR điểm danh')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : _loadError != null
              ? Text('Lỗi: ${_loadError!.toString()}')
              : _sessionData == null
              ? const Text('Không có dữ liệu buổi học.')
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị tóm tắt thông tin
              Text('Môn học: ${_sessionData!.subjectName ?? "Không rõ"}', style: const TextStyle(fontSize: 18)),
              Text('Phòng: ${_sessionData!.sessionLocation}', style: const TextStyle(fontSize: 16)),
              Text('Thời gian: ${_sessionData!.startTime.split('T')[1].substring(0, 5)} - ${_sessionData!.endTime.split('T')[1].substring(0, 5)}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),

              // Nút Bắt đầu điểm danh (Giao diện cũ)
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code, color: Colors.white),
                label: const Text('Bắt đầu điểm danh', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: _startAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tluAccentColor, // Màu xanh
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}