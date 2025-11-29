// ==========================================
// FILE: lib/main.dart
// UPDATED: Added CardProvider and card routes
// ==========================================
import 'package:bien/screens/auth/verify_account_screen.dart';
import 'package:bien/screens/wallet/bien_transfer_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:bien/providers/bill_provider.dart';
import 'package:bien/providers/card_provider.dart'; // NEW
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';

// Services
import 'services/launch_service.dart';

// Theme
import 'core/design_system/app_theme.dart';
import 'core/middleware/auth_guard.dart';

// Core screens
import 'screens/core/home_screen.dart';
import 'screens/core/wallet_screen.dart';
import 'screens/core/profile_screen.dart';
import 'screens/core/settings_screen.dart';
import 'screens/core/scan_to_pay_screen.dart';

// Feature screens
import 'screens/features/transactions_screen.dart';
import 'screens/features/analytics_screen.dart';
import 'screens/features/cards_screen.dart';
import 'screens/features/send_money_screen.dart';
import 'screens/features/notifications_screen.dart';
import 'screens/features/help_support_screen.dart';
import 'screens/features/security_settings_screen.dart';

// Auth screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';

// Onboarding screens
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/splash_screen.dart';

// Wallet screens
import 'screens/wallet/cashout_screen.dart';
import 'screens/wallet/topup_screen.dart';

// Bill screens
import 'package:bien/screens/bills/bills_home_screen.dart';

// Card screens (NEW)
import 'screens/cards/card_topup_screen.dart';
import 'screens/cards/card_transfer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()), // NEW
      ],
      child: DevicePreview(
        enabled: true,
        builder: (context) => const FintechApp(),
      ),
    ),
  );
}

class FintechApp extends StatelessWidget {
  const FintechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bien Payments',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const _InitialRouteResolver(),
            settings: settings,
          );
        }
        return _buildRoute(settings);
      },
      routes: _allRoutes(),
    );
  }

  Map<String, WidgetBuilder> _allRoutes() => {
        // Public routes (no auth required)
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/verify-account': (context) => const VerifyAccountScreen(),

        // Protected routes (auth required)
        '/home': (context) => AuthGuardWidget(
              child: const HomeScreen(),
            ),
        '/transactions': (context) => AuthGuardWidget(
              child: const TransactionsScreen(),
            ),
        '/analytics': (context) => AuthGuardWidget(
              child: const AnalyticsScreen(),
            ),
        '/wallet': (context) => AuthGuardWidget(
              child: const WalletScreen(),
            ),
        '/profile': (context) => AuthGuardWidget(
              child: const ProfileScreen(),
            ),
        '/settings': (context) => AuthGuardWidget(
              child: const SettingsScreen(),
            ),
        '/scan-to-pay': (context) => AuthGuardWidget(
              child: const ScanToPayScreen(),
            ),
        '/cards': (context) => AuthGuardWidget(
              child: const CardsScreen(),
            ),
        '/send-money': (context) => AuthGuardWidget(
              child: const SendMoneyScreen(),
            ),
        '/notifications': (context) => AuthGuardWidget(
              child: const NotificationsScreen(),
            ),
        '/help-support': (context) => AuthGuardWidget(
              child: const HelpSupportScreen(),
            ),
        '/security-settings': (context) => AuthGuardWidget(
              child: const SecuritySettingsScreen(),
            ),
        '/bills': (context) => AuthGuardWidget(
              child: const BillsHomeScreen(),
            ),
        '/cash-out': (context) => AuthGuardWidget(
              child: const CashOutScreen(),
            ),
        '/top-up': (context) => AuthGuardWidget(
              child: const TopUpScreen(),
            ),
        '/bien-transfer': (context) => AuthGuardWidget(
              child: const BienTransferScreen(),
            ),
        
        // Card routes (NEW)
        '/card-topup': (context) => AuthGuardWidget(
              child: const CardTopUpScreen(),
            ),
        '/card-transfer': (context) => AuthGuardWidget(
              child: const CardTransferScreen(),
            ),
      };

  Route<dynamic>? _buildRoute(RouteSettings settings) {
    final builder = _allRoutes()[settings.name];
    if (builder == null) return null;

    if (settings.name == '/onboarding') {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, __, ___) => builder(context),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, a, __, child) {
          return FadeTransition(opacity: a, child: child);
        },
      );
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}

class _InitialRouteResolver extends StatelessWidget {
  const _InitialRouteResolver();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _determineInitialRoute(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final route = snapshot.data!;
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, route);
          });
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<String> _determineInitialRoute(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (authProvider.isAuthenticated) {
      return '/home';
    }

    final onboardingShown = await LaunchService.initialRoute();
    return onboardingShown == '/login' ? '/login' : '/splash';
  }
}