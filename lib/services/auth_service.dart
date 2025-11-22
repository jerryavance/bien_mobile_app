// ==========================================
// UPDATED: lib/services/auth_service.dart
// Fixed to use userId from backend
// ==========================================
import '../models/user_model.dart';
import '../models/auth_tokens.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  // ==========================================
  // REGISTRATION
  // ==========================================
  
  /// Register new user
  /// Returns userId in data for OTP verification
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      '/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ==========================================
  // OTP VERIFICATION
  // ==========================================
  
  /// Verify OTP after registration or login
  /// Requires userId, otp, and verificationType
  Future<ApiResponse<UserModel>> verifyOtp({
    required String userId,
    required String otp,
    required String verificationType, // 'signup' or 'login'
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      body: {
        'userId': userId,
        'otp': otp,
        'verificationType': verificationType,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      // Save tokens if present
      if (response.data!.containsKey('tokens')) {
        final tokens = AuthTokens.fromJson(response.data!['tokens']);
        await _storage.saveTokens(tokens);
      }

      // Save user data if present
      if (response.data!.containsKey('user')) {
        final user = UserModel.fromJson(response.data!['user']);
        await _storage.saveUser(user);
        return ApiResponse.success(data: user, message: 'Verification successful');
      }
    }

    return ApiResponse.error(message: response.message ?? 'Verification failed');
  }

  /// Resend OTP code
  /// CHANGED: Now requires userId instead of identifier
  Future<ApiResponse<void>> resendOtp({
    required String userId,
    required String verificationType, // 'signup', 'login', or 'reset'
    String channel = 'sms', required String identifier, // 'sms' or 'email'
  }) async {
    return await _api.post(
      '/auth/resend-otp',
      body: {
        'userId': userId,
        'verificationType': verificationType,
        'channel': channel,
      },
      needsAuth: false,
    );
  }

  // ==========================================
  // LOGIN
  // ==========================================
  
  /// Login with email or phone and password
  /// Automatically determines identifierType
  Future<ApiResponse<UserModel>> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    // Determine identifier type based on format
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(identifier);
    
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'identifier': identifier,
        'password': password,
        'identifierType': isEmail ? 'email' : 'phone',
        'rememberMe': rememberMe,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      // Save tokens if present
      if (response.data!.containsKey('tokens')) {
        final tokens = AuthTokens.fromJson(response.data!['tokens']);
        await _storage.saveTokens(tokens);
      }

      // Save user if present
      if (response.data!.containsKey('user')) {
        final user = UserModel.fromJson(response.data!['user']);
        await _storage.saveUser(user);
        return ApiResponse.success(data: user, message: 'Login successful');
      }
    }

    // Return error response with data preserved (may contain userId)
    return ApiResponse.error(
      message: response.message ?? 'Login failed',
      errors: response.data, // Preserve response data for userId extraction
    );
  }

  // ==========================================
  // PASSWORD RESET
  // ==========================================
  
  /// Request password reset - sends OTP to email or phone
  /// Returns userId if available
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(
    String identifier, {
    String identifierType = 'email',
  }) async {
    return await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      body: {
        'identifier': identifier,
        'identifierType': identifierType,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Verify OTP for password reset
  /// CHANGED: Now requires userId instead of identifier
  Future<ApiResponse<Map<String, dynamic>>> verifyResetOtp({
    required String userId,
    required String otp, required String identifier,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      '/auth/verify-reset-otp',
      body: {
        'userId': userId,
        'otp': otp,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Reset password with verified token
  /// CHANGED: Now requires userId instead of identifier
  Future<ApiResponse<void>> resetPassword({
    required String userId,
    required String otp,
    required String newPassword, required String identifier,
  }) async {
    return await _api.post(
      '/auth/reset-password',
      body: {
        'userId': userId,
        'otp': otp,
        'newPassword': newPassword,
      },
      needsAuth: false,
    );
  }

  /// Change password for authenticated users
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _api.post(
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      needsAuth: true,
    );
  }

  // ==========================================
  // USER PROFILE
  // ==========================================
  
  /// Get current authenticated user profile
  Future<ApiResponse<UserModel>> getCurrentUserProfile() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/auth/me',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data!);
      await _storage.saveUser(user);
      return ApiResponse.success(data: user);
    }

    return ApiResponse.error(message: response.message ?? 'Failed to fetch profile');
  }

  // ==========================================
  // TOKEN MANAGEMENT
  // ==========================================
  
  /// Refresh access token using refresh token
  Future<ApiResponse<void>> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse.error(message: 'No refresh token available');
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      body: {'refreshToken': refreshToken},
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final tokens = AuthTokens.fromJson(response.data!);
      await _storage.saveTokens(tokens);
      return ApiResponse.success(message: 'Token refreshed');
    }

    return ApiResponse.error(message: response.message ?? 'Token refresh failed');
  }

  // ==========================================
  // LOGOUT
  // ==========================================
  
  /// Logout and clear all stored data
  Future<void> logout() async {
    try {
      // Try to call backend logout endpoint
      await _api.post('/auth/logout');
    } catch (e) {
      print('Logout API error: $e');
      // Continue with local logout even if API call fails
    }
    
    // Clear all local storage
    await _storage.clearAll();
  }

  // ==========================================
  // HELPERS
  // ==========================================
  
  /// Check if user is logged in with valid token
  Future<bool> isLoggedIn() async {
    return await _storage.hasValidToken();
  }

  /// Get current user from local storage
  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }
}