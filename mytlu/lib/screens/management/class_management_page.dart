// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../services/api_service.dart';
// import '../../services/user_session.dart';
//
// import '../../models/subject_model.dart';
// import '../../models/class_detail_model.dart';
// import 'student_management_page.dart';
//
// class ClassManagementPage extends StatefulWidget {
//   const ClassManagementPage({super.key});
//
//   @override
//   State<ClassManagementPage> createState() => _ClassManagementPageState();
// }
//
// class _ClassManagementPageState extends State<ClassManagementPage> {
//   final ApiService _apiService = ApiService();
//
//   // Biến State cho dữ liệu API
//   String? _jwtToken;
//   bool _isLoading = true;
//   Exception? _loadError;
//
//   List<ClassDetail> _allClasses = [];
//   List<ClassDetail> _filteredClasses = [];
//   List<Subject> _allSubjects = []; // Danh sách môn học cho Dropdown
//
//   // Biến Filter
//   // <<< SỬA 2: Đặt là nullable (có thể null) vì nó phụ thuộc vào dữ liệu API >>>
//   Subject? _selectedSubject;
//   String _selectedClassType = 'Tất cả lớp học';
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     // Không gán widget.subject nữa
//     _loadInitialData();
//   }
//
//   // =========================================================================
//   // TẢI DỮ LIỆU BAN ĐẦU (Token, Môn học, Lớp học)
//   // =========================================================================
//   Future<void> _loadInitialData() async {
//     try {
//       final session = UserSession();
//       final token = await session.getToken();
//
//       if (token == null) {
//         throw Exception('Token không khả dụng. Vui lòng đăng nhập lại.');
//       }
//       _jwtToken = token;
//
//       // 1. Tải TẤT CẢ các môn học (cho Dropdown)
//       final subjects = await _apiService.fetchAllMySubjects(_jwtToken!);
//       // 2. Tải TẤT CẢ các lớp học của giảng viên
//       final classes = await _apiService.fetchMyClasses(_jwtToken!);
//
//       if (!mounted) return;
//
//       setState(() {
//         _allSubjects = subjects;
//         _allClasses = classes;
//         _isLoading = false;
//
//         // <<< SỬA 3: Chọn môn học đầu tiên (nếu có) làm giá trị mặc định >>>
//         if (subjects.isNotEmpty) {
//           _selectedSubject = subjects.first;
//         }
//
//         // Bắt đầu lọc lần đầu
//         _filterClasses();
//       });
//
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _loadError = e is Exception ? e : Exception(e.toString());
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // =========================================================================
//   // LOGIC LỌC DỮ LIỆU (Đã sửa để xử lý _selectedSubject là nullable)
//   // =========================================================================
//   void _filterClasses() {
//     // Chỉ lọc khi dữ liệu đã được tải và có môn học để lọc
//     if (_allSubjects.isEmpty || _selectedSubject == null) {
//       setState(() => _filteredClasses = []);
//       return;
//     }
//
//     setState(() {
//       _filteredClasses = _allClasses.where((cls) {
//
//         // Lọc theo Môn học (Chỉ hiển thị các lớp thuộc _selectedSubject)
//         final subjectMatch = cls.subjectCode.contains(_selectedSubject!.code);
//
//         // Lọc theo Loại lớp học
//         final typeMatch = _selectedClassType == 'Tất cả lớp học' || cls.type == _selectedClassType;
//
//         // Lọc theo Tìm kiếm
//         final searchMatch = _searchQuery.isEmpty ||
//             cls.classCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             cls.room.toLowerCase().contains(_searchQuery.toLowerCase());
//
//         return subjectMatch && typeMatch && searchMatch;
//       }).toList();
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       // Giữ nguyên Loading
//       return Scaffold(
//         appBar: AppBar(title: const Text('Quản lý lớp học', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0D47A1), iconTheme: const IconThemeData(color: Colors.white)),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     if (_loadError != null) {
//       // Giữ nguyên Lỗi
//       return Scaffold(
//         appBar: AppBar(title: const Text('Quản lý lớp học', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0D47A1), iconTheme: const IconThemeData(color: Colors.white)),
//         body: Center(child: Text('Lỗi tải dữ liệu: ${_loadError!.toString()}')),
//       );
//     }
//
//     // Nếu không có môn học nào được phân công
//     if (_allSubjects.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Quản lý lớp học', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0D47A1), iconTheme: const IconThemeData(color: Colors.white)),
//         body: const Center(child: Text('Bạn chưa được phân công môn học nào để quản lý.')),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: const Text('Quản lý lớp học', style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xFF0D47A1),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               // Hiển thị tên môn học đang được chọn
//               _selectedSubject != null ? _selectedSubject!.name : 'Chọn Môn học',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildFilterCard(),
//             const SizedBox(height: 16),
//
//             // Danh sách lớp học
//             ListView.builder(
//               itemCount: _filteredClasses.length,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return _buildClassCard(_filteredClasses[index]);
//               },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // =========================================================================
//   // WIDGETS
//   // =========================================================================
//
//   Widget _buildFilterCard() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<Subject>(
//                     // <<< SỬA 4: Sử dụng _selectedSubject là nullable >>>
//                     value: _selectedSubject,
//                     decoration: _inputDecoration('Môn học'),
//                     items: _allSubjects.map((Subject subject) {
//                       return DropdownMenuItem<Subject>(
//                         value: subject,
//                         child: Text(subject.name, overflow: TextOverflow.ellipsis),
//                       );
//                     }).toList(),
//                     onChanged: (Subject? newValue) {
//                       setState(() {
//                         _selectedSubject = newValue;
//                         _filterClasses(); // Lọc lại khi đổi môn
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedClassType,
//                     decoration: _inputDecoration('Lớp học'),
//                     items: ['Tất cả lớp học', 'Lý thuyết', 'Thực hành']
//                         .map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedClassType = newValue!;
//                         _filterClasses(); // Lọc lại khi đổi loại lớp
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               decoration: _inputDecoration('Tìm kiếm').copyWith(
//                 prefixIcon: const Icon(Icons.search),
//               ),
//               onChanged: (value) {
//                 _searchQuery = value;
//                 _filterClasses(); // Lọc lại khi gõ tìm kiếm
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildClassCard(ClassDetail cls) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   cls.classCode,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   style: TextButton.styleFrom(
//                     backgroundColor: const Color(0xFFE3F2FD),
//                     foregroundColor: const Color(0xFF0D47A1),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     minimumSize: const Size(0, 30),
//                   ),
//                   child: Text(
//                     '${cls.studentCount} sinh viên',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//             Text(
//               cls.subjectCode,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Niên khóa: ${cls.academicYear}',
//               style: TextStyle(fontSize: 14, color: Colors.grey[800]),
//             ),
//             Text(
//               '${cls.room} • ${cls.type}',
//               style: TextStyle(fontSize: 14, color: Colors.grey[800]),
//             ),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       // Truyền ClassDetail hợp lệ
//                       builder: (context) => StudentManagementPage(classDetail: cls),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Quản lý sinh viên',
//                       style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(Icons.arrow_forward, size: 16, color: Colors.blue[700]),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: Colors.grey[50],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     );
//   }
// }