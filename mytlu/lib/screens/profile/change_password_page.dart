import 'package:flutter/material.dart';
import '../../models/user_model.dart';

// Màu chủ đạo
const Color tluPrimaryColor = Color(0xFF0D47A1);

class ChangePasswordPage extends StatefulWidget {
  final User user; // Thông tin người dùng để hiển thị trên header

  const ChangePasswordPage({super.key, required this.user});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    // TODO: Xử lý logic đổi mật khẩu
    // Lấy giá trị từ controllers
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmNewPass = _confirmNewPasswordController.text;

    if (newPass != confirmNewPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới không khớp!')),
      );
      return;
    }

    // Sau khi xử lý thành công, có thể quay lại trang trước
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu đã được thay đổi!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu',
            style: TextStyle(color: Colors.white)),
        backgroundColor: tluPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card Thông tin người dùng trên cùng
            _buildUserInfoHeader(),
            const SizedBox(height: 20),
            // Card chứa các trường nhập mật khẩu
            _buildPasswordFormCard(),
            const SizedBox(height: 20),
            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tluPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Xác nhận', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho header thông tin người dùng
  Widget _buildUserInfoHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(widget.user.imageUrl),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.academicRank}. ${widget.user.fullName}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.user.id,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                Text(
                  'Bộ môn: ${widget.user.department}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho Card chứa form đổi mật khẩu
  Widget _buildPasswordFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoField('Email',
                widget.user.email.replaceRange(3, 11, '********')), // Ẩn giữa email
            _buildInfoField('Số điện thoại',
                widget.user.phone.replaceRange(2, 8, '********')), // Ẩn giữa SĐT
            const Divider(height: 30),
            _buildPasswordField(
              controller: _oldPasswordController,
              label: 'Nhập mật khẩu cũ',
              obscureText: _obscureOldPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureOldPassword = !_obscureOldPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Mật khẩu mới',
              obscureText: _obscureNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Text(
                'Mật khẩu phải bao gồm chữ cái, chữ số, ít nhất một ký tự đặc biệt và tối thiểu 8 ký tự.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmNewPasswordController,
              label: 'Nhập lại mật khẩu mới',
              obscureText: _obscureConfirmNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmNewPassword = !_obscureConfirmNewPassword;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper cho hiển thị thông tin dạng text (Email, SĐT đã ẩn)
  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper cho trường nhập mật khẩu (có nút ẩn/hiện)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: '$label *',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: tluPrimaryColor, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}