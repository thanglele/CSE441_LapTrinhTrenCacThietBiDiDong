// lib/services/user_session.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// (Class UserProfile giữ nguyên)
class UserProfile {
  final String username; // Đây là mã sinh viên
  final String fullName;
  final String studentCode;
  final String avatarPath; 

  UserProfile({
    required this.username,
    required this.fullName,
    required this.studentCode,
    required this.avatarPath,
  });
}

class UserSession {
  final _secureStorage = const FlutterSecureStorage();
  
  // Cập nhật các Key
  static const _keyToken = 'token';
  static const _keyUserRole = 'userRole';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyFullName = 'fullName';
  static const _keyStudentCode = 'studentCode';
  static const _keyAvatarPath = 'avatarPath';

  Future<void> saveSession({
    required String token,
    required String userRole,
    required String username,
    required String fullName,
    required String studentCode,
    required String avatarUrl,
    required String password,
  }) async {
    
    String localAvatarPath = await _saveImageToLocal(avatarUrl);

    // 1. LƯU DỮ LIỆU NHẠY CẢM
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyUserRole, value: userRole);
    await _secureStorage.write(key: _keyUsername, value: username);
    await _secureStorage.write(key: _keyFullName, value: fullName);
    await _secureStorage.write(key: _keyStudentCode, value: studentCode);
    
    // 3. LƯU LẠI MẬT KHẨU
    await _secureStorage.write(key: _keyPassword, value: password);

    // 2. LƯU DỮ LIỆU THƯỜNG
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, localAvatarPath);
  }

  // --- HÀM KIỂM TRA & LẤY DỮ LIỆU (Đã cập nhật) ---
  Future<UserProfile?> getUserProfile() async {
    // Chỉ cần kiểm tra token
    final token = await _secureStorage.read(key: _keyToken);
    if (token == null) {
      return null;
    }

    // Lấy nốt thông tin còn lại
    final username = await _secureStorage.read(key: _keyUsername);
    final fullName = await _secureStorage.read(key: _keyFullName);
    final studentCode = await _secureStorage.read(key: _keyStudentCode);
    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString(_keyAvatarPath);

    return UserProfile(
      username: username ?? '',
      fullName: fullName ?? '',
      studentCode: studentCode ?? '',
      avatarPath: avatarPath ?? '', // Sửa thành rỗng nếu null
    );
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final username = await _secureStorage.read(key: _keyUsername);
    final password = await _secureStorage.read(key: _keyPassword);
    return {
      'username': username,
      'password': password,
    };
  }

  // --- HÀM LẤY TOKEN (Hữu ích cho các lệnh gọi API khác) ---
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }
  
  // --- HÀM ĐĂNG XUẤT (Đã cập nhật) ---
  Future<void> clearSession() async {
    await _secureStorage.deleteAll(); // Xóa hết token, username...
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAvatarPath);
  }

  // (Hàm giả định, bạn cần package 'path_provider' và 'http' để làm thật)
  Future<String> _saveImageToLocal(String imageUrl) async {
    // ... (Giữ nguyên logic giả lập)
    return "assets/images/avatar_default.png"; 
  }
}