import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/header.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  int _selectedIndex = 1; // bottom nav: 0=Lịch học, 1=Quét QR, ...
  int _countdown = 5;
  Timer? _timer;
  bool _isCounting = false;
  bool _scanSuccess = false;
  bool _cameraGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _cameraGranted = true);
      _startCountdown();
      return;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      setState(() => _cameraGranted = true);
      _startCountdown();
      return;
    }

    // If denied permanently, show dialog with option to open settings
    if (result.isPermanentlyDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Quyền Camera bị từ chối'),
            content: const Text(
              'Bạn cần cấp quyền Camera trong cài đặt để quét mã QR.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('HỦY'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(ctx).pop();
                },
                child: const Text('MỞ CÀI ĐẶT'),
              ),
            ],
          ),
        );
      });
    } else {
      // simple denied (not permanent) — show a snackbar and allow retry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Vui lòng cho phép quyền Camera để quét mã QR.',
            ),
            action: SnackBarAction(
              label: 'YÊU CẦU LẠI',
              onPressed: () => _checkAndRequestCameraPermission(),
            ),
          ),
        );
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdown = 5;
      _isCounting = true;
      _scanSuccess = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown <= 0) {
        t.cancel();
        setState(() {
          _isCounting = false;
          _scanSuccess = true;
        });
        _onScanSuccess();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _onScanSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quét thành công'),
        content: const Text('Mã QR hợp lệ. Điểm danh thành công.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to previous page
            },
            child: const Text('XONG'),
          ),
        ],
      ),
    );
  }

  void _cancelAndBack() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF407CDC),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _cancelAndBack,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Khu vực điểm danh',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          // Placeholder right (could be empty)
          const SizedBox(width: 8),
        ],
      ),
    );
  }
  // ...existing helper widgets (none) ...

  Widget _buildFrameCard() {
    // Outer frame 380 x 550 (we'll let it be responsive but constrain by these sizes)
    return Center(
      child: Container(
        width: 380,
        height: 550,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Title
            const Text(
              'Tìm kiếm mã QR',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            // Use shared Header if you prefer; keep a title inside the card too
            const Text(
              'Tìm kiếm mã QR',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đưa mã QR truy cập điểm danh của bạn vào trong khung hình ở dưới',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),

            // Camera area 320 x 320
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // "Camera feed" simulation (could be a camera preview in real app)
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=8d8c5a9a86f2eb3d3f7d9e7b7be7f7c1',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // semi-transparent blur overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          //  color: Colors.black.withOpacity(0.35),
                          color: Colors.black.withOpacity(
                            _cameraGranted ? 0.35 : 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center clear scanning area (240x240) — show it as a rectangle with border
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.85),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                  ),

                  // Center: countdown number with translucent backdrop
                  Positioned(
                    child: Container(
                      width: 140,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        // Chỉ giữ lại logic này
                        _cameraGranted
                            ? (_isCounting
                                  ? '$_countdown'
                                  : (_scanSuccess ? '0' : ''))
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Ubuntu',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Top-right small badge "Camera hoạt động"
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      // Chỉ giữ lại khối có logic _cameraGranted
                      decoration: BoxDecoration(
                        color: _cameraGranted
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _cameraGranted ? 'Camera hoạt động' : 'Camera bị tắt',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _cameraGranted
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Instruction text under camera
            const Text(
              'Giữ yên 5 giây trong khi chúng tôi xác nhận mã QR truy cập trang điểm danh của bạn...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: _cancelAndBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1D5DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Hủy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    bool active,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: active ? const Color(0xFF407CDC) : Colors.grey),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Choose which item is active: Quét QR index = 1
    return Scaffold(
      backgroundColor: Colors.white,

      // Chỉ giữ lại appBar mà bạn muốn
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: const Header(), // Giả sử 'Header' là widget bạn muốn
      ),
      body: SafeArea(child: Center(child: _buildFrameCard())),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Simulate navigation between menus inside this demo screen.
          // If user taps Lịch học (0) we pop back (simulate), else switch to selection.
          if (index == 0) {
            // go back to schedule
            Navigator.of(context).pop();
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF407CDC),
        unselectedItemColor: Colors.grey,
        items: [
          _buildNavItem(Icons.calendar_today, 'Lịch học', _selectedIndex == 0),
          _buildNavItem(Icons.qr_code, 'Quét QR', _selectedIndex == 1),
          _buildNavItem(Icons.history, 'Lịch sử', _selectedIndex == 2),
          _buildNavItem(Icons.person, 'Hồ sơ', _selectedIndex == 3),
        ],
      ),
    );
  }
}
