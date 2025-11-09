import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'services/launch_service.dart';
import 'core/design_system/app_theme.dart';

//core screens
import 'screens/core/home_screen.dart';
import 'screens/core/wallet_screen.dart';
import 'screens/core/profile_screen.dart';
import 'screens/core/settings_screen.dart';
import 'screens/core/scan_to_pay_screen.dart';

//features screens
import 'screens/features/transactions_screen.dart';
import 'screens/features/investment_screen.dart';
import 'screens/features/budget_screen.dart';
import 'screens/features/analytics_screen.dart';
import 'screens/features/cards_screen.dart';
import 'screens/features/savings_screen.dart';
import 'screens/features/send_money_screen.dart';
import 'screens/features/notifications_screen.dart';
import 'screens/features/help_support_screen.dart';
import 'screens/features/security_settings_screen.dart';
import 'screens/features/currency_converter_screen.dart';
import 'screens/features/bill_payments_screen.dart';
import 'screens/features/loan_calculator_screen.dart';
import 'screens/features/tax_calculator_screen.dart';

//auth screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

//onboarding screens
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/splash_screen.dart';

//wallet screens
import 'screens/wallet/cashout_screen.dart';
import 'screens/wallet/topup_screen.dart';
import 'package:provider/provider.dart';
// Providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';

//Product screens
import 'screens/products/airtime_screen.dart';
import 'screens/products/data_bundles_screen.dart';
import 'screens/products/merchant_pay_screen.dart';
import 'screens/products/school_fees_screen.dart';
import 'screens/products/utility_payment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DevicePreview(
    enabled: true,
    builder: (context) => const FintechApp(),
  ));
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
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/investments': (context) => const InvestmentScreen(),
        '/budget': (context) => const BudgetScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),

        '/scan-to-pay': (context) => const ScanToPayScreen(),
        
        '/cards': (context) => const CardsScreen(),
        '/savings': (context) => const SavingsScreen(),
        '/send-money': (context) => const SendMoneyScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/security-settings': (context) => const SecuritySettingsScreen(),
        '/currency-converter': (context) => const CurrencyConverterScreen(),
        '/bill-payments': (context) => const BillPaymentsScreen(),
        '/loan-calculator': (context) => const LoanCalculatorScreen(),
        '/tax-calculator': (context) => const TaxCalculatorScreen(),

        '/cash-out': (context) => const CashOutScreen(),
        '/top-up': (context) => const TopUpScreen(),

        '/airtime': (context) => const AirtimeScreen(),
        '/data-bundles': (context) => const DataBundlesScreen(),
        '/merchant-pay': (context) => const MerchantPayScreen(),
        '/school-fees': (context) => const SchoolFeesScreen(),
        '/utility-payment': (context) => const UtilityPaymentScreen(),

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
      future: LaunchService.initialRoute(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final route = snapshot.data!;
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, route);
          });
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}











// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/material.dart';
// import 'services/launch_service.dart';
// import 'core/design_system/app_theme.dart';
// import 'screens/core/home_screen.dart';
// import 'screens/core/wallet_screen.dart';
// import 'screens/core/profile_screen.dart';
// import 'screens/core/settings_screen.dart';
// import 'screens/features/transactions_screen.dart';
// import 'screens/features/investment_screen.dart';
// import 'screens/features/budget_screen.dart';
// import 'screens/features/analytics_screen.dart';
// import 'screens/features/cards_screen.dart';
// import 'screens/features/savings_screen.dart';
// import 'screens/features/send_money_screen.dart';
// import 'screens/features/notifications_screen.dart';
// import 'screens/features/help_support_screen.dart';
// import 'screens/features/security_settings_screen.dart';
// import 'screens/features/currency_converter_screen.dart';
// import 'screens/features/bill_payments_screen.dart';
// import 'screens/features/loan_calculator_screen.dart';
// import 'screens/features/tax_calculator_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/signup_screen.dart';
// import 'screens/onboarding/onboarding_screen.dart';
// import 'screens/onboarding/splash_screen.dart';
// import 'screens/wallet/cashout_screen.dart';
// import 'screens/wallet/topup_screen.dart';

// import 'package:provider/provider.dart';
// // Providers
// import 'providers/auth_provider.dart';
// import 'providers/wallet_provider.dart';
// import 'providers/transaction_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(DevicePreview(
//     enabled: true,
//     builder: (context) => const FintechApp(),
//   ));
// }

// class FintechApp extends StatelessWidget {
//   const FintechApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bien Payments',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: '/',
//       onGenerateRoute: (settings) {
//         if (settings.name == '/') {
//           return MaterialPageRoute(
//             builder: (context) => const _InitialRouteResolver(),
//             settings: settings,
//           );
//         }
//         return _buildRoute(settings);
//       },
//       routes: _allRoutes(),
//     );
//   }

//   Map<String, WidgetBuilder> _allRoutes() => {
//         '/splash': (context) => const SplashScreen(),
//         '/onboarding': (context) => const OnboardingScreen(),
//         '/home': (context) => const HomeScreen(),
//         '/login': (context) => const LoginScreen(),
//         '/signup': (context) => const SignupScreen(),
//         '/transactions': (context) => const TransactionsScreen(),
//         '/investments': (context) => const InvestmentScreen(),
//         '/budget': (context) => const BudgetScreen(),
//         '/analytics': (context) => const AnalyticsScreen(),
//         '/wallet': (context) => const WalletScreen(),
//         '/profile': (context) => const ProfileScreen(),
//         '/settings': (context) => const SettingsScreen(),
//         '/cards': (context) => const CardsScreen(),
//         '/savings': (context) => const SavingsScreen(),
//         '/send-money': (context) => const SendMoneyScreen(),
//         '/notifications': (context) => const NotificationsScreen(),
//         '/help-support': (context) => const HelpSupportScreen(),
//         '/security-settings': (context) => const SecuritySettingsScreen(),
//         '/currency-converter': (context) => const CurrencyConverterScreen(),
//         '/bill-payments': (context) => const BillPaymentsScreen(),
//         '/loan-calculator': (context) => const LoanCalculatorScreen(),
//         '/tax-calculator': (context) => const TaxCalculatorScreen(),
//         '/cash-out': (context) => const CashOutScreen(),
//         '/top-up': (context) => const TopUpScreen(),
//       };

//   Route<dynamic>? _buildRoute(RouteSettings settings) {
//     final builder = _allRoutes()[settings.name];
//     if (builder == null) return null;

//     if (settings.name == '/onboarding') {
//       return PageRouteBuilder(
//         settings: settings,
//         pageBuilder: (context, __, ___) => builder(context),
//         transitionDuration: const Duration(milliseconds: 600),
//         transitionsBuilder: (context, a, __, child) {
//           return FadeTransition(opacity: a, child: child);
//         },
//       );
//     }

//     return MaterialPageRoute(builder: builder, settings: settings);
//   }
// }

// class _InitialRouteResolver extends StatelessWidget {
//   const _InitialRouteResolver();

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: LaunchService.initialRoute(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final route = snapshot.data!;
//           Future.microtask(() {
//             Navigator.pushReplacementNamed(context, route);
//           });
//         }
//         return const Scaffold(body: SizedBox.shrink());
//       },
//     );
//   }
// }









// ==========================================
// UPDATED: lib/main.dart
// Add Provider setup
// ==========================================

/*
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';

// ... rest of imports

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: DevicePreview(
        enabled: true,
        builder: (context) => const BienPaymentsApp(),
      ),
    ),
  );
}

class BienPaymentsApp extends StatelessWidget {
  const BienPaymentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bien Payments',
      debugShowCheckedModeBanner: false,
      theme: BienAppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          return auth.isAuthenticated 
              ? const HomeScreen() 
              : const OnboardingScreen();
        },
      ),
      routes: {
        // ... all your routes
      },
    );
  }
}
*/









// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/material.dart';
// import 'core/design_system/app_theme.dart';
// import 'screens/core/home_screen.dart';
// import 'screens/core/wallet_screen.dart';
// import 'screens/core/profile_screen.dart';
// import 'screens/core/settings_screen.dart';
// import 'screens/features/transactions_screen.dart';
// import 'screens/features/investment_screen.dart';
// import 'screens/features/budget_screen.dart';
// import 'screens/features/analytics_screen.dart';
// import 'screens/features/cards_screen.dart';
// import 'screens/features/savings_screen.dart';
// import 'screens/features/send_money_screen.dart';
// import 'screens/features/notifications_screen.dart';
// import 'screens/features/help_support_screen.dart';
// import 'screens/features/security_settings_screen.dart';
// import 'screens/features/currency_converter_screen.dart';
// import 'screens/features/bill_payments_screen.dart';
// import 'screens/features/loan_calculator_screen.dart';
// import 'screens/features/tax_calculator_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/signup_screen.dart';
// import 'screens/onboarding/onboarding_screen.dart';
// import 'screens/onboarding/splash_screen.dart'; // Import SplashScreen

// import 'screens/wallet/cashout_screen.dart';
// import 'screens/wallet/topup_screen.dart';

// void main() {
//   runApp(DevicePreview(
//     enabled: true,
//     // enabled: !kReleaseMode,
//     builder: (context) => FintechApp(),
//   ));
// }


// class FintechApp extends StatelessWidget {
//   const FintechApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bien',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const SplashScreen(), // Splash first
//         '/onboarding': (context) => const OnboardingScreen(),
//         '/home': (context) => const HomeScreen(),
//         '/login': (context) => const LoginScreen(),
//         '/signup': (context) => const SignupScreen(),
//         '/transactions': (context) => const TransactionsScreen(),
//         '/investments': (context) => const InvestmentScreen(),
//         '/budget': (context) => const BudgetScreen(),
//         '/analytics': (context) => const AnalyticsScreen(),
//         '/wallet': (context) => const WalletScreen(),
//         '/profile': (context) => const ProfileScreen(),
//         '/settings': (context) => const SettingsScreen(),
//         '/cards': (context) => const CardsScreen(),
//         '/savings': (context) => const SavingsScreen(),
//         '/send-money': (context) => const SendMoneyScreen(),
//         '/notifications': (context) => const NotificationsScreen(),
//         '/help-support': (context) => const HelpSupportScreen(),
//         '/security-settings': (context) => const SecuritySettingsScreen(),
//         '/currency-converter': (context) => const CurrencyConverterScreen(),
//         '/bill-payments': (context) => const BillPaymentsScreen(),
//         '/loan-calculator': (context) => const LoanCalculatorScreen(),
//         '/tax-calculator': (context) => const TaxCalculatorScreen(),

//         '/cash-out': (context) => const CashOutScreen(),
//         '/top-up': (context) => const TopUpScreen(),

//       },
//     );
//   }
// }
