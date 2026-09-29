import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';

class SecureStorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession({required String token, required UserModel user}) async {
    await _storage.write(key: _keyToken, value: token);
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _keyUser, value: userJson);
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final userStr = await _storage.read(key: _keyUser);
      if (userStr == null || userStr.isEmpty) return null;
      final map = jsonDecode(userStr) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyUser);
    } catch (_) {}
  }
}
