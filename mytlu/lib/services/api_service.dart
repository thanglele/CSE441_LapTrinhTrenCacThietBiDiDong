// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/class_model.dart';

class ApiService {
  static const String _baseUrl = 'https://your-dotnet-api.com/api/lecturer';

  // Dữ liệu giả lập
  final List<Map<String, dynamic>> _dummyData = [
    {
      'classCode': '64KTPM3',
      'subjectName': 'Mobile Dev',
      'room': '305 - B5',
      'lecturerName': 'Nguyễn Văn A',
      'startTime': '08:00',
      'endTime': '09:30',
      'status': 'Đang diễn ra',
    },
    {
      'classCode': '63PM-01',
      'subjectName': 'Lập trình C++',
      'room': '305 - B5',
      'lecturerName': 'Nguyễn Văn B',
      'startTime': '09:45',
      'endTime': '11:00',
      'status': 'Sắp diễn ra',
    },
    {
      'classCode': '64TT-02',
      'subjectName': 'Lập trình python',
      'room': '401 - C1',
      'lecturerName': 'Nguyễn Văn C',
      'startTime': '07:00',
      'endTime': '07:50',
      'status': 'Đã kết thúc',
    },
  ];

  Future<List<ClassModel>> fetchClassesForDate(
      String lecturerId, String jwtToken, DateTime date) async {

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Giả lập độ trễ API
    await Future.delayed(const Duration(seconds: 1));

    if (formattedDate == todayFormatted) {
      // Trả về dữ liệu giả lập cho hôm nay
      return _dummyData.map((json) => ClassModel.fromJson(json)).toList();
    } else {
      // Trả về dữ liệu rỗng nếu là ngày khác
      return [];
    }

  }
}