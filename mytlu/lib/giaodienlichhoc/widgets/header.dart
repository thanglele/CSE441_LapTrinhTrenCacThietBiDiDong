import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF407CDC),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cột chứa tiêu đề và thông tin sinh viên
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "My TLU",
                style: TextStyle(
                  fontSize: 28, // ✅ giảm nhẹ để cân đối
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "MSV: 225117",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                "Nguyễn Thị Dinh",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          // Biểu tượng thông báo + avatar
          Row(
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 12,
               // backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
