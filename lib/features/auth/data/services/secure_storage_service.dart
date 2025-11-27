import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/utils/logger.dart';

/// Secure storage service using Hive for encrypted token and user data storage
class SecureStorageService {
  static const String _boxName = 'secure_storage';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user';
  static const String _keyRememberMe = 'remember_me';

  late Box _box;
  bool _isInitialized = false;

  /// Singleton instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  /// Initialize Hive and open secure box
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      AppLogger.info(
          'SecureStorageService initialized', 'SecureStorageService');
    } catch (e) {
      AppLogger.error('Failed to initialize SecureStorageService: $e',
          'SecureStorageService');
      rethrow;
    }
  }

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _ensureInitialized();
    await _box.put(_keyAccessToken, token);
    AppLogger.debug('Access token saved', 'SecureStorageService');
  }

  /// Get access token
  String? getAccessToken() {
    _checkInitialized();
    return _box.get(_keyAccessToken) as String?;
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _ensureInitialized();
    await _box.put(_keyRefreshToken, token);
    AppLogger.debug('Refresh token saved', 'SecureStorageService');
  }

  /// Get refresh token
  String? getRefreshToken() {
    _checkInitialized();
    return _box.get(_keyRefreshToken) as String?;
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    await _ensureInitialized();
    await _box.put(_keyUser, jsonEncode(user.toJson()));
    AppLogger.debug('User data saved: ${user.email}', 'SecureStorageService');
  }

  /// Get user data
  UserModel? getUser() {
    _checkInitialized();
    final userJson = _box.get(_keyUser) as String?;
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Failed to parse user data: $e', 'SecureStorageService');
      return null;
    }
  }

  /// Save complete auth session (tokens + user)
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
    bool rememberMe = true,
  }) async {
    await _ensureInitialized();
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUser(user),
      _box.put(_keyRememberMe, rememberMe),
    ]);
    AppLogger.info(
        'Auth session saved (rememberMe: $rememberMe)', 'SecureStorageService');
  }

  /// Check if user has active session
  bool hasActiveSession() {
    _checkInitialized();
    final accessToken = getAccessToken();
    final refreshToken = getRefreshToken();
    final user = getUser();
    return accessToken != null && refreshToken != null && user != null;
  }

  /// Check if remember me is enabled
  bool isRememberMeEnabled() {
    _checkInitialized();
    return _box.get(_keyRememberMe, defaultValue: true) as bool;
  }

  /// Clear all auth data (logout)
  Future<void> clearAuthSession() async {
    await _ensureInitialized();
    await Future.wait([
      _box.delete(_keyAccessToken),
      _box.delete(_keyRefreshToken),
      _box.delete(_keyUser),
      _box.delete(_keyRememberMe),
    ]);
    AppLogger.info('Auth session cleared', 'SecureStorageService');
  }

  /// Clear only tokens (keep user data for UI)
  Future<void> clearTokens() async {
    await _ensureInitialized();
    await Future.wait([
      _box.delete(_keyAccessToken),
      _box.delete(_keyRefreshToken),
    ]);
    AppLogger.debug('Tokens cleared', 'SecureStorageService');
  }

  /// Clear all data in the box
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box.clear();
    AppLogger.warning('All secure storage cleared', 'SecureStorageService');
  }

  /// Check if initialized, throw if not
  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'SecureStorageService not initialized. Call init() first.');
    }
  }

  /// Ensure initialized, init if not
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Close the box (call on app dispose)
  Future<void> dispose() async {
    if (_isInitialized) {
      await _box.close();
      _isInitialized = false;
      AppLogger.info('SecureStorageService disposed', 'SecureStorageService');
    }
  }
}
