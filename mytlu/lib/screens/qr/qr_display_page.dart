import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// Thay thế bằng đường dẫn chính xác
import '../../models/session_data.dart';
// Import các trang khác nếu cần điều hướng từ nút
import '../management/attendance_history_page.dart';

// Màu sắc chung từ các file khác
const Color tluPrimaryColor = Color(0xFF0D47A1); // Xanh TLU đậm
const Color tluAccentColor = Color(0xFF42A5F5); // Xanh sáng hơn

class QrDisplayPage extends StatelessWidget {
  final SessionData sessionData;
  final String startTime; // Thời gian bắt đầu điểm danh (VD: 08:00)
  final String endTime;   // Thời gian kết thúc điểm danh (VD: 08:30)

  // Tên Giảng viên (Giả sử bạn không truyền, nhưng cần để khớp UI)
  final String lecturerName = 'Nguyễn Văn A';

  const QrDisplayPage({
    super.key,
    required this.sessionData,
    required this.startTime,
    required this.endTime,
  });

  // Helper cho Widget hiển thị thông tin dạng key/value
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

  // Widget cho trạng thái chip
  Widget _buildStatusChip(String status) {
    final bool isActive = status.toLowerCase() == 'đang diễn ra';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
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
    // Nội dung mã QR
    final qrContent =
        'Class: ${sessionData.classCode}, '
        'Subject: ${sessionData.subjectName}, '
        'Room: ${sessionData.sessionLocation}, '
        'Date: ${sessionData.sessionDate}, '
        'Start: $startTime, End: $endTime';

    // Lấy ngày học (Giả định sessionDate là 'YYYY-MM-DD')
    final sessionDateStr = sessionData.sessionDate.split('T')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KHUNG CHỨA MÃ QR (Đã sửa lại thành Card cho giống UI)
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: QrImageView(
                      data: qrContent,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 2. PHẦN THÔNG TIN CHI TIẾT
              const Text(
                'Thông tin lớp học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Môn học + Trạng thái
              _buildDetailRow(
                  'Môn học',
                  sessionData.subjectName ?? 'N/A',
                  trailing: _buildStatusChip('Đang diễn ra') // Trạng thái cố định trong UI mẫu
              ),
              const SizedBox(height: 10),

              // Phòng học
              _buildDetailRow('Phòng', sessionData.sessionLocation, trailing: const Text('')),
              const SizedBox(height: 10),

              // Giảng viên (Không có trong SessionData, dùng biến cứng)
              _buildDetailRow('Giảng viên', lecturerName, trailing: const Text('')),
              const SizedBox(height: 10),

              // Thời gian học
              _buildDetailRow('Thời gian học',
                  '${sessionData.startTime.split('T')[1].substring(0, 5)} - ${sessionData.endTime.split('T')[1].substring(0, 5)}',
                  trailing: const Text('')),
              const SizedBox(height: 10),

              // Ngày
              _buildDetailRow('Ngày', sessionDateStr, trailing: const Text('')),
              const SizedBox(height: 10),

              // Thời gian điểm danh
              _buildDetailRow('Thời gian điểm danh', '$startTime - $endTime', trailing: const Text('')),

              const SizedBox(height: 40),

              // 3. NÚT HÀNH ĐỘNG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Nút Chỉnh sửa (Trở về trang CreateQrPage)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Quay về trang CreateQrPage để chỉnh sửa
                      },
                      child: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tluAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Nút Quản lý điểm danh (Đi đến AttendanceHistoryPage)

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}