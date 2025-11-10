import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bien Payments Uganda - Localized App Theme
/// Adapted for East African market with local payment methods
class AppTheme {
  // Bien Brand Colors - Updated for local market
  // static const Color primaryColor = Color(0xFF0066CC); // Bien Blue
  static const Color primaryColor = Color(0xFF113A5E); // Bien Blue
  static const Color secondaryColor = Color(0xFFFFB800); // Bien Gold
  static const Color accentColor = Color(0xFF00A651); // Uganda Green
  
  // Semantic Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);
  
  // Status Colors
  static const Color successColor = Color(0xFF00A651);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFFFB800);
  static const Color infoColor = Color(0xFF0066CC);

  // Uganda-specific colors for payment methods
  static const Color mtnColor = Color(0xFFFFCC00); // MTN Mobile Money
  static const Color airtelColor = Color(0xFFED1C24); // Airtel Money
  static const Color flexipayColor = Color(0xFF0066CC); // Flexipay

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF113A5E), Color(0xFF0052A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  // Typography - Using Inter (Uganda English)
  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get heading3 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get heading4 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        height: 1.2,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  // Currency Formatting for UGX
  static String formatUGX(double amount) {
    return 'UGX ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  // Phone number formatting for Uganda
  static String formatUgandaPhone(String phone) {
    // Format: +256 XXX XXX XXX or 0XXX XXX XXX
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (phone.startsWith('256')) {
      phone = phone.substring(3);
    } else if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    
    if (phone.length == 9) {
      return '0${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: heading4.copyWith(color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.all(16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: button.copyWith(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
      ),
    );
  }
}

// Uganda-specific constants
class UgandaConstants {
  // Mobile Money Networks
  static const List<Map<String, dynamic>> mobileMoneyNetworks = [
    {
      'name': 'MTN Mobile Money',
      'code': 'MTN',
      'color': Color(0xFFFFCC00),
      'icon': 'mtn',
      'prefix': ['077', '078'],
    },
    {
      'name': 'Airtel Money',
      'code': 'AIRTEL',
      'color': Color(0xFFED1C24),
      'icon': 'airtel',
      'prefix': ['075', '070'],
    },
    {
      'name': 'Flexipay',
      'code': 'FLEXIPAY',
      'color': Color(0xFF0066CC),
      'icon': 'flexipay',
      'prefix': [],
    },
  ];

  // Telecom Networks for Airtime/Data
  static const List<Map<String, dynamic>> telecomNetworks = [
    {
      'name': 'MTN Uganda',
      'code': 'MTN',
      'color': Color(0xFFFFCC00),
      'icon': 'mtn',
    },
    {
      'name': 'Airtel Uganda',
      'code': 'AIRTEL',
      'color': Color(0xFFED1C24),
      'icon': 'airtel',
    },
  ];

  // Utility Providers
  static const List<Map<String, dynamic>> utilityProviders = [
    {
      'name': 'UMEME (Yaka)',
      'code': 'UMEME',
      'type': 'electricity',
      'icon': 'electricity',
    },
    {
      'name': 'National Water',
      'code': 'NWSC',
      'type': 'water',
      'icon': 'water',
    },
    {
      'name': 'DStv',
      'code': 'DSTV',
      'type': 'tv',
      'icon': 'tv',
    },
    {
      'name': 'StarTimes',
      'code': 'STARTIMES',
      'type': 'tv',
      'icon': 'tv',
    },
  ];

  // School Payment Systems
  static const List<Map<String, dynamic>> schoolPaymentSystems = [
    {
      'name': 'Bien School',
      'code': 'BIEN_SCHOOL',
      'requiresSchoolCode': true,
    },
    {
      'name': 'School Pay',
      'code': 'SCHOOL_PAY',
      'requiresSchoolCode': true,
    },
    {
      'name': 'Sure Pay',
      'code': 'SURE_PAY',
      'requiresSchoolCode': false,
    },
  ];

  // Transaction Limits (in UGX)
  static const Map<String, double> transactionLimits = {
    'daily_cashout': 5000000, // 5M UGX
    'daily_transfer': 10000000, // 10M UGX
    'single_transaction': 2000000, // 2M UGX
    'monthly_limit': 50000000, // 50M UGX
  };

  // KYC Levels
  static const List<Map<String, dynamic>> kycLevels = [
    {
      'level': 1,
      'name': 'Basic',
      'dailyLimit': 500000, // 500K UGX
      'requirements': ['Phone verification', 'Email verification'],
    },
    {
      'level': 2,
      'name': 'Verified',
      'dailyLimit': 2000000, // 2M UGX
      'requirements': ['National ID', 'Selfie'],
    },
    {
      'level': 3,
      'name': 'Premium',
      'dailyLimit': 10000000, // 10M UGX
      'requirements': ['National ID', 'Passport photo', 'Address proof'],
    },
  ];
}