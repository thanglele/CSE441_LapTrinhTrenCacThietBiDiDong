import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'package:mytlu/config/api_config.dart';
import 'package:mytlu/presentation/splash_screen.dart';
import 'package:mytlu/login/ForgetPassword.dart';
import 'package:mytlu/services/user_session.dart';
import 'package:mytlu/giaodienlichhoc/screens/student_page.dart';
import 'package:mytlu/screens/home_page_lecture.dart';
import 'package:mytlu/giaodienlichhoc/screens/scan_qr_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? userName;
  final String? userAvatarAsset;
  final bool permissionsGranted;
  const LoginScreen({
    Key? key,
    this.userName,
    this.userAvatarAsset,
    required this.permissionsGranted,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final LocalAuthentication auth = LocalAuthentication();

  late TextEditingController _studentCodeController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _studentCodeController = TextEditingController();
    _passwordController = TextEditingController();

    if (!widget.permissionsGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionErrorDialog();
      });
    }
  }

  void _showPermissionErrorDialog() {
    // Đóng dialog cũ nếu có (để tránh lỗi)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Thiếu quyền truy cập'),
          content: Text(
            'Vui lòng cấp quyền Vị trí và Camera trong Cài đặt để tiếp tục.',
          ),
          actions: [
            TextButton(
              child: Text('ĐI TỚI CÀI ĐẶT'),
              onPressed: () {
                openAppSettings(); // Mở Cài đặt của app
                // Không đóng dialog, để khi quay lại app vẫn thấy
              },
            ),
            TextButton(
              child: Text('THOÁT'),
              onPressed: () {
                SystemNavigator.pop(); // Vẫn dùng lệnh này (thoát về Home)
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _studentCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // Kiểm tra nếu người dùng vừa quay lại app
    if (state == AppLifecycleState.resumed) {
      // Chỉ kiểm tra nếu chúng ta biết quyền đã bị thiếu
      if (!widget.permissionsGranted) {
        // Kiểm tra lại trạng thái quyền
        final locationStatus = await Permission.location.status;
        final cameraStatus = await Permission.camera.status;

        if (locationStatus.isGranted && cameraStatus.isGranted) {
          // Khởi động lại app bằng cách điều hướng về SplashScreen
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false, // Xóa hết stack
            );
          }
        } else {
          // Vẫn chưa cấp quyền. Hiển thị lại dialog
          _showPermissionErrorDialog();
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    // Kiểm tra 'mounted' để đảm bảo an toàn
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Nền đỏ cho lỗi
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    final bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) return; // Dừng lại nếu không có quyền

    bool authenticated = false;
    try {
      final bool canAuthenticate =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showErrorSnackBar("Thiết bị này không hỗ trợ sinh trắc học.");
        return;
      }

      authenticated = await auth.authenticate(
        localizedReason: 'Vui lòng quét vân tay để đăng nhập',
        // Dùng code cho bản 3.0.0+
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      if (e.code == 'noCredentialsSet') {
        _showErrorSnackBar(
          'Lỗi: Bạn chưa cài đặt màn hình khóa (PIN/Vân tay).',
        );
      } else if (e.code == 'notEnrolled') {
        // (Tên code chính xác là 'notEnrolled')
        _showErrorSnackBar('Lỗi: Bạn chưa đăng ký vân tay nào.');
      } else {
        _showErrorSnackBar(
          'Lỗi: Bạn chưa cài đặt màn hình khóa (PIN/Vân tay).',
        );
      }
      return; // Dừng hàm

      // (Bạn cũng nên giữ lại PlatformException để bắt các lỗi chung khác)
    } on PlatformException catch (e) {
      _showErrorSnackBar('Lỗi hệ thống: ${e.message}');
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      _showErrorSnackBar("Đang đăng nhập bằng vân tay...");

      final credentials = await UserSession().getSavedCredentials();
      final String? username = credentials['username'];
      final String? password = credentials['password'];

      if (username != null && password != null) {
        // Gọi hàm login trung tâm
        await _performLogin(username, password);
      } else {
        _showErrorSnackBar("Lỗi: Không tìm thấy thông tin đăng nhập đã lưu.");
      }
    } else {
      _showErrorSnackBar("Xác thực vân tay thất bại.");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<bool> _checkPermissions() async {
    // Lấy trạng thái hiện tại (không yêu cầu)
    final locationStatus = await Permission.location.status;
    final cameraStatus = await Permission.camera.status;

    if (locationStatus.isGranted && cameraStatus.isGranted) {
      return true; // OK, có đủ quyền
    }

    // Nếu thiếu quyền, hiển thị dialog lỗi
    // (Dialog này đã có logic mở Cài đặt và Thoát)
    _showPermissionErrorDialog();
    return false; // Báo lỗi, ngăn logic tiếp theo
  }

  Future<void> _performLogin(String username, String password) async {
    // Kiểm tra quyền (bắt buộc)
    final bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar("Vui lòng bật GPS/Dịch vụ vị trí để đăng nhập.");
        // (Tùy chọn: Mở cài đặt vị trí cho người dùng)
        await Geolocator.openLocationSettings();
        return;
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi khi kiểm tra dịch vụ vị trí: $e");
      return;
    }

    // Kiểm tra rỗng
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Vui lòng nhập Mã sinh viên và Mật khẩu.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String loginPosition;
    try {
      // Lấy vị trí (độ chính xác trung bình, timeout 10 giây)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );
      // Format tọa độ thành chuỗi "latitude, longitude"
      loginPosition = "${position.latitude}, ${position.longitude}";

      print('Tọa độ đã lấy: $loginPosition');

    } catch (e) {
      _showErrorSnackBar("Không thể lấy tọa độ thiết bị: $e");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Dùng biến toàn cục
    final String url = '${ApiConfig.baseUrl}/api/v1/auth/login';
    final Map<String, String> headers = {
      'accept': 'text/plain',
      'Content-Type': 'application/json',
    };
    final Map<String, String> body = {
      'username': username,
      'password': password,
      'loginPosition': loginPosition,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final String token = responseBody['token'];
        final String userRole = responseBody['userRole'];

        try {
          final userProfileData = await _fetchUserProfile(token);
          final String apiFullName = userProfileData['fullName'];
          final String apiAvatarUrl =
              "http://example.com/avatar.png";

          // Lưu session (BAO GỒM CẢ MẬT KHẨU)
          await UserSession().saveSession(
            token: token,
            userRole: userRole,
            username: username,
            fullName: apiFullName,
            studentCode: username,
            avatarUrl: apiAvatarUrl,
            password: password,
          );

          if (!mounted) return;
          if (userRole == 'student')
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const StudentPage()),
                  (Route<dynamic> route) => false,
            );
          else
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
            );
        } catch (e) {
          _showErrorSnackBar(e.toString());
        }
      } else if (response.statusCode == 401) {
        final String message = responseBody['message'];
        _showErrorSnackBar(message);
      } else if (response.statusCode == 428) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForgetPasswordScreen(
              permissionsGranted: widget.permissionsGranted,
            ),
          ),
        );
      } else {
        _showErrorSnackBar(
          'Lỗi: ${response.statusCode}. ${responseBody['message'] ?? ''}',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi kết nối mạng: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // SỬA LẠI HÀM NÀY
  void _handleLogin() async {
    String studentCode;
    final String password = _passwordController.text;

    // 1. KIỂM TRA XEM LẤY USERNAME TỪ ĐÂU
    if (widget.userName != null) {
      // Đang ở màn hình "Xin chào", lấy MSV (username) từ storage
      final credentials = await UserSession().getSavedCredentials();
      studentCode = credentials['username'] ?? "";

      if (studentCode.isEmpty) {
        _showErrorSnackBar("Lỗi: Không tìm thấy Mã sinh viên đã lưu.");
        return;
      }
    } else {
      // Đang ở màn hình đăng nhập chuẩn, lấy MSV từ ô text
      studentCode = _studentCodeController.text;
    }

    // 2. Gọi hàm login trung tâm (code này đã đúng)
    await _performLogin(studentCode, password);
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String token) async {
    final String url = '${ApiConfig.baseUrl}/api/v1/auth/me';

    // 1. Thêm "Bearer " vào token (theo yêu cầu của bạn)
    final String authToken = 'Bearer $token';

    final Map<String, String> headers = {
      'accept': 'text/plain',
      'Authorization': authToken,
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // Trả về dữ liệu user (VD: { "fullName": "...", ... })
        return responseBody;
      } else {
        // Nếu lỗi (401, 404), ném ra lỗi để _handleLogin bắt
        throw Exception(
          'Lỗi lấy thông tin User: ${responseBody['title'] ?? 'Không xác định'}',
        );
      }
    } catch (e) {
      // Ném ra lỗi mạng
      throw Exception('Lỗi mạng khi lấy thông tin User: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(94, 196, 230, 1),
              Color.fromRGBO(64, 124, 220, 1),
            ],
          ),
        ),

        child: Stack(
          children: [
            Positioned(
              top: 50.0,
              left: 10.0,
              child: Container(
                width: 206.0,
                height: 46.0,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16.0),

                child: Text(
                  'My TLU',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(0, 19, 122, 1),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment(0.0, 0.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.userName == null)
                    _buildWelcomeHeader(
                      null,
                      widget.userAvatarAsset ??
                          'assets/images/avatar_default.png',
                    )
                  else
                    _buildWelcomeHeader(
                      widget.userName!,
                      widget.userAvatarAsset ??
                          'assets/images/avatar_default.png',
                    ),

                  if (widget.userName == null) SizedBox(height: 10),

                  if (widget.userName == null)
                  // Ô nhập Mã sinh viên
                    _buildTextField(
                      hintText: 'Mã sinh viên',
                      icon: Icons.person_outline,
                      isPassword: false,
                      controller: _studentCodeController,
                    ),

                  SizedBox(height: 20),

                  // Ô nhập Mật khẩu
                  _buildTextField(
                    hintText: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: _togglePasswordVisibility,
                    controller: _passwordController,
                  ),

                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Đăng nhập
                      ElevatedButton(
                        onPressed: () {
                          _handleLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A2A9B), // Màu xanh đậm
                          fixedSize: Size(309, 63), // Kích thước 309x63
                          shape: RoundedRectangleBorder(
                            // Bo tròn mạnh
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(width: 10), // Khoảng cách giữa 2 nút
                      // Nút Vân tay
                      if (widget.userName != null)
                        Row(
                          children: [
                            SizedBox(width: 10), // Khoảng cách
                            InkWell(
                              onTap: _authenticateWithBiometrics,
                              borderRadius: BorderRadius.circular(31.5),
                              child: Container(
                                width: 63.0,
                                height: 63.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF0F0F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.fingerprint,
                                  color: Colors.black,
                                  size: 35.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  SizedBox(height: 5),
                  Container(
                    width: 379.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPasswordScreen(
                                  permissionsGranted: widget.permissionsGranted,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        if (widget.userName != null)
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(
                                    permissionsGranted: true,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Tài khoản khác?',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black, // (Màu này bạn đang dùng)
                                fontSize: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanQRScreen()),
          );
        },
        backgroundColor: Color(0xFF0A2A9B),
        elevation: 4.0,
        child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 40.0),
        shape: CircleBorder(),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF0A2A9B),

        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        height: 86.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Item Hỗ trợ
            _buildNavItem(
              icon: Icons.headset_mic_outlined,
              label: 'Hỗ trợ',
              onTap: () {
                // TODO: Xử lý Hỗ trợ
              },
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20.0), // Đẩy text xuống
              child: Text(
                'Quét mã QR',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),

            // Item Thông báo
            _buildNavItem(
              icon: Icons.notifications_outlined,
              label: 'Thông báo',
              onTap: () {
                // TODO: Xử lý Thông báo
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String? name, String avatarAsset) {
    if (name == null) {
      return Container(
        width: 379.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Center(
          child: Text(
            "Xin chào!",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(0, 19, 122, 1),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      return Container(
        width: 379.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 28, backgroundImage: AssetImage(avatarAsset)),
            SizedBox(width: 15),

            Expanded(
              child: Text(
                "Xin chào $name",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(icon, color: Colors.white, size: 28.0),
            ),
            SizedBox(height: 4.0),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required bool isPassword,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    TextEditingController? controller,
  }) {
    final verticalPadding = (60.0 - 24.0) / 2;

    return Container(
      width: 379.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !isVisible : false,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.black,
          fontSize: 28,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,

          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.black54,
            fontSize: 25,
          ),

          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: verticalPadding,
          ),

          prefixIcon: Icon(icon, color: Colors.black54),

          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: onToggleVisibility,
          )
              : null,
        ),
      ),
    );
  }
}
