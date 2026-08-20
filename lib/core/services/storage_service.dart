import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyPermissionCompleted = 'permissions_setup_completed';
  static const String _keyUserSessionToken = 'user_session_token';

  Future<void> setPermissionsCompleted(bool completed) async {
    try {
      await _storage.write(
        key: _keyPermissionCompleted,
        value: completed.toString(),
      );
    } catch (e) {
      AppLogger.error('Failed to set permission completed status', error: e);
    }
  }

  Future<bool> isPermissionsCompleted() async {
    try {
      final String? value = await _storage.read(key: _keyPermissionCompleted);
      return value == 'true';
    } catch (e) {
      AppLogger.error('Failed to read permission status', error: e);
      return false;
    }
  }

  Future<void> setUserSessionToken(String token) async {
    try {
      await _storage.write(key: _keyUserSessionToken, value: token);
    } catch (e) {
      AppLogger.error('Failed to save session token', error: e);
    }
  }

  Future<String?> getUserSessionToken() async {
    try {
      return await _storage.read(key: _keyUserSessionToken);
    } catch (e) {
      AppLogger.error('Failed to read session token', error: e);
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      AppLogger.error('Failed to clear storage', error: e);
    }
  }
}
