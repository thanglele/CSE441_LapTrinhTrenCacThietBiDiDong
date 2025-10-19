import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:mytlu/login/ForgetPassword.dart';

class OTPCodeScreen extends StatefulWidget {
  const OTPCodeScreen({Key? key}) : super(key: key);

  @override
  _OTPCodeScreenState createState() => _OTPCodeScreenState();
}

class _OTPCodeScreenState extends State<OTPCodeScreen> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 60,
      textStyle: TextStyle(
        fontFamily: 'Ubuntu',
        fontSize: 20,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
    );
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
                  Container(
                    width: 379.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Center(
                      child: Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    width: 379.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Center(
                      child: Text(
                        "Nhập mã OTP xác nhận được gửi qua Email",
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    width: 379.0,
                    child: Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme:
                          defaultPinTheme,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      keyboardType: TextInputType.number,

                      onCompleted: (pin) {
                        print('Đã nhập xong OTP: $pin');
                        // TODO: Xử lý logic gửi OTP
                      },
                    ),
                  ),

                  SizedBox(height: 5),
                  Container(
                    width: 379.0,
                    child: Align(
                      alignment: Alignment.centerRight,
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
                          'Nhập lại Email',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Gửi mã OTP
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Xử lý logic Gửi lại mã OTP
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A2A9B),
                          fixedSize: Size(180, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          'Gửi lại mã OTP',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
}
