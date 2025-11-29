// ==========================================
// FILE: lib/services/storage_service.dart
// Updated with account ID and validation ref storage
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
  static const String _userIdKey = 'user_id';
  static const String _accountIdKey = 'account_id'; // NEW
  static const String _validationRefKey = 'validation_ref'; // NEW

  final _secureStorage = const FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ==========================================
  // USER ID MANAGEMENT
  // ==========================================

  Future<void> saveUserId(String userId) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: userId);
      print('StorageService: UserId saved: $userId');
    } catch (e) {
      print('StorageService: Error saving userId: $e');
      rethrow;
    }
  }

  Future<String?> getUserId() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      return userId;
    } catch (e) {
      print('StorageService: Error reading userId: $e');
      return null;
    }
  }

  Future<bool> hasUserId() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  // ==========================================
  // ACCOUNT ID MANAGEMENT (NEW)
  // ==========================================

  /// Save main account ID for transactions
  Future<void> saveAccountId(String accountId) async {
    try {
      await _secureStorage.write(key: _accountIdKey, value: accountId);
      print('StorageService: AccountId saved: $accountId');
    } catch (e) {
      print('StorageService: Error saving accountId: $e');
      rethrow;
    }
  }

  /// Get main account ID
  Future<String?> getAccountId() async {
    try {
      final accountId = await _secureStorage.read(key: _accountIdKey);
      return accountId;
    } catch (e) {
      print('StorageService: Error reading accountId: $e');
      return null;
    }
  }

  // ==========================================
  // VALIDATION REFERENCE MANAGEMENT (NEW)
  // ==========================================

  /// Save validation reference temporarily
  Future<void> saveValidationRef(String validationRef) async {
    try {
      await _secureStorage.write(key: _validationRefKey, value: validationRef);
      print('StorageService: ValidationRef saved: $validationRef');
    } catch (e) {
      print('StorageService: Error saving validationRef: $e');
      rethrow;
    }
  }

  /// Get validation reference
  Future<String?> getValidationRef() async {
    try {
      final validationRef = await _secureStorage.read(key: _validationRefKey);
      return validationRef;
    } catch (e) {
      print('StorageService: Error reading validationRef: $e');
      return null;
    }
  }

  /// Clear validation reference after use
  Future<void> clearValidationRef() async {
    try {
      await _secureStorage.delete(key: _validationRefKey);
      print('StorageService: ValidationRef cleared');
    } catch (e) {
      print('StorageService: Error clearing validationRef: $e');
    }
  }

  // ==========================================
  // TOKEN MANAGEMENT
  // ==========================================

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

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      return token;
    } catch (e) {
      print('StorageService: Error reading access token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      print('StorageService: Error reading refresh token: $e');
      return null;
    }
  }

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

  Future<void> saveUser(UserModel user) async {
    try {
      await Future.wait([
        _secureStorage.write(
          key: _userKey,
          value: jsonEncode(user.toJson()),
        ),
        saveUserId(user.id),
      ]);
      print('StorageService: User data saved successfully');
    } catch (e) {
      print('StorageService: Error saving user data: $e');
      rethrow;
    }
  }

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

  Future<void> clearAll() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userKey),
        _secureStorage.delete(key: _tokenExpiryKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _accountIdKey),
        _secureStorage.delete(key: _validationRefKey),
      ]);
      print('StorageService: All data cleared successfully');
    } catch (e) {
      print('StorageService: Error clearing storage: $e');
      rethrow;
    }
  }

  Future<void> clearPendingVerification() async {
    try {
      final hasValidToken = await this.hasValidToken();
      if (!hasValidToken) {
        await Future.wait([
          _secureStorage.delete(key: _userIdKey),
          _secureStorage.delete(key: _accountIdKey),
          _secureStorage.delete(key: _validationRefKey),
        ]);
        print('StorageService: Pending verification data cleared');
      }
    } catch (e) {
      print('StorageService: Error clearing pending verification: $e');
    }
  }
}