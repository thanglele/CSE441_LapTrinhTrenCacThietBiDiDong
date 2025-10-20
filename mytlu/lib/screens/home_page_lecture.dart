import 'package:flutter/material.dart';
// Thay thế bằng đường dẫn chính xác của bạn
import '../models/class_model.dart';
import '../services/api_service.dart';

// Màu sắc chính được sử dụng trong giao diện
const Color tluPrimaryColor = Color(0xFF0D47A1); // Xanh TLU đậm
const Color tluAccentColor = Color(0xFF42A5F5); // Xanh sáng hơn

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<ClassModel>> _todayClassesFuture;
  final ApiService _apiService = ApiService();

  // TODO: Thay thế bằng dữ liệu người dùng và token thực tế sau khi đăng nhập
  final String _lecturerId = 'GV001';
  final String _jwtToken = 'YOUR_ACTUAL_JWT_TOKEN';
  final String _lecturerName = 'Nguyễn Thị Dinh';

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future để tải lịch học ngay khi vào trang
    _todayClassesFuture = _apiService.fetchTodayClasses(_lecturerId, _jwtToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. App Bar và Thông tin người dùng
            _buildCustomAppBar(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Lịch giảng dạy (Horizontal Date Picker)
                  const Text(
                    'Lịch giảng dạy',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTeachingSchedule(),

                  const SizedBox(height: 20),

                  // 3. Danh sách Lớp học hôm nay
                  const Text(
                    'Lớp học hôm nay',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Hiển thị danh sách lớp học sử dụng FutureBuilder
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
  // WIDGET 1: CUSTOM APP BAR (My TLU, Ảnh đại diện, Tên)
  // =========================================================================
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
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
            // Icon Bell và Tiêu đề
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My TLU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Avatar và Tên
            Row(
              children: [
                // Avatar (Giả lập)
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/avatar_placeholder.png'), // Thay thế bằng ảnh thật
                ),
                const SizedBox(width: 15),
                Text(
                  _lecturerName,
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
  // WIDGET 2: LỊCH GIẢNG DẠY (DATE PICKER)
  // =========================================================================
  Widget _buildTeachingSchedule() {
    // Dữ liệu giả lập cho 7 ngày (Chưa fetch từ API)
    final List<Map<String, dynamic>> days = [
      {'date': '22', 'day': 'Th 2', 'active': true, 'count': '9'},
      {'date': '23', 'day': 'Th 3', 'active': false, 'count': '9'},
      {'date': '24', 'day': 'Th 4', 'active': false, 'count': '9'},
      {'date': '25', 'day': 'Th 5', 'active': false, 'count': '9'},
      {'date': '26', 'day': 'Th 6', 'active': false, 'count': '9'},
      {'date': '27', 'day': 'Th 7', 'active': false, 'count': '9'},
      {'date': '28', 'day': 'CN', 'active': false, 'count': '9'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final bool isActive = day['active'] as bool;

          return Container(
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
                  day['day'] as String,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day['date'] as String,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day['count'] as String,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // WIDGET 3: HIỂN THỊ DANH SÁCH LỚP HỌC VỚI FUTUREBUILDER
  // =========================================================================
  Widget _buildClassesList() {
    return FutureBuilder<List<ClassModel>>(
      future: _todayClassesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Trạng thái Loading
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: tluPrimaryColor),
          ));
        } else if (snapshot.hasError) {
          // Trạng thái Lỗi
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Trạng thái Không có dữ liệu
          return const Center(child: Text('Hôm nay không có lịch giảng dạy.', style: TextStyle(fontSize: 16)));
        } else {
          // Trạng thái Thành công, hiển thị dữ liệu
          final classes = snapshot.data!;
          return Column(
            children: classes.map((cls) => ClassCard(data: cls)).toList(),
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
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // TODO: Thêm logic chuyển màn hình tương ứng
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Quản lý',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET CLASSCARD (Thẻ hiển thị thông tin lớp học)
// =========================================================================
class ClassCard extends StatelessWidget {
  final ClassModel data;

  const ClassCard({super.key, required this.data});

  Color _getStatusColor(String status) {
    if (status == 'Đang diễn ra') return Colors.green[700]!;
    if (status == 'Sắp diễn ra') return Colors.orange[700]!;
    return Colors.grey;
  }

  // Xây dựng nút hành động dựa trên trạng thái
  Widget _buildActionButton(String status) {
    bool isActive = status == 'Đang diễn ra' || status == 'Sắp diễn ra';

    // Tùy chỉnh hiển thị text cho nút
    String buttonText;
    IconData buttonIcon;

    if (status == 'Đã kết thúc' || status == 'Đã tạo') {
      buttonText = status == 'Đã tạo' ? 'Đã tạo' : 'Đã kết thúc';
      buttonIcon = Icons.check_circle_outline;
    } else {
      buttonText = 'Tạo QR';
      buttonIcon = Icons.qr_code;
    }

    return ElevatedButton.icon(
      onPressed: isActive ? () { /* Xử lý sự kiện Tạo QR */ } : null,
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
    final statusColor = _getStatusColor(data.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên môn học và Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${data.code}. ${data.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  data.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Phòng học và Giảng viên
            Text(
              '${data.room} • ${data.lecturer}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),

            // Thời gian và Nút Tạo QR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data.time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                _buildActionButton(data.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}