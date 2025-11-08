import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/session_data.dart';
// import '../management/attendance_history_page.dart';

const Color tluPrimaryColor = Color(0xFF0D47A1);
const Color tluAccentColor = Color(0xFF42A5F5);

class QrDisplayPage extends StatelessWidget {
  final SessionData sessionData;
  final String startTime; // Thời gian bắt đầu điểm danh (VD: 08:00)
  final String endTime;   // Thời gian kết thúc điểm danh (VD: 08:30)
  // **THAY ĐỔI:** Đổi qrToken thành qrContent
  final String qrContent; // Nội dung QR là toàn bộ JSON response

  const QrDisplayPage({
    super.key,
    required this.sessionData,
    required this.startTime,
    required this.endTime,
    required this.qrContent, // **THAY ĐỔI**
  });

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

  // (Giữ nguyên _buildDetailRow)
  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
            if (trailing != null) trailing
          ],
        ),
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

  // (Giữ nguyên _buildStatusChip)
  Widget _buildStatusChip(String status) {
    final bool isActive = status.toLowerCase() == 'in_progress' || status.toLowerCase() == 'đang diễn ra';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  @override
  Widget build(BuildContext context) {
    // Lấy ngày học
    String sessionDateStr = "N/A";
    try {
      final dateTime = DateTime.parse(sessionData.startTime).toLocal();
      sessionDateStr = DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      debugPrint("Lỗi parse ngày: $e");
    }

    // **CẬP NHẬT:** Không cần định nghĩa qrContent, dùng trực tiếp biến của class
    // final qrContent = this.qrContent; // (Không cần dòng này)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR Điểm Danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KHUNG CHỨA MÃ QR
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: QrImageView(
                      data: this.qrContent, // **THAY ĐỔI:** Dùng biến của class
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 2. PHẦN THÔNG TIN CHI TIẾT
              const Text(
                'Thông tin buổi học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Lớp học phần + Trạng thái
              _buildDetailRow(
                  'Lớp học phần',
                  sessionData.className,
                  trailing: _buildStatusChip(sessionData.sessionStatus) 
              ),
              const SizedBox(height: 10),

              // (Giữ nguyên các _buildDetailRow còn lại)
              _buildDetailRow('Phòng', sessionData.location, trailing: const Text('')),
              const SizedBox(height: 10),
              _buildDetailRow('Giảng viên', sessionData.lecturerName ?? 'N/A', trailing: const Text('')),
              const SizedBox(height: 10),
              _buildDetailRow('Thời gian học',
                  '${_extractTimeSafely(sessionData.startTime)} - ${_extractTimeSafely(sessionData.endTime)}',
                  trailing: const Text('')),
              const SizedBox(height: 10),
              _buildDetailRow('Ngày', sessionDateStr, trailing: const Text('')),
              const SizedBox(height: 10),
              _buildDetailRow('Thời gian điểm danh', '$startTime - $endTime', trailing: const Text('')),
              const SizedBox(height: 40),

              // 3. NÚT HÀNH ĐỘNG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Quay về trang CreateQrPage
                      },
                      child: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tluAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}