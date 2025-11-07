import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String username;
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
  static const _secureStorage = FlutterSecureStorage();

  // Các key lưu trữ
  static const _keyToken = 'token';
  static const _keyUserRole = 'userRole';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyFullName = 'fullName';
  static const _keyStudentCode = 'studentCode';
  static const _keyAvatarPath = 'avatarPath';

  // ============================================================
  // SAVE SESSION (Sau khi đăng nhập thành công)
  // ============================================================
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

    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyUserRole, value: userRole);
    await _secureStorage.write(key: _keyUsername, value: username);
    await _secureStorage.write(key: _keyFullName, value: fullName);
    await _secureStorage.write(key: _keyStudentCode, value: studentCode);
    await _secureStorage.write(key: _keyPassword, value: password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, localAvatarPath);

    print('✅ [UserSession] Đã lưu session cho $fullName');
  }

  // ============================================================
  // GET SESSION (Dùng trong HomePage)
  // ============================================================
  Future<Map<String, String?>> getSession() async {
    final token = await _secureStorage.read(key: _keyToken);
    final fullName = await _secureStorage.read(key: _keyFullName);

    print('DEBUG (UserSession) token: $token, name: $fullName');
    return {
      'token': token,
      'fullName': fullName,
    };
  }

  // ============================================================
  // GET USER PROFILE (Khi cần thông tin chi tiết)
  // ============================================================
  Future<UserProfile?> getUserProfile() async {
    final token = await _secureStorage.read(key: _keyToken);
    if (token == null) return null;

    final username = await _secureStorage.read(key: _keyUsername);
    final fullName = await _secureStorage.read(key: _keyFullName);
    final studentCode = await _secureStorage.read(key: _keyStudentCode);
    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString(_keyAvatarPath) ?? '';

    return UserProfile(
      username: username ?? '',
      fullName: fullName ?? '',
      studentCode: studentCode ?? '',
      avatarPath: avatarPath,
    );
  }

  // ============================================================
  // GET TOKEN (Dành cho các API khác)
  // ============================================================
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// 👉 **Thêm hàm static để gọi nhanh**
  static Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  // ============================================================
  // GET SAVED CREDENTIALS (username/password)
  // ============================================================
  Future<Map<String, String?>> getSavedCredentials() async {
    final username = await _secureStorage.read(key: _keyUsername);
    final password = await _secureStorage.read(key: _keyPassword);
    return {
      'username': username,
      'password': password,
    };
  }

  // ============================================================
  // CLEAR SESSION (Đăng xuất)
  // ============================================================
  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAvatarPath);
    print('🧹 [UserSession] Đã xóa toàn bộ session');
  }

  // ============================================================
  // GIẢ LẬP LƯU ẢNH LOCAL
  // ============================================================
  Future<String> _saveImageToLocal(String imageUrl) async {
    // TODO: Nếu cần thật sự tải ảnh, thêm http + path_provider
    return "assets/images/avatar_default.png";
  }
}
