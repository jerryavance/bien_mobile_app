// ==========================================
// FILE: lib/services/storage_service.dart
// Secure local storage
// ==========================================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/auth_tokens.dart';

class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyTokenExpiry = 'token_expiry';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Auth Tokens
  Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAccessToken, tokens.accessToken);
    await prefs.setString(_keyRefreshToken, tokens.refreshToken);
    await prefs.setString(_keyTokenExpiry, tokens.expiresAt.toIso8601String());
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyRefreshToken);
  }

  Future<bool> hasValidToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(_keyAccessToken);
    final expiryStr = prefs.getString(_keyTokenExpiry);

    if (token == null || expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isBefore(expiry);
  }

  // User Data
  Future<void> saveUser(UserModel user) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await _prefs;
    final userStr = prefs.getString(_keyUser);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // Generic key-value storage
  Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }
}