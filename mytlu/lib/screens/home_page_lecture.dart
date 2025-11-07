import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';
import 'create_qr_page.dart';
import 'management/management_dashboard_page.dart';

const Color tluPrimaryColor = Color(0xFF0D47A1);
const Color tluAccentColor = Color(0xFF42A5F5);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Dán đè toàn bộ class _HomePageState
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  late Future<List<ClassModel>> _todayClassesFuture;
  final ApiService _apiService = ApiService();

  final String _lecturerId = 'GV001';
  final String _jwtToken = 'YOUR_ACTUAL_JWT_TOKEN';
  final String _lecturerName = 'Nguyễn Thị Dinh';

  // === SỬA 1: XÓA 'late final List<Widget> _pages;' ở đây ===

  @override
  void initState() {
    super.initState();
    // === SỬA 2: CHỈ khởi tạo dữ liệu, KHÔNG build widget ===
    _todayClassesFuture =
        _apiService.fetchClassesForDate(_lecturerId, _jwtToken, _selectedDate);
    // (Xóa danh sách _pages khỏi đây)
  }

  void _loadClassesForSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _todayClassesFuture =
          _apiService.fetchClassesForDate(_lecturerId, _jwtToken, _selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // === SỬA 3: KHAI BÁO _pages bên trong hàm build() ===
    final List<Widget> _pages = [
      _buildHomePageContent(), // Gọi ở đây thì context đã hợp lệ
      const ManagementDashboardPage(),
      const Center(child: Text('Trang Thống kê (chưa code)')),
      const Center(child: Text('Trang Cá nhân (chưa code)')),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Dùng danh sách _pages vừa tạo
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomePageContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildCustomAppBar(context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const Text(
                  'Lớp học hôm nay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildClassesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                const Text(
                  'My TLU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
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

  Widget _buildTeachingSchedule() {
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
          final bool isActive = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          final String dayName =
          DateFormat('EEE', 'vi').format(date).replaceAll('.', '');
          final String dateNum = DateFormat('dd').format(date);

          return GestureDetector(
            onTap: () => _loadClassesForSelectedDate(date),
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

  Widget _buildClassesList() {
    return FutureBuilder<List<ClassModel>>(
      future: _todayClassesFuture,
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
              child: Text('Ngày này không có lịch giảng dạy.',
                  style: TextStyle(fontSize: 16)));
        } else {
          final classes = snapshot.data!;
          return Column(
            children: classes.map((cls) => ClassCard(data: cls)).toList(),
          );
        }
      },
    );
  }

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

class ClassCard extends StatelessWidget {
  final ClassModel data;

  const ClassCard({super.key, required this.data});

  Color _getStatusColor(String status) {
    if (status == 'Đang diễn ra') return Colors.green[700]!;
    if (status == 'Sắp diễn ra') return Colors.orange[700]!;
    return Colors.grey;
  }

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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => CreateQrPage(
              sessionData: SessionData(
                subjectName: data.name,
                room: data.room,
                className: data.code,
                scheduleTime: data.time,
                date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
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
            Text(
              '${data.room} • ${data.lecturer}',
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