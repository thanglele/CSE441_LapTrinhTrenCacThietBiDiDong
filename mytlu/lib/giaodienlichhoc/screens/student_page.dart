import 'package:flutter/material.dart';
import '../models/lop_hoc.dart';
import '../widgets/lop_hoc_card.dart';
import '../widgets/header.dart';
import '../widgets/lich_hoc_tuan.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int _currentIndex = 0;

  final List<LopHoc> lopHocHomNay = [
    LopHoc(
      tenLop: "CSE441.Mobile Dev",
      phong: "Phòng 305 - B5",
      giangVien: "Nguyễn Văn A",
      thoiGian: "08:50 - 09:40",
      trangThai: TrangThaiLopHoc.dangDienRa,
    ),
    LopHoc(
      tenLop: "Lập trình C++",
      phong: "Phòng 305 - B5",
      giangVien: "Nguyễn Văn B",
      thoiGian: "09:45 - 10:35",
      trangThai: TrangThaiLopHoc.sapDienRa,
    ),
    LopHoc(
      tenLop: "Lập trình Python",
      phong: "Phòng 305 - B5",
      giangVien: "Nguyễn Văn C",
      thoiGian: "07:55 - 08:45",
      trangThai: TrangThaiLopHoc.daKetThuc_DaDiemDanh,
    ),
    LopHoc(
      tenLop: "Trí tuệ nhân tạo",
      phong: "Phòng 305 - B5",
      giangVien: "Nguyễn Văn D",
      thoiGian: "07:00 - 07:50",
      trangThai: TrangThaiLopHoc.daKetThuc_ChuaDiemDanh,
    ),
  ];

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  // Build pages dynamically so UI updates when selectedDate changes.
  List<Widget> get _pages {
    return [
      SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Header(),
                LichHocTuan(
                  onSelectDate: (newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Lớp học hôm nay",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ensure "Đang diễn ra" appears at top
                Builder(builder: (context) {
                  final displayed = List<LopHoc>.from(lopHocHomNay)
                    ..sort((a, b) {
                      int order(TrangThaiLopHoc t) {
                        switch (t) {
                          case TrangThaiLopHoc.dangDienRa:
                            return 0;
                          case TrangThaiLopHoc.sapDienRa:
                            return 1;
                          case TrangThaiLopHoc.daKetThuc_DaDiemDanh:
                            return 2;
                          case TrangThaiLopHoc.daKetThuc_ChuaDiemDanh:
                            return 3;
                        }
                      }
                      return order(a.trangThai).compareTo(order(b.trangThai));
                    });

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayed.length,
                    itemBuilder: (context, index) {
                      return LopHocCard(lopHoc: displayed[index]);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      const Center(child: Text("Quét QR - Chức năng sắp có")),
      const Center(child: Text("Lịch sử - Chức năng sắp có")),
      const Center(child: Text("Hồ sơ - Chức năng sắp có")),
    ];
  }

  String _getFormattedDate() {
    final now = selectedDate;
    final weekdayNames = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];
    final weekday = weekdayNames[now.weekday % 7];
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$weekday, $day/$month/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2E64A5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Lịch học",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: "Quét QR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Lịch sử",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Hồ sơ",
          ),
        ],
      ),
    );
  }
}
