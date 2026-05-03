import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'role';
  static const _hasProfileKey = 'has_profile';
  static const _isActiveKey = 'is_active';
  static const _fullNameKey = 'full_name';

  SecureStorage(this._storage);

  Future<void> writeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> writeUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> readUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> writeRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> readRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> writeHasProfile(bool hasProfile) async {
    await _storage.write(key: _hasProfileKey, value: hasProfile.toString());
  }

  Future<bool> readHasProfile() async {
    final value = await _storage.read(key: _hasProfileKey);
    return value == 'true';
  }

  Future<void> writeIsActive(bool isActive) async {
    await _storage.write(key: _isActiveKey, value: isActive.toString());
  }

  Future<bool> readIsActive() async {
    final value = await _storage.read(key: _isActiveKey);
    return value == 'true';
  }

  Future<void> writeFullName(String fullName) async {
    await _storage.write(key: _fullNameKey, value: fullName);
  }

  Future<String?> readFullName() async {
    return await _storage.read(key: _fullNameKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
