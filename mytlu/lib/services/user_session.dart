import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String username;       // Mã sinh viên
  final String fullName;
  final String studentCode;
  final String avatarPath;
  final String userRole;
  final String loginPosition;  // Tọa độ đăng nhập "lat,lng"

  UserProfile({
    required this.username,
    required this.fullName,
    required this.studentCode,
    required this.avatarPath,
    required this.userRole,
    required this.loginPosition,
  });
}

class UserSession {
  final _secureStorage = const FlutterSecureStorage();

  // Keys
  static const _keyToken = 'token';
  static const _keyUserRole = 'userRole';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyFullName = 'fullName';
  static const _keyStudentCode = 'studentCode';
  static const _keyLoginPosition = 'loginPosition';
  static const _keyAvatarPath = 'avatarPath';

  /// Lưu toàn bộ session khi login thành công
  Future<void> saveSession({
    required String token,
    required String userRole,
    required String username,
    required String fullName,
    required String studentCode,
    required String loginPosition, // mới
    required String avatarUrl,
    required String password,
  }) async {
    // 1. Lưu nhạy cảm vào secure storage
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyUserRole, value: userRole);
    await _secureStorage.write(key: _keyUsername, value: username);
    await _secureStorage.write(key: _keyFullName, value: fullName);
    await _secureStorage.write(key: _keyStudentCode, value: studentCode);
    await _secureStorage.write(key: _keyLoginPosition, value: loginPosition);
    await _secureStorage.write(key: _keyPassword, value: password);

    // 2. Lưu avatar (dữ liệu thường) vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String localAvatarPath = await _saveImageToLocal(avatarUrl);
    await prefs.setString(_keyAvatarPath, localAvatarPath);
  }

  /// Lấy thông tin người dùng
  Future<UserProfile?> getUserProfile() async {
    final token = await _secureStorage.read(key: _keyToken);
    if (token == null) return null;

    final username = await _secureStorage.read(key: _keyUsername);
    final fullName = await _secureStorage.read(key: _keyFullName);
    final studentCode = await _secureStorage.read(key: _keyStudentCode);
    final userRole = await _secureStorage.read(key: _keyUserRole);
    final loginPosition = await _secureStorage.read(key: _keyLoginPosition) ?? '';

    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString(_keyAvatarPath) ?? '';

    return UserProfile(
      username: username ?? '',
      fullName: fullName ?? '',
      studentCode: studentCode ?? '',
      avatarPath: avatarPath,
      userRole: userRole ?? '',
      loginPosition: loginPosition,
    );
  }

  /// Lấy token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
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

  /// Lấy thông tin đăng nhập lưu trữ (username + password)
  Future<Map<String, String?>> getSavedCredentials() async {
    final username = await _secureStorage.read(key: _keyUsername);
    final password = await _secureStorage.read(key: _keyPassword);
    return {'username': username, 'password': password};
  }

  /// Xóa session khi logout
  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAvatarPath);
  }

  /// Lưu ảnh về local (giả lập, thực tế cần path_provider + http)
  Future<String> _saveImageToLocal(String imageUrl) async {
    // Logic lưu ảnh từ URL về local (hoặc dùng placeholder)
    return "assets/images/avatar_default.png";
  }

  /// Lấy vị trí login
  Future<String?> getLoginPosition() async {
    return await _secureStorage.read(key: _keyLoginPosition);
  }
}
