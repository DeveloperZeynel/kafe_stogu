import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<void> saveAuth({
    required String token,
    required int userId,
    required String username,
    required String role,
  }) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );

    await _storage.write(
      key: _userIdKey,
      value: userId.toString(),
    );

    await _storage.write(
      key: _usernameKey,
      value: username,
    );

    await _storage.write(
      key: _roleKey,
      value: role,
    );
  }

  Future<String?> getToken() async {
    return _storage.read(
      key: _tokenKey,
    );
  }

  Future<String?> getUsername() async {
    return _storage.read(
      key: _usernameKey,
    );
  }

  Future<String?> getRole() async {
    return _storage.read(
      key: _roleKey,
    );
  }

  Future<int?> getUserId() async {
    final value =
        await _storage.read(
      key: _userIdKey,
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token =
        await getToken();

    return token != null &&
        token.isNotEmpty;
  }
}