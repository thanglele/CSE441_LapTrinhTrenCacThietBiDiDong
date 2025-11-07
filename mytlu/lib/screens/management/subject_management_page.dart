// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // Cần thiết cho API Service
// import 'dart:convert';
// import 'class_management_page.dart';
// import '../../models/subject_model.dart';
// // <<< THÊM CÁC SERVICE >>>
// import '../../services/api_service.dart';
// import '../../services/user_session.dart';
//
// class SubjectManagementPage extends StatefulWidget {
//   const SubjectManagementPage({super.key});
//
//   @override
//   State<SubjectManagementPage> createState() => _SubjectManagementPageState();
// }
//
// class _SubjectManagementPageState extends State<SubjectManagementPage> {
//   late Future<List<Subject>> _subjectsFuture;
//   final ApiService _apiService = ApiService();
//
//   // Lưu token đã tải
//   String? _jwtToken;
//
//   // Danh sách dữ liệu giả lập (Đã bị loại bỏ)
//   // final List<Subject> _subjects = [...];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSubjectsData();
//   }
//
//   // =========================================================================
//   // TẢI TOKEN VÀ GỌI API THẬT
//   // =========================================================================
//   Future<void> _loadSubjectsData() async {
//     try {
//       final session = UserSession();
//       final token = await session.getToken();
//
//       if (token == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Vui lòng đăng nhập lại để xem môn học.'), backgroundColor: Colors.red),
//           );
//         }
//         setState(() {
//           _subjectsFuture = Future.error('Token không khả dụng');
//         });
//         return;
//       }
//
//       setState(() {
//         _jwtToken = token;
//         // Bắt đầu gọi API thật
//         _subjectsFuture = _apiService.fetchMySubjects(token);
//       });
//
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _subjectsFuture = Future.error('Lỗi tải dữ liệu: $e');
//         });
//       }
//     }
//   }
//
//   // =========================================================================
//   // GIAO DIỆN CHÍNH (Sử dụng FutureBuilder)
//   // =========================================================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: const Text('Quản lý môn học', style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xFF0D47A1),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Thanh tìm kiếm
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Tìm kiếm',
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Danh sách môn học (SỬA: Dùng FutureBuilder)
//             Expanded(
//               child: FutureBuilder<List<Subject>>(
//                 future: _subjectsFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Lỗi tải môn học: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(child: Text('Bạn chưa được phân công môn học nào.'));
//                   }
//
//                   final subjects = snapshot.data!;
//
//                   return ListView.builder(
//                     itemCount: subjects.length,
//                     itemBuilder: (context, index) {
//                       return _buildSubjectCard(subjects[index]);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget helper để xây dựng card cho mỗi môn học
//   Widget _buildSubjectCard(Subject subject) {
//     // Lỗi 'subject' is required không xảy ra ở đây, mà ở nơi ClassManagementPage được định nghĩa.
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Cột thông tin bên trái
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   subject.name,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   // Giả sử Model Subject có credits và code
//                   '${subject.code} • ${subject.credits} tín chỉ',
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//
//             // Nút quản lý bên phải
//             TextButton(
//               onPressed: () {
//                 // Hành động điều hướng mới
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     // Truyền môn học (subject) mà người dùng đã bấm
//                     builder: (context) => ClassManagementPage(),
//                   ),
//                 );
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: const Color(0xFFE3F2FD),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//               child: Row(
//                 children: [
//                   Text(
//                     // Giả sử Model Subject có classCount
//                     '${subject.classCount.toString().padLeft(2, '0')} lớp',
//                     style: const TextStyle(
//                       color: Color(0xFF0D47A1),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF0D47A1)),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }