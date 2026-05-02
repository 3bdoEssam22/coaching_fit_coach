import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'role';
  static const _hasProfileKey = 'has_profile';

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

  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _hasProfileKey);
  }
}
