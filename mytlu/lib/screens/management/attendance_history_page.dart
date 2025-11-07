// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../models/class_model.dart'; // Dùng lại model lớp học
// import 'attendance_detail_page.dart'; // Trang chi tiết (sẽ tạo ở bước 3)
//
// class AttendanceHistoryPage extends StatefulWidget {
//   const AttendanceHistoryPage({super.key});
//
//   @override
//   State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
// }
//
// class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
//   // Dữ liệu giả lập
//   // Chúng ta sẽ dùng List<dynamic> để chứa cả String (ngày) và ClassModel (lớp)
//   final List<dynamic> _items = [
//     "Thứ 6, 19/09/2025",
//     ClassModel(
//       code: 'CSE441.Mobile Dev',
//       name: 'Mobile Dev',
//       room: 'Phòng 305 - B5',
//       lecturer: 'Nguyễn Văn A',
//       time: '08:00 - 09:30',
//       status: 'Đang diễn ra',
//     ),
//     "Thứ 5, 18/09/2025",
//     ClassModel(
//       code: 'CSE123.Mạng máy tính',
//       name: 'Mạng máy tính',
//       room: 'Phòng 305 - B5',
//       lecturer: 'Nguyễn Văn A',
//       time: '08:00 - 09:30',
//       status: 'Đã kết thúc',
//     ),
//     ClassModel(
//       code: 'CSE456.Lập trình Python',
//       name: 'Lập trình Python',
//       room: 'Phòng 305 - B5',
//       lecturer: 'Nguyễn Văn A',
//       time: '07:00 - 08:00',
//       status: 'Đã kết thúc',
//     ),
//     // Thêm các ngày và lớp khác ở đây...
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: const Text('Quản lý điểm danh',
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xFF0D47A1),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           // Khung Filter
//           _buildFilterSection(),
//           // Danh sách
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _items.length,
//               itemBuilder: (context, index) {
//                 final item = _items[index];
//                 // Nếu item là String, build header ngày
//                 if (item is String) {
//                   return _buildDateHeader(item);
//                 }
//                 // Nếu item là ClassModel, build card lớp học
//                 if (item is ClassModel) {
//                   return _buildClassCard(item);
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget cho khung Filter (Chọn ngày, Tìm kiếm)
//   Widget _buildFilterSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           DropdownButtonFormField<String>(
//             value: 'Tất cả các ngày',
//             decoration: _inputDecoration('Chọn ngày'),
//             items: ['Tất cả các ngày', 'Hôm nay', 'Hôm qua']
//                 .map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {},
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             decoration: _inputDecoration('Tìm kiếm').copyWith(
//               prefixIcon: const Icon(Icons.search),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget cho tiêu đề ngày
//   Widget _buildDateHeader(String date) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 12),
//       child: Text(
//         date,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   // Widget cho thẻ lớp học (giống thiết kế)
//   Widget _buildClassCard(ClassModel cls) {
//     final bool isFinished = cls.status == 'Đã kết thúc';
//     final Color statusColor =
//     isFinished ? Colors.grey[600]! : Colors.green[700]!;
//
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
//                 Expanded(
//                   child: Text(
//                     cls.name,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Text(
//                   cls.status,
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: statusColor,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               cls.room,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
//                     const SizedBox(width: 4),
//                     Text(
//                       cls.time,
//                       style: TextStyle(fontSize: 14, color: Colors.grey[800]),
//                     ),
//                   ],
//                 ),
//                 // Nút "Quản lý điểm danh"
//                 TextButton(
//                   onPressed: () {
//                     // Chuyển sang trang chi tiết
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             AttendanceDetailPage(classInfo: cls),
//                       ),
//                     );
//                   },
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Quản lý điểm danh',
//                         style: TextStyle(
//                             color: Colors.blue[700],
//                             fontWeight: FontWeight.w600),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(Icons.arrow_forward_ios,
//                           size: 14, color: Colors.blue[700]),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper cho InputDecoration
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