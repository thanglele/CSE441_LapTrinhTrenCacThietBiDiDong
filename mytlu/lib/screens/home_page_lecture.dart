import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';
import 'create_qr_page.dart';

// Màu sắc đã định nghĩa
const Color tluPrimaryColor = Color(0xFF0D47A1);
const Color tluAccentColor = Color(0xFF42A5F5);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // Biến trạng thái mới: Theo dõi ngày được chọn (mặc định là hôm nay)
  DateTime _selectedDate = DateTime.now();
  late Future<List<ClassModel>> _todayClassesFuture;
  final ApiService _apiService = ApiService();

  // TODO: Thay thế bằng dữ liệu người dùng và token thực tế sau khi đăng nhập
  final String _lecturerId = 'GV001';
  final String _jwtToken = 'YOUR_ACTUAL_JWT_TOKEN';
  final String _lecturerName = 'Nguyễn Thị Dinh';

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future với ngày hiện tại
    _todayClassesFuture = _apiService.fetchClassesForDate(_lecturerId, _jwtToken, _selectedDate);
  }

  // Hàm mới: Tải lại dữ liệu khi ngày được chọn thay đổi
  void _loadClassesForSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      // Gọi API với ngày mới được chọn
      _todayClassesFuture = _apiService.fetchClassesForDate(_lecturerId, _jwtToken, _selectedDate);
    });
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
                  child: Icon(Icons.person, color: tluPrimaryColor, size: 35),
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
  // WIDGET 2: LỊCH GIẢNG DẠY (DATE PICKER) - Đã sửa để có thể chọn
  // =========================================================================
  Widget _buildTeachingSchedule() {
    // Tạo danh sách 7 ngày, bắt đầu từ hôm nay
    List<DateTime> weekDays = List.generate(7, (index) {
      return DateTime.now().add(Duration(days: index));
    });

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          // Kiểm tra xem ngày này có phải là ngày đang được chọn không
          final bool isActive = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          // Định dạng hiển thị (vi: Tiếng Việt)
          final String dayName = DateFormat('EEE', 'vi').format(date).replaceAll('.', '');
          final String dateNum = DateFormat('dd').format(date);

          return GestureDetector(
            onTap: () => _loadClassesForSelectedDate(date), // Xử lý sự kiện chọn
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
                    dayName,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateNum,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Giả lập số lớp học
                  Text(
                    '${index + 1}',
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
          return const Center(child: Text('Ngày này không có lịch giảng dạy.', style: TextStyle(fontSize: 16)));
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
        // Đã sửa lỗi Undefined name
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
  Widget _buildActionButton(String status, BuildContext context) {
    bool isActive = status == 'Đang diễn ra' || status == 'Sắp diễn ra';

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
      onPressed: isActive
          ? () {
        // Dẫn link sang trang Tạo QR và truyền dữ liệu cần thiết
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => CreateQrPage(
              sessionData: SessionData(
                subjectName: data.name,
                room: data.room,
                className: data.code,
                scheduleTime: data.time,
                date: DateFormat('dd/MM/yyyy').format(DateTime.now()), // Ngày hiện tại
              ),
            ),
          ),
        );
      }
          : null,
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
                _buildActionButton(data.status, context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}