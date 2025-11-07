import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// Thay thế bằng đường dẫn chính xác
import '../../models/session_data.dart';

// Màu sắc chung từ các file khác
const Color tluPrimaryColor = Color(0xFF0D47A1); // Xanh TLU đậm
const Color tluAccentColor = Color(0xFF42A5F5); // Xanh sáng hơn

class QrDisplayPage extends StatelessWidget {
  final SessionData sessionData;
  final String startTime;
  final String endTime;

  const QrDisplayPage({
    super.key,
    required this.sessionData,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    // Nội dung mã QR
    final qrContent =
        'Class: ${sessionData.classCode}, '
        'Subject: ${sessionData.subjectName}, '
        'Room: ${sessionData.sessionLocation}, '
        'Date: ${sessionData.sessionDate}, '
        'Start: $startTime, End: $endTime';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR Điểm danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: tluPrimaryColor, // Dùng màu TLU chính
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView( // Cho phép cuộn nếu màn hình nhỏ
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // KHUNG CHỨA MÃ QR
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      // MÃ QR
                      QrImageView(
                        data: qrContent,
                        version: QrVersions.auto,
                        size: 280.0,
                        // Thêm màu sắc và điểm nhìn
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: tluPrimaryColor,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // TRẠNG THÁI
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade700)
                        ),
                        child: Text(
                          'ĐANG DIỄN RA - Vui lòng không làm mới',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // THÔNG TIN LỚP HỌC (theo format của ClassCard)
              Text(
                'Chi tiết buổi học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const Divider(),

              _buildInfoRow(Icons.book, 'Môn học', sessionData.subjectName ?? 'N/A'),
              _buildInfoRow(Icons.school, 'Lớp', sessionData.classCode ?? 'N/A'),
              _buildInfoRow(Icons.access_time, 'Thời gian', '$startTime - $endTime'),
              _buildInfoRow(Icons.location_on, 'Phòng', sessionData.sessionLocation),
              _buildInfoRow(Icons.calendar_today, 'Ngày', sessionData.sessionDate),

              const SizedBox(height: 40),

              // NÚT KẾT THÚC (Nếu cần)
              // TODO: Thêm logic gọi API /sessions/{id}/end-attendance
              ElevatedButton.icon(
                onPressed: () {
                  // (Nên có hàm gọi API end-attendance và quay về HomePage)
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
                label: const Text('KẾT THÚC ĐIỂM DANH', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper để hiển thị thông tin chi tiết theo hàng
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tluPrimaryColor, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}