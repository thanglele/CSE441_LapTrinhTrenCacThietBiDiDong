import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Cần cho việc định dạng ngày
import '../../models/session_data.dart';
import '../../services/user_session.dart';
import 'qr_display_page.dart';

// Màu sắc phụ (Nếu cần)
const Color tluAccentColor = Color(0xFF42A5F5);
const Color tluPrimaryColor = Color(0xFF0D47A1);

class CreateQrPage extends StatefulWidget {
  final String sessionId;
  const CreateQrPage({super.key, required this.sessionId});

  @override
  State<CreateQrPage> createState() => _CreateQrPageState();
}

class _CreateQrPageState extends State<CreateQrPage> {
  String? _jwtToken;
  bool _isLoading = true;
  SessionData? _sessionData;
  Exception? _loadError;

  late String _checkInTime;
  late String _checkOutTime;

  @override
  void initState() {
    super.initState();
    _checkInTime = "00:00";
    _checkOutTime = "00:00";
    _loadData();
  }

  // Helper: Trích xuất HH:mm an toàn (Giữ nguyên từ lần sửa trước)
  String _extractTimeSafely(String fullDateTimeString) {
    final RegExp timeRegex = RegExp(r'(\d{2}:\d{2})');
    final match = timeRegex.firstMatch(fullDateTimeString);
    if (match != null) {
      return match.group(0)!;
    }
    return '00:00';
  }

  Future<void> _loadData() async {
    // ... (Giữ nguyên logic tải dữ liệu và token) ...
    try {
      final session = UserSession();
      final token = await session.getToken();

      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }
      _jwtToken = token;

      final url = Uri.parse('https://mytlu.thanglele.cloud/api/v1/sessions/${widget.sessionId}');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionData = SessionData.fromJson(data);

        // Sử dụng helper để trích xuất thời gian an toàn
        final String startTimeStr = _extractTimeSafely(sessionData.startTime);
        final String endTimeStr = _extractTimeSafely(sessionData.endTime);

        setState(() {
          _sessionData = sessionData;
          _checkInTime = startTimeStr;
          _checkOutTime = endTimeStr;
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

  Future<void> _startAttendance() async {
    // ... (Giữ nguyên logic _startAttendance) ...
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
        final String formattedStartTime = _checkInTime;
        final String formattedEndTime = _checkOutTime;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bắt đầu điểm danh và tạo QR!')),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QrDisplayPage(
                sessionData: _sessionData!,
                startTime: formattedStartTime,
                endTime: formattedEndTime,
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

  List<String> _buildTimeList(String start, String end) {
    // ... (Giữ nguyên logic _buildTimeList) ...
    int startMinutes = int.parse(start.split(':')[0]) * 60 + int.parse(start.split(':')[1]);
    int endMinutes = int.parse(end.split(':')[0]) * 60 + int.parse(end.split(':')[1]);

    List<String> times = [];
    for (int minutes = startMinutes; minutes <= endMinutes; minutes += 5) {
      final hour = (minutes ~/ 60) % 24;
      final minute = minutes % 60;
      times.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
    return times;
  }

  Widget _buildInfoField(String label, String value) {
    // ... (Giữ nguyên _buildInfoField) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          width: double.infinity,
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    // ... (Giữ nguyên _buildStatusChip) ...
    final bool isActive = status.toLowerCase() == 'in_progress';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Đang diễn ra' : 'Sắp diễn ra',
        style: TextStyle(
          color: isActive ? Colors.green[800] : Colors.orange[800],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo QR', style: TextStyle(color: Colors.white)), backgroundColor: tluPrimaryColor),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null || _sessionData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo QR', style: TextStyle(color: Colors.white)), backgroundColor: tluPrimaryColor),
        body: Center(child: Text('Lỗi tải dữ liệu: ${_loadError?.toString() ?? "Không có dữ liệu session"}')),
      );
    }

    final SessionData data = _sessionData!;
    final String sessionStartTimeStr = _checkInTime;
    final String sessionEndTimeStr = _checkOutTime;

    // <<< PHẦN SỬA LỖI CHÍNH: LẤY VÀ ĐỊNH DẠNG NGÀY HÔM NAY >>>
    final String sessionDateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
    // Ví dụ: Nếu hôm nay là 08/11/2025, sessionDateStr sẽ là "08/11/2025"


    final List<String> timeList = _buildTimeList(sessionStartTimeStr, sessionEndTimeStr);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo QR', style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng Tên Môn học và Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Tên môn học', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500))),
                _buildStatusChip(data.sessionStatus),
              ],
            ),

            _buildInfoField('', data.subjectName ?? 'N/A'),
            const SizedBox(height: 16),

            _buildInfoField('Phòng học', data.sessionLocation),
            const SizedBox(height: 16),

            _buildInfoField('Lớp', data.classCode ?? 'N/A'),
            const SizedBox(height: 16),

            // Dùng thời gian học thực tế của session
            _buildInfoField('Thời gian học', '${_extractTimeSafely(data.startTime)} - ${_extractTimeSafely(data.endTime)}'),
            const SizedBox(height: 16),

            // Trường Ngày (Sử dụng ngày hôm nay)
            _buildInfoField('Ngày', sessionDateStr),
            const SizedBox(height: 24),

            // THỜI GIAN ĐIỂM DANH (Dropdowns)
            Text('Thời gian điểm danh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 8),

            Row(
              children: [
                // Dropdown Bắt đầu
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _checkInTime,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                    items: timeList.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _checkInTime = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Dropdown Kết thúc
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _checkOutTime,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                    items: timeList.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _checkOutTime = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Nút TẠO QR
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2_sharp, color: Colors.white),
                label: const Text('Tạo QR', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: _startAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tluAccentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}