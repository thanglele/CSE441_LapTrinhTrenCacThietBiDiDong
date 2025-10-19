import 'package:flutter/material.dart';

import 'package:mytlu/login/ForgetPassword.dart';

class LoginScreen extends StatefulWidget {
  final String? userName;
  final String? userAvatarAsset;
  const LoginScreen({Key? key, this.userName, this.userAvatarAsset}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
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
                    fontFamily: 'Ubuntu',
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
                    _buildTextField(
                      hintText: 'Mã sinh viên',
                      icon: Icons.person_outline,
                      isPassword: false,
                    )
                  // Ngược lại, hiển thị "Xin chào"
                  else 
                    _buildWelcomeHeader(
                      widget.userName!, 
                      widget.userAvatarAsset ?? 'assets/images/avatar_default.png'
                    ),

                  SizedBox(height: 10),

                  // Ô nhập Mã sinh viên
                  _buildTextField(
                    hintText: 'Mã sinh viên',
                    icon: Icons.person_outline,
                    isPassword: false,
                  ),

                  SizedBox(height: 20),

                  // Ô nhập Mật khẩu
                  _buildTextField(
                    hintText: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),

                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Đăng nhập
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Xử lý logic đăng nhập
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A2A9B), // Màu xanh đậm
                          fixedSize: Size(309, 63), // Kích thước 309x63
                          shape: RoundedRectangleBorder(
                            // Bo tròn mạnh
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
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
                      InkWell(
                        onTap: () {
                          // TODO: Xử lý logic vân tay
                        },
                        borderRadius: BorderRadius.circular(31.5), // bo tròn
                        child: Container(
                          width: 63.0,
                          height: 63.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F0F0), // Màu nền xám nhạt/trắng
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            color: Colors.black, // Màu icon vân tay
                            size: 35.0, // Kích thước icon
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),
                  Container(
                    width: 379.0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
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
          // TODO: Xử lý logic Quét QR
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

  Widget _buildWelcomeHeader(String name, String avatarAsset) {
    return Container(
      width: 379.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(avatarAsset), 
          ),
          SizedBox(width: 15),
          
          Expanded(
            child: Text(
              "Xin chào $name",
              style: TextStyle(
                fontFamily: 'Ubuntu',
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
        obscureText: isPassword ? !isVisible : false,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          color: Colors.black,
          fontSize: 28,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,

          hintStyle: TextStyle(
            fontFamily: 'Ubuntu',
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
