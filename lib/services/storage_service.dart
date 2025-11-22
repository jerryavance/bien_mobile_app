// ==========================================
// STEP 1: Update StorageService for Token Management
// FILE: lib/services/storage_service.dart
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

  final _secureStorage = const FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Save tokens
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
      print('Tokens saved successfully');
    } catch (e) {
      print('Error saving tokens: $e');
      rethrow;
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      return token;
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      print('Error reading refresh token: $e');
      return null;
    }
  }

  // Save user data
  Future<void> saveUser(UserModel user) async {
    try {
      await _secureStorage.write(
        key: _userKey,
        value: jsonEncode(user.toJson()),
      );
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Get user data
  Future<UserModel?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Error reading user data: $e');
      return null;
    }
  }

  // Check if token is valid and not expired
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
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userKey),
        _secureStorage.delete(key: _tokenExpiryKey),
      ]);
      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing storage: $e');
      rethrow;
    }
  }
}