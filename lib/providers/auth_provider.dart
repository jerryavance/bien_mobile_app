// ==========================================
// FILE: lib/providers/auth_provider.dart
// Authentication state management
// ==========================================
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // Initialize - check if user is logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _isAuthenticated = await _authService.isLoggedIn();
    if (_isAuthenticated) {
      _user = await _authService.getCurrentUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Request login OTP
  Future<bool> requestLoginOtp(String emailOrPhone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.requestLoginOtp(emailOrPhone);

    _isLoading = false;
    if (!response.success) {
      _errorMessage = response.message;
    }
    notifyListeners();

    return response.success;
  }

  // Verify login OTP
  Future<bool> verifyLoginOtp(String emailOrPhone, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.verifyLoginOtp(emailOrPhone, otp);

    _isLoading = false;
    if (response.success && response.data != null) {
      _user = response.data;
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();

    return response.success;
  }

  // Signup
  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    _isLoading = false;
    if (!response.success) {
      _errorMessage = response.message;
    }
    notifyListeners();

    return response.success;
  }

  // Verify signup OTP
  Future<bool> verifySignupOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.verifySignupOtp(phoneNumber, otp);

    _isLoading = false;
    if (response.success && response.data != null) {
      _user = response.data;
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();

    return response.success;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}