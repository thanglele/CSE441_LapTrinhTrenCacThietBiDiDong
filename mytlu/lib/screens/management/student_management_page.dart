import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/class_detail_model.dart';
import '../../models/student_model.dart';
// <<< THÊM CÁC SERVICE >>>
import '../../services/api_service.dart';
import '../../services/user_session.dart';

class StudentManagementPage extends StatefulWidget {
  // Trang này nhận thông tin lớp học từ trang trước
  final ClassDetail? classDetail;

  const StudentManagementPage({super.key, required this.classDetail});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  final ApiService _apiService = ApiService();

  String? _jwtToken;
  bool _isLoading = true;
  Exception? _loadError;

  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];

  late String _selectedClassCode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedClassCode = widget.classDetail.classCode;
    _loadInitialData();
  }

  // =========================================================================
  // TẢI DỮ LIỆU BAN ĐẦU (Token và Danh sách Sinh viên) - GIỮ NGUYÊN
  // =========================================================================
  Future<void> _loadInitialData() async {
    try {
      final session = UserSession();
      final token = await session.getToken();

      if (token == null) {
        throw Exception('Token không khả dụng. Vui lòng đăng nhập lại.');
      }
      _jwtToken = token;

      // GỌI API: chỉ tải sinh viên cho lớp hiện tại được truyền vào.
      final students = await _apiService.fetchStudentsInClass(
        widget.classDetail.classCode,
        _jwtToken!,
      );

      if (!mounted) return;

      setState(() {
        _allStudents = students;
        _isLoading = false;
        // Bắt đầu lọc lần đầu
        _filterStudents();
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e is Exception ? e : Exception(e.toString());
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu sinh viên: ${_loadError!.toString()}')),
        );
      }
    }
  }

  // =========================================================================
  // LOGIC LỌC DỮ LIỆU (ĐÃ SỬA)
  // =========================================================================
  void _filterStudents() {
    setState(() {
      _filteredStudents = _allStudents.where((student) {

        // <<< SỬA: BỎ classMatch nếu bạn chỉ tải 1 lớp, hoặc nếu bạn muốn Dropdown ClassCode là bộ lọc >>>
        // Giữ lại classMatch nếu bạn dự định Dropdown sẽ chọn giữa các lớp khác nhau (ví dụ: lớp LT và lớp TH)
        final classMatch = student.className == _selectedClassCode; // Chỉ hiện lớp hiện tại

        // Lọc theo Tìm kiếm (Tên hoặc ID sinh viên)
        final searchMatch = _searchQuery.isEmpty ||
            student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.id.toLowerCase().contains(_searchQuery.toLowerCase());

        // Hiện tại: Chỉ lọc theo lớp đang được chọn VÀ theo thanh tìm kiếm
        return classMatch && searchMatch;
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    // ... (Xử lý Loading và Error giữ nguyên) ...
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý sinh viên', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0D47A1)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý sinh viên', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0D47A1)),
        body: Center(child: Text('Không thể tải sinh viên: ${_loadError!.toString()}')),
      );
    }

    final String subjectName = widget.classDetail.subjectCode;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Quản lý sinh viên',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
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
              '$subjectName: ${widget.classDetail.classCode}',
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
                // Dropdown chọn lớp (Hiện tại chỉ có lớp đang chọn)
                DropdownButtonFormField<String>(
                  value: _selectedClassCode,
                  decoration: _inputDecoration('Lớp học'),
                  // Lớp duy nhất được tải từ API (lớp chính)
                  items: [widget.classDetail.classCode].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClassCode = newValue!;
                      _filterStudents();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Thanh tìm kiếm
                TextField(
                  decoration: _inputDecoration('Tìm kiếm').copyWith(
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterStudents();
                  },
                ),
              ],
            ),
          ),

          // Danh sách sinh viên
          Expanded(
            child: _filteredStudents.isEmpty && _searchQuery.isNotEmpty
                ? const Center(child: Text("Không tìm thấy sinh viên phù hợp."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(_filteredStudents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ... (Các Widget phụ _buildStudentCard, _buildStatusChip, _inputDecoration giữ nguyên) ...
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
              backgroundImage: student.imageUrl.isNotEmpty
                  ? NetworkImage(student.imageUrl) as ImageProvider
                  : const AssetImage('assets/images/avatar_placeholder.png'),
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
                    'Mã SV: ${student.id}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Lớp: ${student.className}',
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
                  onPressed: () {
                    // TODO: Điều hướng sang trang chi tiết SV 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xem chi tiết SV: ${student.name}')),
                    );
                  },
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