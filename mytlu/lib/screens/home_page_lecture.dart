import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// Thay thế bằng đường dẫn chính xác của bạn
import '../models/schedule_session_dto.dart';
import '../models/session_data.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'qr/create_qr_page.dart'; // Trang tạo QR

// Màu sắc chính (Giữ nguyên)
const Color tluPrimaryColor = Color(0xFF0D47A1);
const Color tluAccentColor = Color(0xFF42A5F5);

// =========================================================================
// HOMEPAGE KHÔNG CẦN THAM SỐ VÀ TỰ ĐỘNG LẤY DL
// =========================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<ScheduleSession>> _classesFuture;
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  DateTime _selectedDate = DateTime.now();

  String? _jwtToken;
  String? _lecturerName;
  bool _isDataLoaded = false;

  // <<< THÊM: Lưu trữ tóm tắt lịch (Số lượng lớp) cho 7 ngày
  Map<String, int> _scheduleSummary = {}; // Key: 'YYYY-MM-DD', Value: Count

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // =========================================================================
  // HÀM KHỞI TẠO DỮ LIỆU CHÍNH (TẢI TOKEN VÀ TÊN)
  // =========================================================================
  Future<void> _initializeData() async {
    try {
      final session = await _userSession.getSession();

      if (session['token'] == null || session['fullName'] == null) {
        if (mounted) {
          // TODO: Thay thế bằng điều hướng về LoginScreen
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không tìm thấy session. Vui lòng đăng nhập!'))
          );
        }
        return;
      }

      setState(() {
        _jwtToken = session['token'];
        _lecturerName = session['fullName'];
        _isDataLoaded = true;
      });

      // 1. Tải lịch 7 ngày (sau khi có token)
      await _fetchScheduleSummary();

      // 2. Tải lớp học cho ngày hôm nay (mặc định)
      _loadClassesForDate(_selectedDate);

    } catch (e) {
      debugPrint('Lỗi khởi tạo dữ liệu: $e');
      setState(() {
        _isDataLoaded = true;
        _classesFuture = Future.error('Lỗi tải dữ liệu người dùng: $e');
      });
    }
  }

  // =========================================================================
  // <<< HÀM MỚI: TẢI SỐ LƯỢNG LỚP TRONG 7 NGÀY TỚI >>>
  // =========================================================================
  Future<void> _fetchScheduleSummary() async {
    if (_jwtToken == null) return;

    final Map<String, int> summary = {};
    final DateTime now = DateTime.now();

    // Tải cho 7 ngày tới (bao gồm hôm nay)
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      try {
        // Gọi API mới (sử dụng fetchScheduleByDate đã thêm vào ApiService)
        final sessions = await _apiService.fetchScheduleByDate(_jwtToken!, date);
        summary[formattedDate] = sessions.length;
      } catch (e) {
        debugPrint('Lỗi tải lịch ngày $formattedDate: $e');
        summary[formattedDate] = 0; // Đặt là 0 nếu có lỗi
      }
    }

    if (mounted) {
      setState(() {
        _scheduleSummary = summary;
      });
    }
  }


  // =========================================================================
  // HÀM TẢI DỮ LIỆU LỚP HỌC CHO NGÀY ĐƯỢC CHỌN
  // =========================================================================
  void _loadClassesForDate(DateTime date) {
    if (_jwtToken == null) return;

    setState(() {
      _selectedDate = date;
      // <<< SỬA: Dùng API mới để lấy đúng lịch của ngày được chọn
      _classesFuture = _apiService.fetchScheduleByDate(_jwtToken!, date);
    });
  }

  // =========================================================================
  // HÀM XỬ LÝ KHI NHẤN NÚT "TẠO QR"
  // =========================================================================
  Future<void> _handleStartAttendance(String sessionId) async {
    if (_jwtToken == null || !mounted) return;

    try {
      // 1. TẢI THÔNG TIN SESSION CHI TIẾT
      final url = Uri.parse('https://mytlu.thanglele.cloud/api/v1/sessions/$sessionId');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $_jwtToken',
      });

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body); // Dữ liệu chi tiết

        // 2. ĐIỀU HƯỚNG SANG TRANG TẠO QR
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              // CreateQrPage sẽ tự gọi API start-attendance
              builder: (_) => CreateQrPage(sessionId: sessionId),
            ),
          ).then((_) {
            // 3. Tải lại danh sách sau khi quay lại (để cập nhật trạng thái)
            _loadClassesForDate(_selectedDate);
            // 4. Tải lại tóm tắt lịch (cần thiết nếu trạng thái session ảnh hưởng đến số lượng lớp chưa hoàn thành)
            _fetchScheduleSummary();
          });
        }
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi không xác định.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở trang tạo QR: ${e.toString().split(':')[1].trim()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isSameDay(DateTime dateA, DateTime dateB) {
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: tluPrimaryColor),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildCustomAppBar(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch giảng dạy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 10),
                  _buildTeachingSchedule(), // <<< ĐÃ SỬ DỤNG DỮ LIỆU THẬT
                  const SizedBox(height: 20),
                  Text(
                    _isSameDay(_selectedDate, DateTime.now())
                        ? 'Lớp học hôm nay'
                        : 'Lớp học ngày ${DateFormat.Md('vi_VN').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildClassesList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // =========================================================================
  // WIDGET 2: LỊCH GIẢNG DẠY (ĐÃ SỬA ĐỂ DÙNG DỮ LIỆU THẬT)
  // =========================================================================
  Widget _buildTeachingSchedule() {
    final List<DateTime> days = List.generate(
      7,
          (index) => DateTime.now().add(Duration(days: index)),
    );

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final bool isActive = _isSameDay(date, _selectedDate);
          final formattedDate = DateFormat('yyyy-MM-dd').format(date);

          // <<< LẤY SỐ LƯỢNG LỚP TỪ STATE >>>
          final int classCount = _scheduleSummary[formattedDate] ?? 0;

          return GestureDetector(
            onTap: () {
              _loadClassesForDate(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isActive ? tluAccentColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('vi_VN').format(date),
                    style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.d().format(date),
                    style: TextStyle(color: isActive ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // <<< HIỂN THỊ SỐ LƯỢNG LỚP THẬT >>>
                  Text(
                    '$classCount',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ... (Các widgets khác giữ nguyên) ...
  Widget _buildCustomAppBar(BuildContext context) {
    // Code giữ nguyên (sử dụng _lecturerName)
    // ...
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
      decoration: const BoxDecoration(
        color: tluPrimaryColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('My TLU', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28), onPressed: () {}),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.white, backgroundImage: AssetImage('assets/images/avatar_placeholder.png')),
              const SizedBox(width: 15),
              Text(_lecturerName ?? 'Loading...', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList() {
    // Code giữ nguyên (sử dụng _classesFuture)
    // ...
    return FutureBuilder<List<ScheduleSession>>(
      future: _classesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: tluPrimaryColor)));
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Không có lịch giảng dạy cho ngày này.', style: TextStyle(fontSize: 16))));
        } else {
          final classes = snapshot.data!;
          return Column(
            children: classes.map((cls) {
              return ClassCard(
                data: cls,
                lecturerName: _lecturerName ?? 'Giảng viên',
                onStartAttendance: () => _handleStartAttendance(cls.classSessionId.toString()),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildBottomNavBar() {
    // Code giữ nguyên
    // ...
    return Container(
      decoration: const BoxDecoration(color: tluPrimaryColor),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) { setState(() { _selectedIndex = index; }); },
          type: BottomNavigationBarType.fixed,
          backgroundColor: tluPrimaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Quản lý'),
            BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: 'Thống kê'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET CLASSCARD (Giữ nguyên)
// =========================================================================
class ClassCard extends StatelessWidget {
  final ScheduleSession data;
  final String lecturerName;
  final VoidCallback onStartAttendance;

  const ClassCard({super.key, required this.data, required this.lecturerName, required this.onStartAttendance});

  Map<String, dynamic> _getStatusInfo(String status) {
    if (status == 'in_progress') return {'text': 'Đang diễn ra', 'color': Colors.green[700]!};
    if (status == 'pending') return {'text': 'Sắp diễn ra', 'color': Colors.orange[700]!};
    return {'text': 'Đã kết thúc', 'color': Colors.grey};
  }

  String _formatTime(DateTime start, DateTime end) {
    return '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
  }

  Widget _buildActionButton(String status) {
    bool isActive = status == 'in_progress' || status == 'pending';
    String buttonText;
    IconData buttonIcon;

    if (status == 'completed') {
      buttonText = 'Đã kết thúc';
      buttonIcon = Icons.check_circle_outline;
    } else {
      buttonText = 'Tạo QR';
      buttonIcon = Icons.qr_code;
    }

    return ElevatedButton.icon(
      onPressed: isActive ? onStartAttendance : null,
      icon: Icon(buttonIcon, size: 16),
      label: Text(buttonText, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isActive ? tluAccentColor : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 30),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(data.attendanceStatus);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(data.className, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Text(statusInfo['text']!, style: TextStyle(fontSize: 12, color: statusInfo['color']!, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${data.location} • $lecturerName', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(_formatTime(data.startTime, data.endTime), style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                ]),
                _buildActionButton(data.attendanceStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}