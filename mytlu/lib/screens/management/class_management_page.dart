import 'package:flutter/material.dart';
import '../../models/subject_model.dart';

class ClassDetail {
  final String classCode;
  final String subjectCode;
  final String academicYear;
  final String room;
  final String type;
  final int studentCount;

  ClassDetail({
    required this.classCode,
    required this.subjectCode,
    required this.academicYear,
    required this.room,
    required this.type,
    required this.studentCount,
  });
}

class ClassManagementPage extends StatefulWidget {
  final Subject subject;

  const ClassManagementPage({super.key, required this.subject});

  @override
  State<ClassManagementPage> createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage> {
  final List<ClassDetail> _classes = [
    ClassDetail(
      classCode: '64KTPM3',
      subjectCode: 'CSE123.64KTPM3',
      academicYear: '2025 - Học kỳ I',
      room: '305 - B5',
      type: 'Lý thuyết',
      studentCount: 60,
    ),
    ClassDetail(
      classCode: '64KTPM1',
      subjectCode: 'CSE123.64KTPM1',
      academicYear: '2025 - Học kỳ I',
      room: '305 - B5',
      type: 'Lý thuyết',
      studentCount: 60,
    ),
    ClassDetail(
      classCode: '64KTPM2',
      subjectCode: 'CSE123.64KTPM2',
      academicYear: '2025 - Học kỳ I',
      room: '305 - B5',
      type: 'Lý thuyết',
      studentCount: 60,
    ),
  ];

  final List<Subject> _allSubjects = [
    Subject(name: 'Học tăng cường', code: 'CSE321', credits: 3, classCount: 1),
    Subject(name: 'Mạng máy tính', code: 'CSE1234', credits: 3, classCount: 2),
    Subject(name: 'Kiến trúc máy tính', code: 'CSE123', credits: 3, classCount: 1),
  ];

  late Subject _selectedSubject;
  String _selectedClassType = 'Tất cả lớp học';

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.subject;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Quản lý lớp học', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedSubject.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterCard(),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: _classes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildClassCard(_classes[index]);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: _inputDecoration('Môn học'),
                    items: _allSubjects.map((Subject subject) {
                      return DropdownMenuItem<Subject>(
                        value: subject,
                        child: Text(subject.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (Subject? newValue) {
                      setState(() {
                        _selectedSubject = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClassType,
                    decoration: _inputDecoration('Lớp học'),
                    items: ['Tất cả lớp học', 'Lý thuyết', 'Thực hành']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClassType = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: _inputDecoration('Tìm kiếm').copyWith(
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassDetail cls) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cls.classCode,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE3F2FD),
                    foregroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 30),
                  ),
                  child: Text(
                    '${cls.studentCount} sinh viên',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            Text(
              cls.subjectCode,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Niên khóa: ${cls.academicYear}',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            Text(
              '${cls.room} • ${cls.type}',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Quản lý sinh viên',
                      style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.blue[700]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
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