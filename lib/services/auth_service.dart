// ==========================================
// FIXED: lib/services/auth_service.dart
// Corrected to match backend API responses exactly
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
  /// Backend returns: { success: true, data: { userId, email, phoneNumber, wallet, accounts, otpSentTo, otpExpiresIn } }
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    print('AuthService: Registering user: $email');
    
    final response = await _api.post<Map<String, dynamic>>(
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

    print('AuthService: Registration response - success: ${response.success}');
    print('AuthService: Registration response data: ${response.data}');

    // ✅ CRITICAL: Store userId immediately after registration
    if (response.success && response.data != null) {
      final userId = response.data!['userId'] as String?;
      if (userId != null && userId.isNotEmpty) {
        await _storage.saveUserId(userId);
        print('✅ AuthService: UserId stored after registration: $userId');
      } else {
        print('❌ AuthService: WARNING - No userId in registration response');
        print('AuthService: Response data keys: ${response.data!.keys.toList()}');
      }
    } else {
      print('❌ AuthService: Registration failed - ${response.message}');
    }

    return response;
  }

  // ==========================================
  // OTP VERIFICATION
  // ==========================================
  
  /// Verify OTP after registration or login
  /// Uses stored userId from registration/login
  Future<ApiResponse<UserModel>> verifyOtp({
    String? userId, // Optional - will use stored userId if not provided
    required String otp,
    required String verificationType, // 'signup' or 'login'
  }) async {
    // Get userId from parameter or storage
    final String? effectiveUserId = userId ?? await _storage.getUserId();
    
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      print('AuthService: ERROR - No userId available for OTP verification');
      return ApiResponse.error(
        message: 'Session expired. Please start the verification process again.',
      );
    }

    print('AuthService: Verifying OTP with userId: $effectiveUserId');

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      body: {
        'userId': effectiveUserId,
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
        print('AuthService: Tokens saved after OTP verification');
      }

      // Save user data if present
      if (response.data!.containsKey('user')) {
        final user = UserModel.fromJson(response.data!['user']);
        await _storage.saveUser(user); // This also saves userId
        print('AuthService: User data saved after OTP verification');
        return ApiResponse.success(data: user, message: 'Verification successful');
      }
    }

    return ApiResponse.error(
      message: response.message ?? 'Verification failed',
      statusCode: response.statusCode,
    );
  }

  /// Resend OTP code
  /// ✅ FIXED: Backend expects 'identifier' (phone/email), NOT userId
  /// Backend returns user data including userId - we need to store it!
  Future<ApiResponse<void>> resendOtp({
    required String identifier, // Phone number or email
    required String verificationType, // 'signup', 'login', or 'reset'
    String channel = 'sms', // 'sms' or 'email'
  }) async {
    print('AuthService: Resending OTP to: $identifier, type: $verificationType, channel: $channel');

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/resend-otp',
      body: {
        'identifier': identifier, // ✅ Backend expects identifier, not userId
        'verificationType': verificationType,
        'channel': channel,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    // ✅ CRITICAL: Extract and store userId from response
    if (response.success && response.data != null) {
      print('AuthService: Resend OTP response data: ${response.data}');
      
      // Backend returns: { user: { id, first_name, ... } }
      if (response.data!.containsKey('user')) {
        final userData = response.data!['user'] as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('id')) {
          final userId = userData['id'] as String?;
          if (userId != null && userId.isNotEmpty) {
            await _storage.saveUserId(userId);
            print('✅ AuthService: UserId stored from resend OTP: $userId');
          }
        }
      }
    }

    return ApiResponse<void>(
      success: response.success,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // ==========================================
  // LOGIN
  // ==========================================
  
  /// Login with email or phone and password
  /// If unverified: { success: false, data: { userId, requiresVerification: true } }
  /// If verified: { success: true, data: { user, tokens } }
  Future<ApiResponse<UserModel>> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    print('AuthService: Attempting login with: $identifier');
    
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

    print('AuthService: Login response - success: ${response.success}');
    print('AuthService: Login response data: ${response.data}');

    if (response.success && response.data != null) {
      // ✅ SUCCESSFUL LOGIN - User is verified
      print('AuthService: ✅ Login successful - user is verified');
      
      // Save tokens if present
      if (response.data!.containsKey('tokens')) {
        final tokens = AuthTokens.fromJson(response.data!['tokens']);
        await _storage.saveTokens(tokens);
        print('AuthService: Tokens saved after login');
      }

      // Save user if present
      if (response.data!.containsKey('user')) {
        final user = UserModel.fromJson(response.data!['user']);
        await _storage.saveUser(user); // This also saves userId
        print('AuthService: User data saved after login');
        return ApiResponse.success(data: user, message: 'Login successful');
      }
    } else {
      // ❌ LOGIN FAILED - Check if verification is required
      print('AuthService: ⚠️ Login failed - checking if verification required');
      
      if (response.data != null) {
        print('AuthService: Error response data keys: ${response.data!.keys.toList()}');
        
        // ✅ Check for userId in error response (unverified account)
        if (response.data!.containsKey('userId')) {
          final userId = response.data!['userId'] as String?;
          final requiresVerification = response.data!['requiresVerification'] as bool? ?? false;
          
          if (userId != null && userId.isNotEmpty) {
            await _storage.saveUserId(userId);
            print('✅ AuthService: UserId stored for pending verification: $userId');
            print('AuthService: Requires verification: $requiresVerification');
          }
        }
      }
    }

    // Return error response with data preserved
    return ApiResponse.error(
      message: response.message ?? 'Login failed',
      errors: response.data,
      statusCode: response.statusCode,
    );
  }

  // ==========================================
  // PASSWORD RESET
  // ==========================================
  
  /// Request password reset - sends OTP to email or phone
  /// Backend returns: { success: true, data: { resetToken, message } }
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(
    String identifier, {
    String identifierType = 'email',
  }) async {
    print('AuthService: Requesting password reset for: $identifier');
    
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      body: {
        'identifier': identifier,
        'identifierType': identifierType,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    print('AuthService: Forgot password response - success: ${response.success}');
    print('AuthService: Forgot password response data: ${response.data}');

    return response;
  }

  /// Verify OTP for password reset
  /// ✅ Backend expects resetToken (not userId)
  Future<ApiResponse<Map<String, dynamic>>> verifyResetOtp({
    required String resetToken,
    required String otp,
  }) async {
    print('AuthService: Verifying reset OTP with resetToken: $resetToken');

    return await _api.post<Map<String, dynamic>>(
      '/auth/verify-reset-otp',
      body: {
        'resetToken': resetToken,
        'otp': otp,
      },
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Reset password with verified reset token
  /// ✅ Backend expects verifiedResetToken (not userId)
  Future<ApiResponse<void>> resetPassword({
    required String verifiedResetToken,
    required String newPassword,
  }) async {
    print('AuthService: Resetting password with verifiedResetToken: $verifiedResetToken');

    final response = await _api.post(
      '/auth/reset-password',
      body: {
        'verifiedResetToken': verifiedResetToken,
        'newPassword': newPassword,
      },
      needsAuth: false,
    );

    // Clear stored userId after successful password reset
    if (response.success) {
      await _storage.clearPendingVerification();
      print('AuthService: Pending verification cleared after password reset');
    }

    return response;
  }

  /// Change password for authenticated users
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    print('AuthService: Changing password for authenticated user');
    
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
    print('AuthService: Fetching current user profile');
    
    final response = await _api.get<Map<String, dynamic>>(
      '/auth/me',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data!);
      await _storage.saveUser(user); // This also saves userId
      print('AuthService: User profile fetched and saved');
      return ApiResponse.success(data: user);
    }

    print('AuthService: Failed to fetch user profile - ${response.message}');
    return ApiResponse.error(
      message: response.message ?? 'Failed to fetch profile',
    );
  }

  // ==========================================
  // TOKEN MANAGEMENT
  // ==========================================
  
  /// Refresh access token using refresh token
  Future<ApiResponse<void>> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      print('AuthService: No refresh token available');
      return ApiResponse.error(message: 'No refresh token available');
    }

    print('AuthService: Refreshing access token');

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      body: {'refreshToken': refreshToken},
      needsAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final tokens = AuthTokens.fromJson(response.data!);
      await _storage.saveTokens(tokens);
      print('AuthService: Token refreshed successfully');
      return ApiResponse.success(message: 'Token refreshed');
    }

    print('AuthService: Token refresh failed - ${response.message}');
    return ApiResponse.error(
      message: response.message ?? 'Token refresh failed',
    );
  }

  // ==========================================
  // LOGOUT
  // ==========================================
  
  /// Logout and clear all stored data
  Future<void> logout() async {
    print('AuthService: Logging out user');
    
    try {
      // Try to call backend logout endpoint
      await _api.post('/auth/logout');
      print('AuthService: Backend logout successful');
    } catch (e) {
      print('AuthService: Logout API error: $e');
      // Continue with local logout even if API call fails
    }
    
    // Clear all local storage (including userId, tokens, user data)
    await _storage.clearAll();
    print('AuthService: All local data cleared');
  }

  // ==========================================
  // HELPERS
  // ==========================================
  
  /// Check if user is logged in with valid token
  Future<bool> isLoggedIn() async {
    final hasToken = await _storage.hasValidToken();
    print('AuthService: Is logged in: $hasToken');
    return hasToken;
  }

  /// Get current user from local storage
  Future<UserModel?> getCurrentUser() async {
    final user = await _storage.getUser();
    if (user != null) {
      print('AuthService: Current user retrieved: ${user.fullName}');
    } else {
      print('AuthService: No user in local storage');
    }
    return user;
  }

  /// Get stored userId
  Future<String?> getStoredUserId() async {
    final userId = await _storage.getUserId();
    print('AuthService: Retrieved userId from storage: $userId');
    return userId;
  }

  /// Check if userId exists in storage
  Future<bool> hasStoredUserId() async {
    final hasUserId = await _storage.hasUserId();
    print('AuthService: Has stored userId: $hasUserId');
    return hasUserId;
  }
}