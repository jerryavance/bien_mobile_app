import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/design_system/app_theme.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // ✅ Automatically trigger first OTP send if coming from login/registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialOtpIfNeeded();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  /// ✅ Send initial OTP if this is first time on screen
  Future<void> _sendInitialOtpIfNeeded() async {
    final authProvider = context.read<AuthProvider>();
    final identifier = authProvider.pendingVerificationPhone;
    
    // Check if we have a pending identifier but no OTP sent yet
    if (identifier != null && identifier.isNotEmpty) {
      print('OTP Screen: Found pending identifier: $identifier');
      
      // Check if we need to send the initial OTP
      // This happens when user comes from login with unverified account
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final needsInitialSend = args?['needsInitialSend'] as bool? ?? false;
      
      if (needsInitialSend) {
        print('OTP Screen: Sending initial OTP...');
        final verificationType = args?['verificationType'] ?? 'signup';
        
        final success = await authProvider.resendOtp(
          verificationType: verificationType,
          channel: 'sms',
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification code sent to $identifier'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final verificationType = args?['verificationType'] ?? 'signup';
    
    // Get phone from AuthProvider
    final authProvider = context.watch<AuthProvider>();
    final phoneNumber = authProvider.pendingVerificationPhone ?? 'your phone';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ).animate().fadeIn(),
              
              const SizedBox(height: 40),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.message_outlined,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ).animate().scale(duration: 600.ms),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Verify Your Phone Number',
                style: AppTheme.heading1.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 12),
              
              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'We\'ve sent a 6-digit verification code to\n',
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 48),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return _OtpInputField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) => _onOtpChanged(value, index),
                  );
                }),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              
              // Error Message
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Verify Code',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 24),
              
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (_resendTimer > 0)
                    Text(
                      'Resend in ${_resendTimer}s',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _handleResendCode,
                      child: Text(
                        'Resend Code',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _onOtpChanged(String value, int index) {
    // Clear error when user types
    context.read<AuthProvider>().clearError();
    
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all fields are filled
    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      _handleVerify();
    }
  }

  void _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final verificationType = args?['verificationType'] ?? 'signup';
    
    bool success = false;
    
    // ✅ Handle different verification types
    if (verificationType == 'reset_password') {
      // Password reset flow - verify OTP with reset token
      success = await authProvider.verifyResetOtp(otp: otp);
    } else {
      // Normal signup/login flow - verify OTP with userId
      success = await authProvider.verifyOtp(
        otp: otp,
        verificationType: verificationType,
      );
    }
    
    if (success && mounted) {
      if (verificationType == 'reset_password') {
        // Navigate to reset password screen
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
        );
      } else {
        // Signup or login verification successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
  }

  void _handleResendCode() async {
    final authProvider = context.read<AuthProvider>();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final verificationType = args?['verificationType'] ?? 'signup';
    
    _startTimer();
    
    final success = await authProvider.resendOtp(
      verificationType: verificationType,
      channel: 'sms',
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to resend code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

class _OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const _OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTheme.heading2.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.surfaceColor,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';
// import '../../core/design_system/app_theme.dart';
// import '../../providers/auth_provider.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   const OtpVerificationScreen({super.key});

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
//   int _resendTimer = 60;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
    
//     // ✅ Automatically trigger first OTP send if coming from login/registration
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _sendInitialOtpIfNeeded();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _resendTimer = 60;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         setState(() => _resendTimer--);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   /// ✅ Send initial OTP if this is first time on screen
//   Future<void> _sendInitialOtpIfNeeded() async {
//     final authProvider = context.read<AuthProvider>();
//     final identifier = authProvider.pendingVerificationPhone;
    
//     // Check if we have a pending identifier but no OTP sent yet
//     if (identifier != null && identifier.isNotEmpty) {
//       print('OTP Screen: Found pending identifier: $identifier');
      
//       // Check if we need to send the initial OTP
//       // This happens when user comes from login with unverified account
//       final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//       final needsInitialSend = args?['needsInitialSend'] as bool? ?? false;
      
//       if (needsInitialSend) {
//         print('OTP Screen: Sending initial OTP...');
//         final verificationType = args?['verificationType'] ?? 'signup';
        
//         final success = await authProvider.resendOtp(
//           verificationType: verificationType,
//           channel: 'sms',
//         );
        
//         if (success && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Verification code sent to $identifier'),
//               backgroundColor: AppTheme.successColor,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     final verificationType = args?['verificationType'] ?? 'signup';
    
//     // Get phone from AuthProvider
//     final authProvider = context.watch<AuthProvider>();
//     final phoneNumber = authProvider.pendingVerificationPhone ?? 'your phone';

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),
              
//               // Back Button
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(
//                     Icons.arrow_back_ios,
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//               ).animate().fadeIn(),
              
//               const SizedBox(height: 40),
              
//               // Icon
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: AppTheme.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   Icons.message_outlined,
//                   color: AppTheme.primaryColor,
//                   size: 40,
//                 ),
//               ).animate().scale(duration: 600.ms),
              
//               const SizedBox(height: 32),
              
//               // Title
//               Text(
//                 'Verify Your Phone Number',
//                 style: AppTheme.heading1.copyWith(
//                   color: AppTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ).animate().fadeIn(delay: 200.ms),
              
//               const SizedBox(height: 12),
              
//               // Subtitle
//               RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: AppTheme.bodyMedium.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                   children: [
//                     const TextSpan(
//                       text: 'We\'ve sent a 6-digit verification code to\n',
//                     ),
//                     TextSpan(
//                       text: phoneNumber,
//                       style: TextStyle(
//                         color: AppTheme.primaryColor,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 400.ms),
              
//               const SizedBox(height: 48),
              
//               // OTP Input Fields
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(6, (index) {
//                   return _OtpInputField(
//                     controller: _controllers[index],
//                     focusNode: _focusNodes[index],
//                     onChanged: (value) => _onOtpChanged(value, index),
//                   );
//                 }),
//               ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              
//               // Error Message
//               Consumer<AuthProvider>(
//                 builder: (context, authProvider, _) {
//                   if (authProvider.errorMessage != null) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16),
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppTheme.errorColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: AppTheme.errorColor.withOpacity(0.3),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.error_outline,
//                               color: AppTheme.errorColor,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 authProvider.errorMessage!,
//                                 style: AppTheme.bodySmall.copyWith(
//                                   color: AppTheme.errorColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
              
//               const SizedBox(height: 32),
              
//               // Verify Button
//               Consumer<AuthProvider>(
//                 builder: (context, authProvider, _) {
//                   return ElevatedButton(
//                     onPressed: authProvider.isLoading ? null : _handleVerify,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: authProvider.isLoading
//                         ? SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : Text(
//                             'Verify Code',
//                             style: AppTheme.bodyLarge.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   );
//                 },
//               ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
              
//               const SizedBox(height: 24),
              
//               // Resend Code
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Didn't receive the code? ",
//                     style: AppTheme.bodyMedium.copyWith(
//                       color: AppTheme.textSecondary,
//                     ),
//                   ),
//                   if (_resendTimer > 0)
//                     Text(
//                       'Resend in ${_resendTimer}s',
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: AppTheme.textTertiary,
//                       ),
//                     )
//                   else
//                     TextButton(
//                       onPressed: _handleResendCode,
//                       child: Text(
//                         'Resend Code',
//                         style: AppTheme.bodyMedium.copyWith(
//                           color: AppTheme.primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ).animate().fadeIn(delay: 1000.ms),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _onOtpChanged(String value, int index) {
//     // Clear error when user types
//     context.read<AuthProvider>().clearError();
    
//     if (value.isNotEmpty && index < 5) {
//       _focusNodes[index + 1].requestFocus();
//     } else if (value.isEmpty && index > 0) {
//       _focusNodes[index - 1].requestFocus();
//     }
    
//     // Auto-verify when all fields are filled
//     if (_controllers.every((controller) => controller.text.isNotEmpty)) {
//       _handleVerify();
//     }
//   }

//   void _handleVerify() async {
//     final otp = _controllers.map((c) => c.text).join();
    
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please enter all 6 digits'),
//           backgroundColor: AppTheme.errorColor,
//         ),
//       );
//       return;
//     }
    
//     final authProvider = context.read<AuthProvider>();
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     final verificationType = args?['verificationType'] ?? 'signup';
    
//     final success = await authProvider.verifyOtp(
//       otp: otp,
//       verificationType: verificationType,
//     );
    
//     if (success && mounted) {
//       if (verificationType == 'reset_password') {
//         Navigator.pushNamed(
//           context,
//           '/reset-password',
//           arguments: {
//             'otp': otp,
//           },
//         );
//       } else {
//         // Signup or login verification successful
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Verification successful!'),
//             backgroundColor: AppTheme.successColor,
//           ),
//         );
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//       }
//     }
//   }

//   void _handleResendCode() async {
//     final authProvider = context.read<AuthProvider>();
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     final verificationType = args?['verificationType'] ?? 'signup';
    
//     _startTimer();
    
//     final success = await authProvider.resendOtp(
//       verificationType: verificationType,
//       channel: 'sms',
//     );
    
//     if (success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Verification code sent!'),
//           backgroundColor: AppTheme.successColor,
//         ),
//       );
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(authProvider.errorMessage ?? 'Failed to resend code'),
//           backgroundColor: AppTheme.errorColor,
//         ),
//       );
//     }
//   }
// }

// class _OtpInputField extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final Function(String) onChanged;

//   const _OtpInputField({
//     required this.controller,
//     required this.focusNode,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 50,
//       height: 60,
//       child: TextFormField(
//         controller: controller,
//         focusNode: focusNode,
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.number,
//         maxLength: 1,
//         style: AppTheme.heading2.copyWith(
//           color: AppTheme.textPrimary,
//           fontWeight: FontWeight.bold,
//         ),
//         decoration: InputDecoration(
//           counterText: '',
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppTheme.borderColor),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppTheme.borderColor),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
//           ),
//           filled: true,
//           fillColor: AppTheme.surfaceColor,
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//         ],
//         onChanged: onChanged,
//       ),
//     );
//   }
// }



