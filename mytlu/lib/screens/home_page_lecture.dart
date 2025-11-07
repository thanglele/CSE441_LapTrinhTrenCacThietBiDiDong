import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Đảm bảo đã import và gọi ở main.dart
// Thay thế bằng đường dẫn chính xác của bạn
import '../models/schedule_session_dto.dart';
import '../services/api_service.dart';
// <<< SỬA: Dùng UserSession để lấy token đã lưu
import '../services/user_session.dart';
import 'home/create_qr_page.dart';

// Màu sắc chính (Giữ nguyên)
const Color tluPrimaryColor = Color(0xFF0D47A1);
const Color tluAccentColor = Color(0xFF42A5F5);

// =========================================================================
// <<< SỬA 1: BỎ THAM SỐ TRUYỀN VÀO (jwtToken, lecturerName)
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
  final UserSession _userSession = UserSession(); // Khởi tạo session service

  DateTime _selectedDate = DateTime.now();

  // <<< SỬA 2: Biến State mới để lưu Token và Tên người dùng đã được tải
  String? _jwtToken;
  String? _lecturerName;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Bắt đầu quá trình tải token và dữ liệu ban đầu
    _initializeData();
  }

  // =========================================================================
  // <<< SỬA 3: HÀM KHỞI TẠO DỮ LIỆU CHÍNH
  // =========================================================================
  Future<void> _initializeData() async {
    try {
      final session = await _userSession.getSession(); // Lấy session đã lưu

      if (session['token'] == null || session['fullName'] == null) {
        // Nếu không có session hợp lệ, chuyển về màn hình Login
        // TODO: Cần thêm logic điều hướng về LoginScreen nếu session null/hết hạn
        print('Lỗi: Không tìm thấy Token hợp lệ. Cần chuyển về Login!');
        return;
      }

      setState(() {
        _jwtToken = session['token'];
        _lecturerName = session['fullName'];
        _isDataLoaded = true;
      });

      // Tải lịch học sau khi có token
      _loadClassesForDate(_selectedDate);

    } catch (e) {
      print('Lỗi khởi tạo dữ liệu: $e');
      // Xử lý lỗi (ví dụ: hiển thị thông báo)
      setState(() {
        _isDataLoaded = true; // Dù lỗi nhưng kết thúc tải
        _classesFuture = Future.error('Lỗi tải dữ liệu người dùng: $e');
      });
    }
  }


  // =========================================================================
  // HÀM TẢI DỮ LIỆU LỚP HỌC THEO NGÀY (Dùng _jwtToken đã tải)
  // =========================================================================
  void _loadClassesForDate(DateTime date) {
    if (_jwtToken == null) return; // Bảo vệ nếu token chưa được tải

    setState(() {
      _selectedDate = date;
      // Gọi API với _jwtToken đã được tải (state)
      _classesFuture = _apiService.fetchTodayClasses(_jwtToken!);
    });
  }

  // =========================================================================
  // HÀM XỬ LÝ KHI NHẤN NÚT "TẠO QR" (Dùng _jwtToken đã tải)
  // =========================================================================
  Future<void> _handleStartAttendance(String sessionId) async {
    if (_jwtToken == null) return; // Bảo vệ nếu token chưa được tải

    try {
      // 🔹 Giả sử bạn đã có dữ liệu buổi học lấy từ API hoặc danh sách hiển thị
      final sessionData = SessionData(
        subjectName: "Lập trình Flutter nâng cao",
        room: "P305",
        className: "D21CQCN04-B",
        scheduleTime: "07:00 - 09:00",
        date: "2025-11-08",
      );

      // 🟢 Điều hướng sang trang tạo QR và truyền dữ liệu
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateQrPage(sessionData: sessionData),
        ),
      );

      print('👉 Đã chuyển sang trang tạo QR cho session $sessionId');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi mở trang tạo QR: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // Hàm helper tiện ích để so sánh ngày
  bool _isSameDay(DateTime dateA, DateTime dateB) {
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading trong khi đang tải token và tên
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
            // 1. App Bar
            _buildCustomAppBar(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Lịch giảng dạy
                  const Text(
                    'Lịch giảng dạy',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  _buildTeachingSchedule(),

                  const SizedBox(height: 20),

                  // 3. Danh sách Lớp học
                  Text(
                    _isSameDay(_selectedDate, DateTime.now())
                        ? 'Lớp học hôm nay'
                        : 'Lớp học ngày ${DateFormat.Md('vi_VN').format(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Hiển thị danh sách lớp học
                  _buildClassesList(),
                ],
              ),
            ),
          ],
        ),
      ),
      // 4. Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // =========================================================================
  // WIDGET 1: CUSTOM APP BAR (Dùng _lecturerName)
  // =========================================================================
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, bottom: 20),
      decoration: const BoxDecoration(
        color: tluPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My TLU',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white, size: 28),
                    onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                  AssetImage('assets/images/avatar_placeholder.png'),
                ),
                const SizedBox(width: 15),
                Text(
                  // <<< SỬA 4: Dùng tên đã tải (có thể là chuỗi rỗng nếu lỗi)
                  _lecturerName ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGET 2: LỊCH GIẢNG DẠY (Lịch động 7 ngày)
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
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.d().format(date),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  // =========================================================================
  // WIDGET 3: HIỂN THỊ DANH SÁCH LỚP HỌC (Dùng _lecturerName)
  // =========================================================================
  Widget _buildClassesList() {
    return FutureBuilder<List<ScheduleSession>>(
      future: _classesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: tluPrimaryColor),
              ));
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text('Lỗi tải dữ liệu: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Không có lịch giảng dạy cho ngày này.',
                    style: TextStyle(fontSize: 16)),
              ));
        } else {
          final classes = snapshot.data!;
          return Column(
            children: classes.map((cls) {
              return ClassCard(
                data: cls,
                // <<< SỬA 5: Dùng tên đã tải (state)
                lecturerName: _lecturerName ?? 'Giảng viên',
                onStartAttendance: () =>
                    _handleStartAttendance(cls.classSessionId.toString()),
              );
            }).toList(),
          );
        }
      },
    );
  }

  // =========================================================================
  // WIDGET 4: BOTTOM NAVIGATION BAR
  // =========================================================================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: tluPrimaryColor,
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: tluPrimaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Quản lý',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET CLASSCARD (Giữ nguyên logic callback)
// =========================================================================
class ClassCard extends StatelessWidget {
  final ScheduleSession data;
  final String lecturerName;
  final VoidCallback onStartAttendance;

  const ClassCard({
    super.key,
    required this.data,
    required this.lecturerName,
    required this.onStartAttendance,
  });

  // ... (Hàm _getStatusInfo, _formatTime giữ nguyên)
  Map<String, dynamic> _getStatusInfo(String status) {
    if (status == 'in_progress') {
      return {'text': 'Đang diễn ra', 'color': Colors.green[700]!};
    }
    if (status == 'pending') {
      return {'text': 'Sắp diễn ra', 'color': Colors.orange[700]!};
    }
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
      label: Text(
        buttonText,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isActive ? tluAccentColor : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
                Expanded(
                  child: Text(
                    data.className,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  statusInfo['text']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusInfo['color']!,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${data.location} • $lecturerName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(data.startTime, data.endTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                _buildActionButton(data.attendanceStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}