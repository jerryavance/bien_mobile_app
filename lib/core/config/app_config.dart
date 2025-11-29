// ==========================================
// FILE: lib/core/config/app_config.dart
// Environment configuration
// ==========================================

class AppConfig {
  // Environment type
  static const Environment environment = Environment.development;

  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://bienug.com/APIs/BienApiNew/api';
      case Environment.staging:
        return 'https://staging.bienug.com/APIs/BienApiNew/api';
      case Environment.production:
        return 'https://api.bienug.com/v1';
    }
  }

  // Feature Flags
  static const bool enableDebugLogs = true; // Set to false in production
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int uploadTimeout = 60; // seconds

  // Security
  static const bool enableCertificatePinning = false; // Enable in production
  static const bool enableBiometrics = true;

  // App Information
  static const String appName = 'Bien Payments';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Support
  static const String supportEmail = 'support@bienpayments.ug';
  static const String supportPhone = '+256700000000';
  static const String termsUrl = 'https://bienpayments.ug/terms';
  static const String privacyUrl = 'https://bienpayments.ug/privacy';
}

enum Environment {
  development,
  staging,
  production,
}

// ==========================================
// PRODUCTION CHECKLIST
// ==========================================

/*
  ✅ BEFORE PRODUCTION DEPLOYMENT:

  1. SECURITY
     [ ] Set enableDebugLogs = false
     [ ] Enable certificate pinning
     [ ] Update API base URL to production
     [ ] Remove all print statements
     [ ] Enable crash reporting (Sentry/Firebase)
     [ ] Implement request encryption for sensitive data
     [ ] Add ProGuard rules (Android)
     [ ] Enable code obfuscation

  2. TESTING
     [ ] Test all authentication flows
     [ ] Test all payment types
     [ ] Test error scenarios
     [ ] Test offline behavior
     [ ] Test token expiry and refresh
     [ ] Test on different devices
     [ ] Test network failures
     [ ] Load testing

  3. BACKEND COORDINATION
     [ ] Confirm production API endpoints
     [ ] Get production API keys
     [ ] Test rate limiting
     [ ] Verify webhook endpoints
     [ ] Confirm error response formats
     [ ] Set up monitoring alerts

  4. APP STORE REQUIREMENTS
     [ ] Update app icons
     [ ] Create screenshots
     [ ] Write app description
     [ ] Set privacy policy URL
     [ ] Set terms of service URL
     [ ] Configure in-app purchases (if any)
     [ ] Add required permissions explanations

  5. MONITORING
     [ ] Set up Firebase/Analytics
     [ ] Set up crash reporting
     [ ] Set up error tracking
     [ ] Monitor API response times
     [ ] Track user flows
     [ ] Set up alerts for critical errors

  6. COMPLIANCE
     [ ] GDPR compliance
     [ ] Data encryption at rest
     [ ] Secure data transmission
     [ ] User consent management
     [ ] Data retention policies
     [ ] Right to be forgotten

  7. PERFORMANCE
     [ ] Optimize images
     [ ] Implement caching
     [ ] Lazy loading
     [ ] Minimize API calls
     [ ] Optimize database queries
     [ ] Test app size

  8. USER EXPERIENCE
     [ ] Loading indicators on all API calls
     [ ] Error messages are user-friendly
     [ ] Offline mode messaging
     [ ] Empty states
     [ ] Success confirmations
     [ ] Proper form validation

  9. DOCUMENTATION
     [ ] API documentation up to date
     [ ] Code comments for complex logic
     [ ] README with setup instructions
     [ ] Deployment guide
     [ ] Troubleshooting guide

  10. BACKUP & RECOVERY
      [ ] Database backup strategy
      [ ] Session recovery
      [ ] Transaction rollback handling
      [ ] Data migration plan
*/

// ==========================================
// CRITICAL SECURITY NOTES
// ==========================================

/*
  ⚠️ NEVER commit these to version control:
  - API keys
  - Secrets
  - Private keys
  - Encryption keys
  - Database credentials
  - OAuth client secrets

  ✅ Use environment variables or secure storage:
  - flutter_secure_storage for sensitive data
  - .env files (add to .gitignore)
  - CI/CD secret management
  - Platform-specific keystore

  🔒 Implement in production:
  - SSL certificate pinning
  - Request/response encryption
  - Biometric authentication
  - Secure key storage
  - Rate limiting
  - Request signing
*/

// ==========================================
// BACKEND QUESTIONS TO ASK
// ==========================================

/*
  1. What's the exact response format for success?
     Example: { "success": true, "data": {...} }

  2. What's the exact error format?
     Example: { "success": false, "error": {...} }

  3. What are all possible error codes?
     Example: INSUFFICIENT_FUNDS, INVALID_OTP, etc.

  4. Token lifetime?
     - Access token: __ hours
     - Refresh token: __ days

  5. Rate limiting?
     - Requests per minute: __
     - Requests per hour: __

  6. Payment types supported?
     - Complete list of paymentType values

  7. Webhook support?
     - What events trigger webhooks?
     - Webhook signature verification?

  8. File upload limits?
     - Max file size: __MB
     - Supported formats: __

  9. Is there a sandbox/test environment?
     - URL: __
     - Test credentials: __

  10. API versioning strategy?
      - How are breaking changes handled?
*/

// ==========================================
// COMMON ERROR CODES
// ==========================================

class ErrorCodes {
  // Authentication errors
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String invalidToken = 'INVALID_TOKEN';
  static const String accountLocked = 'ACCOUNT_LOCKED';
  static const String accountNotVerified = 'ACCOUNT_NOT_VERIFIED';
  static const String invalidOtp = 'INVALID_OTP';
  static const String otpExpired = 'OTP_EXPIRED';

  // Transaction errors
  static const String insufficientFunds = 'INSUFFICIENT_FUNDS';
  static const String dailyLimitExceeded = 'DAILY_LIMIT_EXCEEDED';
  static const String invalidAmount = 'INVALID_AMOUNT';
  static const String transactionFailed = 'TRANSACTION_FAILED';
  static const String duplicateTransaction = 'DUPLICATE_TRANSACTION';

  // General errors
  static const String networkError = 'NETWORK_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String notFound = 'NOT_FOUND';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';
}

// ==========================================
// USER-FRIENDLY ERROR MESSAGES
// ==========================================

class ErrorMessages {
  static String getMessage(String errorCode) {
    switch (errorCode) {
      case ErrorCodes.invalidCredentials:
        return 'Invalid email or password. Please try again.';
      case ErrorCodes.tokenExpired:
        return 'Your session has expired. Please log in again.';
      case ErrorCodes.insufficientFunds:
        return 'Insufficient balance. Please top up your wallet.';
      case ErrorCodes.dailyLimitExceeded:
        return 'Daily transaction limit exceeded. Try again tomorrow.';
      case ErrorCodes.invalidOtp:
        return 'Invalid verification code. Please check and try again.';
      case ErrorCodes.networkError:
        return 'No internet connection. Please check your network.';
      case ErrorCodes.serverError:
        return 'Something went wrong. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}