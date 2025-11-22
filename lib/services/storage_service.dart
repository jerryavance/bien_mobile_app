// ==========================================
// UPDATED: lib/services/storage_service.dart
// Added userId storage for auth requests
// ==========================================
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/auth_tokens.dart';
import 'dart:convert';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id'; // NEW: Store userId separately

  final _secureStorage = const FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ==========================================
  // USER ID MANAGEMENT (NEW)
  // ==========================================

  /// Save userId separately for auth requests
  Future<void> saveUserId(String userId) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: userId);
      print('StorageService: UserId saved: $userId');
    } catch (e) {
      print('StorageService: Error saving userId: $e');
      rethrow;
    }
  }

  /// Get userId for auth requests
  Future<String?> getUserId() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      print('StorageService: Retrieved userId: $userId');
      return userId;
    } catch (e) {
      print('StorageService: Error reading userId: $e');
      return null;
    }
  }

  /// Check if userId exists
  Future<bool> hasUserId() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  // ==========================================
  // TOKEN MANAGEMENT
  // ==========================================

  /// Save authentication tokens
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken),
        _secureStorage.write(
          key: _tokenExpiryKey,
          value: tokens.expiresAt.toIso8601String(),
        ),
      ]);
      print('StorageService: Tokens saved successfully');
    } catch (e) {
      print('StorageService: Error saving tokens: $e');
      rethrow;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      return token;
    } catch (e) {
      print('StorageService: Error reading access token: $e');
      return null;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      print('StorageService: Error reading refresh token: $e');
      return null;
    }
  }

  /// Check if token is valid and not expired
  Future<bool> hasValidToken() async {
    try {
      final token = await getAccessToken();
      final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);

      if (token == null || expiryStr == null) {
        return false;
      }

      final expiry = DateTime.parse(expiryStr);
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      print('StorageService: Error checking token validity: $e');
      return false;
    }
  }

  // ==========================================
  // USER DATA MANAGEMENT
  // ==========================================

  /// Save user data and extract userId
  Future<void> saveUser(UserModel user) async {
    try {
      await Future.wait([
        _secureStorage.write(
          key: _userKey,
          value: jsonEncode(user.toJson()),
        ),
        // Also save userId separately for easy access
        saveUserId(user.id),
      ]);
      print('StorageService: User data saved successfully');
    } catch (e) {
      print('StorageService: Error saving user data: $e');
      rethrow;
    }
  }

  /// Get user data
  Future<UserModel?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('StorageService: Error reading user data: $e');
      return null;
    }
  }

  // ==========================================
  // CLEANUP
  // ==========================================

  /// Clear all data (logout)
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userKey),
        _secureStorage.delete(key: _tokenExpiryKey),
        _secureStorage.delete(key: _userIdKey), // NEW: Clear userId
      ]);
      print('StorageService: All data cleared successfully');
    } catch (e) {
      print('StorageService: Error clearing storage: $e');
      rethrow;
    }
  }

  /// Clear only pending verification data (keeps authenticated session)
  Future<void> clearPendingVerification() async {
    try {
      // Only clear userId if user is not fully authenticated
      final hasValidToken = await this.hasValidToken();
      if (!hasValidToken) {
        await _secureStorage.delete(key: _userIdKey);
        print('StorageService: Pending verification data cleared');
      }
    } catch (e) {
      print('StorageService: Error clearing pending verification: $e');
    }
  }
}