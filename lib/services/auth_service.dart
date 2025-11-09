// ==========================================
// FILE: lib/services/auth_service.dart
// Authentication operations
// ==========================================
import '../models/user_model.dart';
import '../models/auth_tokens.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  // Login with OTP (Step 1: Request OTP)
  Future<ApiResponse<void>> requestLoginOtp(String emailOrPhone) async {
    return await _api.post(
      '/auth/login/request-otp',
      body: {'identifier': emailOrPhone},
      needsAuth: false,
    );
  }

  // Login with OTP (Step 2: Verify OTP)
  Future<ApiResponse<UserModel>> verifyLoginOtp(String emailOrPhone, String otp) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login/verify-otp',
      body: {'identifier': emailOrPhone, 'otp': otp},
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final tokens = AuthTokens.fromJson(response.data!['tokens']);
      final user = UserModel.fromJson(response.data!['user']);

      await _storage.saveTokens(tokens);
      await _storage.saveUser(user);

      return ApiResponse.success(data: user, message: 'Login successful');
    }

    return ApiResponse.error(message: response.message);
  }

  // Signup (Step 1: Register)
  Future<ApiResponse<void>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    return await _api.post(
      '/auth/signup',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      },
      needsAuth: false,
    );
  }

  // Signup (Step 2: Verify OTP)
  Future<ApiResponse<UserModel>> verifySignupOtp(String phoneNumber, String otp) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/signup/verify-otp',
      body: {'phone_number': phoneNumber, 'otp': otp},
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final tokens = AuthTokens.fromJson(response.data!['tokens']);
      final user = UserModel.fromJson(response.data!['user']);

      await _storage.saveTokens(tokens);
      await _storage.saveUser(user);

      return ApiResponse.success(data: user, message: 'Signup successful');
    }

    return ApiResponse.error(message: response.message);
  }

  // Forgot Password
  Future<ApiResponse<void>> requestPasswordReset(String emailOrPhone) async {
    return await _api.post(
      '/auth/password/request-reset',
      body: {'identifier': emailOrPhone},
      needsAuth: false,
    );
  }

  Future<ApiResponse<void>> resetPassword({
    required String emailOrPhone,
    required String otp,
    required String newPassword,
  }) async {
    return await _api.post(
      '/auth/password/reset',
      body: {
        'identifier': emailOrPhone,
        'otp': otp,
        'new_password': newPassword,
      },
      needsAuth: false,
    );
  }

  // Logout
  Future<void> logout() async {
    await _api.post('/auth/logout');
    await _storage.clearAll();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _storage.hasValidToken();
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }

  // Refresh token
  Future<ApiResponse<void>> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse.error(message: 'No refresh token available');
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final tokens = AuthTokens.fromJson(response.data!);
      await _storage.saveTokens(tokens);
      return ApiResponse.success(message: 'Token refreshed');
    }

    return ApiResponse.error(message: response.message);
  }
}