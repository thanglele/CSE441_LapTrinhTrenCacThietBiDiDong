import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Tạo một class để chứa thông tin User
class UserProfile {
  final String username;
  final String fullName;
  final String studentCode;
  final String avatarPath; // Đường dẫn file avatar đã lưu

  UserProfile({
    required this.username,
    required this.fullName,
    required this.studentCode,
    required this.avatarPath,
  });
}

// 2. Class chính để quản lý Session
class UserSession {
  // Tạo thể hiện (instance) cho storage an toàn
  final _secureStorage = const FlutterSecureStorage();
  
  // Các key để lưu trữ (nên là hằng số)
  static const _keyUsername = 'username';
  static const _keyFullName = 'fullName';
  static const _keyStudentCode = 'studentCode';
  static const _keyPassword = 'password'; // Chỉ lưu an toàn
  static const _keyAvatarPath = 'avatarPath'; // Lưu bình thường

  // --- HÀM LƯU TRỮ ---
  Future<void> saveSession({
    required String username,
    required String fullName,
    required String studentCode,
    required String password,
    required String avatarUrl, // URL ảnh gốc
  }) async {
    // TODO: Tải ảnh từ avatarUrl về và lưu vào bộ nhớ máy
    // (Đây là một bước phức tạp, tạm thời ta giả định đã tải xong)
    String localAvatarPath = await _saveImageToLocal(avatarUrl);

    // 1. LƯU DỮ LIỆU NHẠY CẢM (an toàn)
    await _secureStorage.write(key: _keyUsername, value: username);
    await _secureStorage.write(key: _keyFullName, value: fullName);
    await _secureStorage.write(key: _keyStudentCode, value: studentCode);
    await _secureStorage.write(key: _keyPassword, value: password);

    // 2. LƯU DỮ LIỆU THƯỜNG (không an toàn)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, localAvatarPath);
  }

  // --- HÀM KIỂM TRA & LẤY DỮ LIỆU ---
  Future<UserProfile?> getUserProfile() async {
    // Thử đọc 1 key nhạy cảm (username) và 1 key thường (avatar)
    final username = await _secureStorage.read(key: _keyUsername);
    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString(_keyAvatarPath);

    // Nếu 1 trong 2 không tồn tại -> chưa đăng nhập
    if (username == null || avatarPath == null) {
      return null;
    }

    // Lấy nốt thông tin còn lại
    final fullName = await _secureStorage.read(key: _keyFullName);
    final studentCode = await _secureStorage.read(key: _keyStudentCode);

    return UserProfile(
      username: username,
      fullName: fullName ?? '',
      studentCode: studentCode ?? '',
      avatarPath: avatarPath,
    );
  }
  
  // --- HÀM LẤY MẬT KHẨU (chỉ khi cần) ---
  Future<String?> getSavedPassword() async {
    return await _secureStorage.read(key: _keyPassword);
  }

  // --- HÀM ĐĂNG XUẤT ---
  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAvatarPath);
  }

  // (Hàm giả định, bạn cần package 'path_provider' và 'http' để làm thật)
  Future<String> _saveImageToLocal(String imageUrl) async {
    // TODO: Dùng package http để tải ảnh
    // Dùng package path_provider để lấy thư mục lưu trữ
    // Lưu file và trả về đường dẫn
    print("Đang tải ảnh từ $imageUrl...");
    // Giả lập đường dẫn đã lưu
    return "assets/images/avatar_default.png"; // <-- Tạm thời trả về asset
  }
}