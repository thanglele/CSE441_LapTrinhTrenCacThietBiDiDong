import 'package:flutter/material.dart';

// Màu sắc đã định nghĩa
const Color tluPrimaryColor = Color(0xFF0D47A1);
const Color tluAccentColor = Color(0xFF42A5F5);

// Dữ liệu giả lập cho buổi học được truyền từ trang Home (Giả định)
class SessionData {
  final String subjectName;
  final String room;
  final String className;
  final String scheduleTime;
  final String date;

  SessionData({
    required this.subjectName,
    required this.room,
    required this.className,
    required this.scheduleTime,
    required this.date,
  });
}

class CreateQrPage extends StatefulWidget {
  final SessionData sessionData;

  // Nhận dữ liệu buổi học qua constructor
  const CreateQrPage({super.key, required this.sessionData});

  @override
  State<CreateQrPage> createState() => _CreateQrPageState();
}

class _CreateQrPageState extends State<CreateQrPage> {
  // Biến giữ giá trị thời gian điểm danh (giả định bắt đầu từ 8:00)
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 30);

  // Danh sách các lựa chọn thời gian (ví dụ: các bước 5 phút)
  List<TimeOfDay> _generateTimeOptions() {
    List<TimeOfDay> options = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 5) {
        options.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return options;
  }

  // Hàm chuyển đổi TimeOfDay thành String (HH:MM)
  String _timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Hàm xử lý sự kiện Tạo QR
  void _createQrCode() {
    final start = _timeToString(_startTime);
    final end = _timeToString(_endTime);

    // TODO: Xử lý logic tạo QR ở đây
    // Dữ liệu cần gửi đi: widget.sessionData.className, widget.sessionData.date, start, end

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tạo QR từ $start đến $end cho lớp ${widget.sessionData.className}...')),
    );

    // Sau khi tạo QR thành công, bạn có thể chuyển sang trang hiển thị QR
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrDisplayPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Màu nền tổng thể sáng hơn
      appBar: AppBar(
        title: const Text('Tạo QR', style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white), // Icon back màu trắng
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Các trường thông tin buổi học (Chỉ đọc)
            _buildReadOnlyField('Tên môn học', widget.sessionData.subjectName),
            _buildReadOnlyField('Phòng học', widget.sessionData.room),
            _buildReadOnlyField('Lớp', widget.sessionData.className),
            _buildReadOnlyField('Thời gian học', widget.sessionData.scheduleTime),
            _buildReadOnlyField('Ngày', widget.sessionData.date),

            const SizedBox(height: 20),
            const Text(
              'Thời gian điểm danh',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // 2. Dropdown chọn thời gian điểm danh
            Row(
              children: <Widget>[
                // Thời gian BẮT ĐẦU
                Expanded(
                  child: _buildTimeDropdown(
                    label: 'Bắt đầu',
                    selectedTime: _startTime,
                    onChanged: (TimeOfDay? newTime) {
                      if (newTime != null) {
                        setState(() {
                          _startTime = newTime;
                          // Đảm bảo thời gian kết thúc sau thời gian bắt đầu
                          if (_endTime.hour * 60 + _endTime.minute < newTime.hour * 60 + newTime.minute) {
                            _endTime = TimeOfDay(
                                hour: newTime.hour,
                                minute: newTime.minute + 30 > 59 ? newTime.minute + 30 : newTime.minute + 30
                            );
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Thời gian KẾT THÚC
                Expanded(
                  child: _buildTimeDropdown(
                    label: 'Kết thúc',
                    selectedTime: _endTime,
                    onChanged: (TimeOfDay? newTime) {
                      if (newTime != null) {
                        setState(() {
                          _endTime = newTime;
                        });
                      }
                    },
                    // Chỉ cho phép chọn thời gian sau thời gian bắt đầu
                    filter: (TimeOfDay option) => option.hour * 60 + option.minute >= _startTime.hour * 60 + _startTime.minute,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 3. Nút Tạo QR
            Center(
              child: ElevatedButton.icon(
                onPressed: _createQrCode,
                icon: const Icon(Icons.qr_code_2_sharp, size: 24),
                label: const Text('Tạo QR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: tluAccentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper cho trường hiển thị thông tin chỉ đọc
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: tluAccentColor, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper cho Dropdown chọn thời gian
  Widget _buildTimeDropdown({
    required String label,
    required TimeOfDay selectedTime,
    required ValueChanged<TimeOfDay?> onChanged,
    bool Function(TimeOfDay)? filter,
  }) {
    // Lọc danh sách nếu có hàm filter
    final List<TimeOfDay> options = _generateTimeOptions()
        .where(filter ?? (t) => true)
        .toList();

    return DropdownButtonFormField<TimeOfDay>(
      value: selectedTime,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: tluPrimaryColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: tluAccentColor, width: 2.0),
        ),
      ),
      items: options.map<DropdownMenuItem<TimeOfDay>>((TimeOfDay time) {
        return DropdownMenuItem<TimeOfDay>(
          value: time,
          child: Text(_timeToString(time)),
        );
      }).toList(),
    );
  }
}