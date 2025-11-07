import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../models/student_attendance_model.dart';

class AttendanceDetailPage extends StatefulWidget {
  final ClassModel classInfo;

  const AttendanceDetailPage({super.key, required this.classInfo});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  // Dữ liệu giả lập
  final List<StudentAttendance> _dummyStudents = [
    StudentAttendance(
        id: '2251177226',
        name: 'Ngô Thị Ngọc Ánh',
        className: '64KTPM3',
        status: AttendanceStatus.present),
    StudentAttendance(
        id: '2251177227',
        name: 'Ngô Thị Ngọc Ếm',
        className: '64KTPM3',
        status: AttendanceStatus.present),
    StudentAttendance(
        id: '2251177228',
        name: 'Lê Sỹ Thắng',
        className: '64KTPM3',
        status: AttendanceStatus.late),
    StudentAttendance(
        id: '2251177229',
        name: 'Lê Thắng',
        className: '64KTPM3',
        status: AttendanceStatus.absent),
  ];

  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.classInfo.code,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Khung thông tin lớp học
          _buildClassInfoSection(),
          // Khung Filter
          _buildFilterSection(),
          // Danh sách sinh viên
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _dummyStudents.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(_dummyStudents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho khung thông tin lớp học
  Widget _buildClassInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin lớp học',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _infoRow('Môn học:', widget.classInfo.name),
          _infoRow('Phòng:', widget.classInfo.room),
          _infoRow('Giảng viên:', widget.classInfo.lecturer),
          _infoRow('Thời gian học:', widget.classInfo.time),
          _infoRow('Ngày:', '22/09/2025'), // Giả lập
          _infoRow('Thời gian điểm danh:', '08:00 - 08:30'), // Giả lập
        ],
      ),
    );
  }

  // Widget con cho từng hàng thông tin
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140, // Cố định chiều rộng của label
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Widget cho khung Filter (Search + Chips)
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Thanh tìm kiếm
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
          ),
          const SizedBox(height: 16),
          // Hàng Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 60),
                _buildFilterChip('Đúng giờ', 51),
                _buildFilterChip('Đi muộn', 4),
                _buildFilterChip('Vắng mặt', 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget con cho từng chip filter
  Widget _buildFilterChip(String label, int count) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFFE3F2FD),
        checkmarkColor: Colors.blue[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget cho từng Card sinh viên
  Widget _buildStudentCard(StudentAttendance student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${student.id}   ${student.className}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () { /* TODO: Chi tiết sinh viên */ },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chi tiết',
                        style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.blue[700]),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Hàng trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIcon(
                  'Đúng giờ',
                  Icons.check_circle,
                  Colors.green,
                  student.status == AttendanceStatus.present,
                ),
                _buildStatusIcon(
                  'Đi muộn',
                  Icons.watch_later,
                  Colors.orange,
                  student.status == AttendanceStatus.late,
                ),
                _buildStatusIcon(
                  'Vắng mặt',
                  Icons.cancel,
                  Colors.red,
                  student.status == AttendanceStatus.absent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con cho từng icon trạng thái (Đúng giờ, Vắng...)
  Widget _buildStatusIcon(
      String label, IconData icon, Color color, bool isSelected) {
    return Column(
      children: [
        Icon(
          icon,
          color: isSelected ? color : Colors.grey[300],
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}