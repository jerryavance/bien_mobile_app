// ==========================================
// FILE: lib/core/middleware/auth_guard.dart
// Authentication guard for protected routes
// ==========================================
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class AuthGuard {
  static final AuthService _authService = AuthService();
  static final StorageService _storage = StorageService();

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await _authService.isLoggedIn();
  }

  /// Navigate to login if not authenticated
  static Future<void> requireAuth(BuildContext context) async {
    final isAuth = await isAuthenticated();
    if (!isAuth && context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  /// Check auth and redirect if needed
  static Future<bool> checkAuthAndRedirect(BuildContext context) async {
    final isAuth = await isAuthenticated();
    if (!isAuth && context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
      return false;
    }
    return true;
  }

  /// Refresh token if expired
  static Future<bool> refreshTokenIfNeeded() async {
    final hasValidToken = await _storage.hasValidToken();
    
    if (!hasValidToken) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        final response = await _authService.refreshToken();
        return response.success;
      }
      return false;
    }
    
    return true;
  }
}

/// Widget wrapper for protected routes
class AuthGuardWidget extends StatefulWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuardWidget({
    super.key,
    required this.child,
    this.redirectTo = '/login',
  });

  @override
  State<AuthGuardWidget> createState() => _AuthGuardWidgetState();
}

class _AuthGuardWidgetState extends State<AuthGuardWidget> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await AuthGuard.isAuthenticated();
    
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuth;
        _isChecking = false;
      });

      if (!isAuth) {
        Navigator.of(context).pushReplacementNamed(widget.redirectTo!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated ? widget.child : const SizedBox.shrink();
  }
}

/// Route guard mixin for StatefulWidget screens
mixin RouteGuardMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await AuthGuard.isAuthenticated();
    if (!isAuth && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}