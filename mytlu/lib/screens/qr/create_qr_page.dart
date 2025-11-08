import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Cần cho jsonDecode và utf8
import 'package:intl/intl.dart';
import '../../models/session_data.dart';
import '../../services/user_session.dart';
import 'qr_display_page.dart';

// (Giữ nguyên các hằng số màu sắc)
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

  // (Giữ nguyên _extractTimeSafely)
  String _extractTimeSafely(String fullDateTimeString) {
    try {
      final dateTime = DateTime.parse(fullDateTimeString);
      return DateFormat('HH:mm').format(dateTime.toLocal());
    } catch (e) {
      final RegExp timeRegex = RegExp(r'(\d{2}:\d{2})');
      final match = timeRegex.firstMatch(fullDateTimeString);
      if (match != null) {
        return match.group(0)!;
      }
      return '00:00';
    }
  }

  // (Giữ nguyên _loadData)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final sessionData = SessionData.fromJson(data);

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

  /// **PHẦN CẬP NHẬT CHÍNH**
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

      // Giải mã response body (dùng utf8 để hỗ trợ tiếng Việt)
      final responseBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // 1. Lấy chuỗi JSON từ trường 'qrData'
        final String qrDataString = responseData['qrData'];
        
        // 2. Phân tích chuỗi JSON bên trong đó
        final qrDataJson = jsonDecode(qrDataString);
        
        // 3. Lấy ra 'qrToken' (nội dung QR thực tế)
        final String qrToken = qrDataJson['qrToken'];

        // 4. Lấy trạng thái mới (ví dụ: "in_progress")
        final String newStatus = responseData['sessionStatus'];

        // 5. Tạo session data MỚI với trạng thái đã cập nhật
        final updatedSessionData = _sessionData!.copyWith(sessionStatus: newStatus);

        // 6. Cập nhật state của trang này (để nếu user quay lại, trạng thái đã đúng)
        setState(() {
          _sessionData = updatedSessionData;
        });

        // Lấy thời gian điểm danh đã chọn
        final String formattedStartTime = _checkInTime;
        final String formattedEndTime = _checkOutTime;

        // Hiển thị thông báo thành công từ API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Đã bắt đầu điểm danh!')),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QrDisplayPage(
                sessionData: updatedSessionData, // <-- Truyền data đã cập nhật
                startTime: formattedStartTime,
                endTime: formattedEndTime,
                qrToken: qrToken, // <-- Truyền qrToken
              ),
            ),
          );
        }
      } else {
        // Lỗi từ server (4xx, 5xx)
        final errorMessage = responseData['message'] ?? 'Lỗi không xác định.';
        debugPrint('❌ Lỗi start-attendance: ${response.statusCode} - $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể bắt đầu điểm danh: $errorMessage')),
        );
      }
    } catch (e) {
      // Lỗi mạng, parsing JSON...
      debugPrint('Lỗi mạng hoặc parsing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối hoặc dữ liệu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // (Giữ nguyên _buildTimeList)
  List<String> _buildTimeList(String start, String end) {
    int startMinutes = int.parse(start.split(':')[0]) * 60 + int.parse(start.split(':')[1]);
    int endMinutes = int.parse(end.split(':')[0]) * 60 + int.parse(end.split(':')[1]);

    List<String> times = [];
    for (int minutes = startMinutes; minutes <= endMinutes; minutes += 5) {
      final hour = (minutes ~/ 60) % 24;
      final minute = minutes % 60;
      times.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
    
    String endTimeStr = '${(endMinutes ~/ 60) % 24}'.padLeft(2, '0') + ':' + '${endMinutes % 60}'.padLeft(2, '0');
    if (!times.contains(endTimeStr) && endMinutes > startMinutes) {
         times.add(endTimeStr);
    }
    
    return times;
  }


  // (Giữ nguyên _buildInfoField)
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
           Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
           const SizedBox(height: 4),
        ],
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

  // (Giữ nguyên _buildStatusChip)
  Widget _buildStatusChip(String status) {
    final bool isActive = status.toLowerCase() == 'in_progress';
    final bool isScheduled = status.toLowerCase() == 'scheduled';
    
    String text;
    Color bgColor;
    Color textColor;

    if (isActive) {
      text = 'Đang diễn ra';
      bgColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
    } else if (isScheduled) {
      text = 'Sắp diễn ra';
      bgColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
    } else {
      text = status;
      bgColor = Colors.grey[200]!;
      textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // (Giữ nguyên build)
  @override
  Widget build(BuildContext context) {
    if (_isLoading && _sessionData == null) { // Chỉ full load khi chưa có data
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo QR', style: TextStyle(color: Colors.white)), backgroundColor: tluPrimaryColor),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null && _sessionData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo QR', style: TextStyle(color: Colors.white)), backgroundColor: tluPrimaryColor),
        body: Center(child: Text('Lỗi tải dữ liệu: ${_loadError?.toString() ?? "Không có dữ liệu session"}')),
      );
    }

    final SessionData data = _sessionData!;
    
    final String sessionStartTimeStr = _extractTimeSafely(data.startTime);
    final String sessionEndTimeStr = _extractTimeSafely(data.endTime);

    String sessionDateStr = "N/A";
    try {
      final dateTime = DateTime.parse(data.startTime).toLocal();
      sessionDateStr = DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      sessionDateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    final List<String> timeList = _buildTimeList(sessionStartTimeStr, sessionEndTimeStr);

    if (!timeList.contains(_checkInTime) && timeList.isNotEmpty) {
      _checkInTime = timeList.first;
    }
    if (!timeList.contains(_checkOutTime) && timeList.isNotEmpty) {
      _checkOutTime = timeList.last;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo QR', style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text('Buổi học', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500))),
                    _buildStatusChip(data.sessionStatus),
                  ],
                ),
                _buildInfoField('', data.title ?? 'N/A'), 
                const SizedBox(height: 16),
                _buildInfoField('Lớp học phần', data.className ?? 'N/A'),
                const SizedBox(height: 16),
                _buildInfoField('Phòng học', data.location ?? 'N/Am'),
                const SizedBox(height: 16),
                _buildInfoField('Giảng viên', data.lecturerName ?? 'N/A'),
                const SizedBox(height: 16),
                _buildInfoField('Thời gian học', '$sessionStartTimeStr - $sessionEndTimeStr'),
                const SizedBox(height: 16),
                _buildInfoField('Ngày', sessionDateStr),
                const SizedBox(height: 24),
                Text('Thời gian điểm danh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _checkInTime,
                        decoration: InputDecoration(
                            labelText: 'Từ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                        items: timeList.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _isLoading ? null : (String? newValue) { // Vô hiệu hóa khi đang tải
                          if (newValue != null) {
                            setState(() {
                              _checkInTime = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _checkOutTime,
                        decoration: InputDecoration(
                            labelText: 'Đến',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                        items: timeList.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: _isLoading ? null : (String? newValue) { // Vô hiệu hóa khi đang tải
                          if (newValue != null) {
                            setState(() {
                              _checkOutTime = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2_sharp, color: Colors.white),
                    label: const Text('Tạo QR', style: TextStyle(fontSize: 18, color: Colors.white)),
                    onPressed: _isLoading ? null : _startAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : tluAccentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lớp phủ loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}