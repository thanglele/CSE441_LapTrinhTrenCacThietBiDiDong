import 'package:flutter/material.dart';
import '../../models/class_detail_model.dart';
import '../../models/student_model.dart';

class StudentManagementPage extends StatefulWidget {
  // Trang này nhận thông tin lớp học từ trang trước
  final ClassDetail classDetail;

  const StudentManagementPage({super.key, required this.classDetail});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  // Dữ liệu giả lập
  final List<Student> _dummyStudents = [
    Student(
      id: '2251177226',
      name: 'Ngô Thị Ngọc Ánh',
      className: '64KTPM3',
      imageUrl: 'https://i.pravatar.cc/150?img=11', // Ảnh giả
      isRegistered: true,
    ),
    Student(
      id: '2251177227',
      name: 'Ngô Thị Ngọc Ếm',
      className: '64KTPM3',
      imageUrl: 'https://i.pravatar.cc/150?img=12', // Ảnh giả
      isRegistered: true,
    ),
    Student(
      id: '2251177228',
      name: 'Lê Sỹ Thắng',
      className: '64KTPM3',
      imageUrl: 'https://i.pravatar.cc/150?img=13', // Ảnh giả
      isRegistered: true,
    ),
    Student(
      id: '2251177229',
      name: 'Lê Thắng',
      className: '64KTPM3',
      imageUrl: 'https://i.pravatar.cc/150?img=14', // Ảnh giả
      isRegistered: false,
    ),
  ];

  late String _selectedClass;

  @override
  void initState() {
    super.initState();
    // Lớp được chọn mặc định là lớp được truyền vào
    _selectedClass = widget.classDetail.classCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Quản lý sinh viên',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1), // Màu TLU
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header (Tên môn học + Tên lớp)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[300],
            child: Text(
              'Học tăng cường: ${widget.classDetail.classCode}', // TODO: Cần truyền cả tên môn học
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Phần filter (Dropdown + Search)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Dropdown chọn lớp
                DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: _inputDecoration('Lớp học'),
                  items: [
                    widget.classDetail.classCode, // Chỉ có 1 lựa chọn
                    // TODO: Thêm các lớp khác của môn học này vào đây
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClass = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Thanh tìm kiếm
                TextField(
                  decoration: _inputDecoration('Tìm kiếm').copyWith(
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),

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

  // Widget cho từng Card sinh viên
  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Ảnh đại diện
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(student.imageUrl),
            ),
            const SizedBox(width: 12),

            // Cột thông tin (Tên, ID, Lớp)
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
                    student.id,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    student.className,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Cột Trạng thái và Nút chi tiết
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Trạng thái
                _buildStatusChip(student.isRegistered),
                const SizedBox(height: 4),
                // Nút chi tiết
                TextButton(
                  onPressed: () { /* TODO: Điều hướng sang trang chi tiết SV */ },
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
          ],
        ),
      ),
    );
  }

  // Widget cho cái chip "Đã đăng ký" / "Chưa đăng ký"
  Widget _buildStatusChip(bool isRegistered) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRegistered ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRegistered ? Icons.check_circle : Icons.cancel,
            color: isRegistered ? Colors.green[700] : Colors.red[700],
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isRegistered ? 'Đã đăng ký nhận diện' : 'Chưa đăng ký',
            style: TextStyle(
              color: isRegistered ? Colors.green[800] : Colors.red[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper cho InputDecoration (để tái sử dụng)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}