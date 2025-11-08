// import 'package:flutter/material.dart';
// // Import Model và Service của bạn
// import 'package:mytlu/Students/profile/models/student_profile.dart';
// import 'package:mytlu/Students/profile/services/profile_service.dart';
//
// /// Màn hình này chỉ dùng để Test xem API GET /auth/me có chạy không
// class ApiTestScreen extends StatefulWidget {
//   const ApiTestScreen({Key? key}) : super(key: key);
//
//   @override
//   _ApiTestScreenState createState() => _ApiTestScreenState();
// }
//
// class _ApiTestScreenState extends State<ApiTestScreen> {
//   final ProfileService _profileService = ProfileService();
//   late Future<StudentProfile> _profileFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     // Bắt đầu gọi API ngay khi màn hình được mở
//     _profileFuture = _profileService.getStudentProfile();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Kiểm tra API GET /auth/me"),
//       ),
//       body: FutureBuilder<StudentProfile>(
//         future: _profileFuture,
//         builder: (context, snapshot) {
//
//           // Trạng thái 1: ĐANG TẢI (chờ API)
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),
//                   Text("Đang gọi API..."),
//                 ],
//               ),
//             );
//           }
//
//           // Trạng thái 2: BỊ LỖI
//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   "LỖI: ${snapshot.error.toString()}",
//                   style: TextStyle(color: Colors.red, fontSize: 18),
//                 ),
//               ),
//             );
//           }
//
//           // Trạng thái 3: THÀNH CÔNG
//           if (snapshot.hasData) {
//             final profile = snapshot.data!;
//
//             // HIỂN THỊ DỮ LIỆU THẬT TỪ API
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("API Test THÀNH CÔNG!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
//                   SizedBox(height: 20),
//                   Text("Student Code: ${profile.studentCode}", style: TextStyle(fontSize: 18)),
//                   Text("Full Name: ${profile.fullName}", style: TextStyle(fontSize: 18)),
//                   Text("Admin Class: ${profile.adminClass}", style: TextStyle(fontSize: 18)),
//                   Text("Major Name: ${profile.majorName}", style: TextStyle(fontSize: 18)),
//                   Text("Face Status: ${profile.faceDataStatus}", style: TextStyle(fontSize: 18)),
//                 ],
//               ),
//             );
//           }
//
//           return Center(child: Text('Không có dữ liệu.'));
//         },
//       ),
//     );
//   }
// }