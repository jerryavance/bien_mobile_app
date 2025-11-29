import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isEmail = true;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _toggleInputType() {
    setState(() {
      _isEmail = !_isEmail;
      _identifierController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                    Icons.lock_reset,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ).animate().scale(duration: 600.ms),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Forgot Password?',
                  style: AppTheme.heading1.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Enter your ${_isEmail ? 'email address' : 'phone number'} and we\'ll send you a verification code to reset your password',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 48),
                
                // Input Type Toggle
                Row(
                  children: [
                    Expanded(
                      child: _InputTypeButton(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        isSelected: _isEmail,
                        onTap: () {
                          if (!_isEmail) _toggleInputType();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputTypeButton(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        isSelected: !_isEmail,
                        onTap: () {
                          if (_isEmail) _toggleInputType();
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 24),
                
                // Email or Phone Input
                TextFormField(
                  controller: _identifierController,
                  keyboardType: _isEmail 
                      ? TextInputType.emailAddress 
                      : TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _isEmail ? 'Email Address' : 'Phone Number',
                    hintText: _isEmail 
                        ? 'Enter your email' 
                        : 'e.g., +256 700 000 000',
                    prefixIcon: Icon(
                      _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                      color: AppTheme.textSecondary,
                    ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _isEmail 
                          ? 'Please enter your email' 
                          : 'Please enter your phone number';
                    }
                    
                    if (_isEmail) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    } else {
                      // Remove spaces and special characters for validation
                      final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                      if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(cleanPhone)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    
                    return null;
                  },
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 32),
                
                // Send Code Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleSendCode,
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
                              'Send Verification Code',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0),
                
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
                
                const SizedBox(height: 24),
                
                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendCode() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.forgotPassword(
        _identifierController.text.trim(),
        identifierType: _isEmail ? 'email' : 'phone',
      );
      
      if (success && mounted) {
        // Navigate to OTP verification for password reset
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'verificationType': 'reset_password',
            'needsInitialSend': false, // OTP already sent by forgotPassword
          },
        );
      }
    }
  }
}

class _InputTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InputTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}