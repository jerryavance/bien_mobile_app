// ==========================================
// FIXED: lib/providers/auth_provider.dart
// Corrected to properly handle identifier storage for OTP resend
// ==========================================
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  // State variables
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // ✅ Store identifier (phone/email) for resend OTP
  String? _pendingVerificationIdentifier;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get pendingVerificationPhone => _pendingVerificationIdentifier;

  // ==========================================
  // INITIALIZATION
  // ==========================================

  Future<void> initialize() async {
    print('AuthProvider: Initializing...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isLoggedIn();
      
      if (_isAuthenticated) {
        print('AuthProvider: User is authenticated, fetching profile...');
        _user = await _authService.getCurrentUser();
        
        if (_user != null) {
          print('AuthProvider: User loaded: ${_user!.fullName}');
          await refreshUserProfile();
        }
      } else {
        print('AuthProvider: No valid token found');
        _user = null;
      }
    } catch (e) {
      print('AuthProvider: Error during initialization: $e');
      _isAuthenticated = false;
      _user = null;
      _errorMessage = 'Failed to initialize authentication';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==========================================
  // REGISTRATION
  // ==========================================

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    print('AuthProvider: Starting registration for $email');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      _isLoading = false;

      if (response.success) {
        print('AuthProvider: Registration successful');
        // ✅ Store phone for resend OTP (backend needs identifier)
        _pendingVerificationIdentifier = phoneNumber;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Registration failed - ${response.message}');
        _errorMessage = response.message ?? 'Registration failed. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Registration error: $e');
      _isLoading = false;
      _errorMessage = 'An error occurred during registration';
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // OTP VERIFICATION
  // ==========================================

  /// Verify OTP - userId is automatically retrieved from storage by AuthService
  Future<bool> verifyOtp({
    required String otp,
    required String verificationType,
  }) async {
    print('AuthProvider: Verifying OTP for $verificationType...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get userId from storage
      final userId = await _storage.getUserId();
      
      if (userId == null || userId.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Session expired. Please start the verification process again.';
        notifyListeners();
        return false;
      }

      // Call AuthService with userId
      final response = await _authService.verifyOtp(
        userId: userId,
        otp: otp,
        verificationType: verificationType,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        print('AuthProvider: OTP verification successful');
        _user = response.data;
        _isAuthenticated = true;
        _errorMessage = null;
        _pendingVerificationIdentifier = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: OTP verification failed - ${response.message}');
        _errorMessage = response.message ?? 'Invalid verification code. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: OTP verification error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to verify code. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// ✅ FIXED: Resend OTP using identifier (phone/email), not userId
  Future<bool> resendOtp({
    required String verificationType,
    String channel = 'sms',
  }) async {
    print('AuthProvider: Resending OTP...');
    
    // ✅ Check if we have the identifier stored
    if (_pendingVerificationIdentifier == null || _pendingVerificationIdentifier!.isEmpty) {
      _errorMessage = 'Session expired. Please start the verification process again.';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Call AuthService with identifier (phone/email)
      final response = await _authService.resendOtp(
        identifier: _pendingVerificationIdentifier!,
        verificationType: verificationType,
        channel: channel,
      );

      _isLoading = false;

      if (response.success) {
        print('AuthProvider: OTP resent successfully');
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Resend OTP failed - ${response.message}');
        _errorMessage = response.message ?? 'Failed to resend code. Try again later.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Resend OTP error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to resend code';
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // LOGIN
  // ==========================================

  Future<bool> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    print('AuthProvider: Starting login with identifier: $identifier');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        print('AuthProvider: Login successful');
        _user = response.data;
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // ✅ Check if OTP verification is required
        final errorMsg = response.message?.toLowerCase() ?? '';
        if (errorMsg.contains('verify') || errorMsg.contains('pending')) {
          print('AuthProvider: OTP verification required');
          // ✅ Store identifier for resend OTP
          _pendingVerificationIdentifier = identifier;
        }
        
        print('AuthProvider: Login failed - ${response.message}');
        _errorMessage = response.message ?? 'Invalid email/phone or password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Login error: $e');
      _isLoading = false;
      _errorMessage = 'An error occurred during login';
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // PASSWORD RESET
  // ==========================================

  Future<bool> forgotPassword(String identifier, {String identifierType = 'email'}) async {
    print('AuthProvider: Requesting password reset for: $identifier');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(
        identifier,
        identifierType: identifierType,
      );

      _isLoading = false;

      if (response.success) {
        print('AuthProvider: Password reset request successful');
        // ✅ Store identifier for display and resend
        _pendingVerificationIdentifier = identifier;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Password reset request failed - ${response.message}');
        _errorMessage = response.message ?? 'Failed to process request. Try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Forgot password error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to process password reset request';
      notifyListeners();
      return false;
    }
  }

  /// ✅ Password reset flow uses resetToken, not userId
  Future<bool> verifyResetOtp({
    required String resetToken,
    required String otp,
  }) async {
    print('AuthProvider: Verifying reset OTP...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyResetOtp(
        resetToken: resetToken,
        otp: otp,
      );

      _isLoading = false;

      if (response.success) {
        print('AuthProvider: Reset OTP verified successfully');
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Reset OTP verification failed - ${response.message}');
        _errorMessage = response.message ?? 'Invalid verification code';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Verify reset OTP error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to verify code';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String verifiedResetToken,
    required String newPassword,
  }) async {
    print('AuthProvider: Resetting password...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        verifiedResetToken: verifiedResetToken,
        newPassword: newPassword,
      );

      _isLoading = false;

      if (response.success) {
        print('AuthProvider: Password reset successful');
        _errorMessage = null;
        _pendingVerificationIdentifier = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Password reset failed - ${response.message}');
        _errorMessage = response.message ?? 'Failed to reset password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Reset password error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to reset password';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!_isAuthenticated) {
      _errorMessage = 'Not authenticated';
      notifyListeners();
      return false;
    }

    print('AuthProvider: Changing password...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;

      if (response.success) {
        print('AuthProvider: Password changed successfully');
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Password change failed - ${response.message}');
        _errorMessage = response.message ?? 'Failed to change password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Change password error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to change password';
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // USER PROFILE
  // ==========================================

  Future<void> refreshUserProfile() async {
    if (!_isAuthenticated) {
      print('AuthProvider: Not authenticated, skipping profile refresh');
      return;
    }

    print('AuthProvider: Refreshing user profile...');

    try {
      final response = await _authService.getCurrentUserProfile();
      
      if (response.success && response.data != null) {
        print('AuthProvider: Profile refreshed successfully');
        _user = response.data;
        notifyListeners();
      } else {
        print('AuthProvider: Failed to refresh profile - ${response.message}');
      }
    } catch (e) {
      print('AuthProvider: Error refreshing profile: $e');
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> logout() async {
    print('AuthProvider: Logging out...');
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      print('AuthProvider: Logout completed');
    } catch (e) {
      print('AuthProvider: Logout error: $e');
    }

    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _pendingVerificationIdentifier = null;
    _isLoading = false;
    
    print('AuthProvider: Local state cleared');
    notifyListeners();
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ✅ Set pending verification identifier (phone/email) for OTP resend
  void setPendingVerification(String identifier) {
    _pendingVerificationIdentifier = identifier;
    notifyListeners();
  }

  void clearPendingVerification() {
    _pendingVerificationIdentifier = null;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  String? get userDisplayName => _user?.fullName;
  String? get userEmail => _user?.email;
  String? get userPhone => _user?.phoneNumber;
  
  /// Check if userId exists in storage
  Future<bool> hasStoredUserId() async {
    return await _storage.hasUserId();
  }

  /// Get userId from storage (for debugging)
  Future<String?> getStoredUserId() async {
    return await _storage.getUserId();
  }

  /// Debug method to check auth state
  Future<void> debugAuthState() async {
    print('═══════════════════════════════');
    print('AUTH STATE DEBUG');
    print('═══════════════════════════════');
    print('Is Authenticated: $_isAuthenticated');
    print('Is Loading: $_isLoading');
    print('Error Message: $_errorMessage');
    print('User: ${_user?.fullName ?? 'null'}');
    print('Pending Identifier: $_pendingVerificationIdentifier');
    print('Has Token: ${await _storage.hasValidToken()}');
    print('Has UserId: ${await _storage.hasUserId()}');
    print('UserId: ${await _storage.getUserId()}');
    print('═══════════════════════════════');
  }
}