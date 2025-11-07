import 'package:flutter/material.dart';
import 'class_management_page.dart';
import '../../models/subject_model.dart';


class SubjectManagementPage extends StatefulWidget {
  const SubjectManagementPage({super.key});

  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  // Danh sách dữ liệu giả lập
  final List<Subject> _subjects = [
    Subject(name: 'Học tăng cường', code: 'CSE321', credits: 3, classCount: 1),
    Subject(name: 'Mạng máy tính', code: 'CSE1234', credits: 3, classCount: 2),
    Subject(name: 'Kiến trúc máy tính', code: 'CSE123', credits: 3, classCount: 1),
    Subject(name: 'Cấu trúc dữ liệu và giải thuật', code: 'CSE123', credits: 3, classCount: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Quản lý môn học', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1), // Màu TLU
        iconTheme: const IconThemeData(color: Colors.white), // Nút back màu trắng
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách môn học
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return _buildSubjectCard(_subjects[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để xây dựng card cho mỗi môn học
  Widget _buildSubjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cột thông tin bên trái
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.code} • ${subject.credits} tín chỉ',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),

            // Nút quản lý bên phải
            TextButton(
              onPressed: () {
                // Hành động điều hướng mới
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Truyền môn học (subject) mà người dùng đã bấm
                    builder: (context) => ClassManagementPage(subject: subject),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE3F2FD), // Màu xanh nhạt
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                children: [
                  Text(
                    '${subject.classCount.toString().padLeft(2, '0')} lớp',
                    style: const TextStyle(
                      color: Color(0xFF0D47A1), // Màu TLU
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF0D47A1)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}