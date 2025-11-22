import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';
// import '../../services/auth_service.dart'; // Your API service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isEmailLogin = true; // Toggle between email and phone

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleLoginType() {
    setState(() {
      _isEmailLogin = !_isEmailLogin;
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
                const SizedBox(height: 60),
                
                // Logo and Title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 40,
                      ),
                    ).animate().scale(duration: 600.ms).then().shake(),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Welcome Back',
                      style: AppTheme.heading1.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Sign in to your account to continue',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Login Type Toggle
                Row(
                  children: [
                    Expanded(
                      child: _LoginTypeButton(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        isSelected: _isEmailLogin,
                        onTap: () {
                          if (!_isEmailLogin) _toggleLoginType();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LoginTypeButton(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        isSelected: !_isEmailLogin,
                        onTap: () {
                          if (_isEmailLogin) _toggleLoginType();
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 24),
                
                // Email/Phone Field
                TextFormField(
                  controller: _identifierController,
                  keyboardType: _isEmailLogin 
                      ? TextInputType.emailAddress 
                      : TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _isEmailLogin ? 'Email' : 'Phone Number',
                    hintText: _isEmailLogin 
                        ? 'Enter your email' 
                        : 'e.g., +256 700 000 000',
                    prefixIcon: Icon(
                      _isEmailLogin ? Icons.email_outlined : Icons.phone_outlined,
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
                      return _isEmailLogin 
                          ? 'Please enter your email' 
                          : 'Please enter your phone number';
                    }
                    
                    if (_isEmailLogin) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    } else {
                      final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                      if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(cleanPhone)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
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
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        Text(
                          'Remember me',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1200.ms),
                
                const SizedBox(height: 32),
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 32),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // API Call
        // final response = await AuthService.login(
        //   identifier: _identifierController.text.trim(),
        //   password: _passwordController.text,
        //   identifierType: _isEmailLogin ? 'email' : 'phone',
        //   rememberMe: _rememberMe,
        // );
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // Handle response
        // if (response.success) {
        //   // Save tokens
        //   await SecureStorage.saveTokens(
        //     accessToken: response.data.tokens.accessToken,
        //     refreshToken: response.data.tokens.refreshToken,
        //   );
        //   
        //   // Save user data
        //   await UserPreferences.saveUser(response.data.user);
        //   
        //   Navigator.pushReplacementNamed(context, '/home');
        // }
        
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/home');
        
      } catch (e) {
        setState(() => _isLoading = false);
        
        // Handle specific errors
        String errorMessage = 'Login failed. Please try again.';
        
        // if (e is ApiException) {
        //   switch (e.statusCode) {
        //     case 401:
        //       errorMessage = 'Invalid credentials';
        //       break;
        //     case 403:
        //       errorMessage = 'Please verify your account';
        //       // Navigate to OTP verification
        //       break;
        //     case 423:
        //       errorMessage = 'Account temporarily locked';
        //       break;
        //   }
        // }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

class _LoginTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LoginTypeButton({
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






























// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../../core/design_system/app_theme.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//   bool _rememberMe = false;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 60),
                
//                 // Logo and Title
//                 Column(
//                   children: [
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryColor,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppTheme.primaryColor.withOpacity(0.3),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.account_balance,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     ).animate().scale(duration: 600.ms).then().shake(),
                    
//                     const SizedBox(height: 24),
                    
//                     Text(
//                       'Welcome Back',
//                       style: AppTheme.heading1.copyWith(
//                         color: AppTheme.textPrimary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ).animate().fadeIn(delay: 200.ms),
                    
//                     const SizedBox(height: 8),
                    
//                     Text(
//                       'Sign in to your account to continue',
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                       textAlign: TextAlign.center,
//                     ).animate().fadeIn(delay: 400.ms),
//                   ],
//                 ),
                
//                 const SizedBox(height: 48),
                
//                 // Email Field
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'Enter your email',
//                     prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: AppTheme.borderColor),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: AppTheme.borderColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: AppTheme.surfaceColor,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
//                 // Password Field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: !_isPasswordVisible,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                         color: AppTheme.textSecondary,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: AppTheme.borderColor),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: AppTheme.borderColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: AppTheme.surfaceColor,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
//                 // Remember Me & Forgot Password
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: _rememberMe,
//                           onChanged: (value) {
//                             setState(() {
//                               _rememberMe = value ?? false;
//                             });
//                           },
//                           activeColor: AppTheme.primaryColor,
//                         ),
//                         Text(
//                           'Remember me',
//                           style: AppTheme.bodySmall.copyWith(
//                             color: AppTheme.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/forgot-password');
//                       },
//                       child: Text(
//                         'Forgot Password?',
//                         style: AppTheme.bodySmall.copyWith(
//                           color: AppTheme.primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ).animate().fadeIn(delay: 1000.ms),
                
//                 const SizedBox(height: 32),
                
//                 // Login Button
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primaryColor,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: _isLoading
//                       ? SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : Text(
//                           'Sign In',
//                           style: AppTheme.bodyLarge.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 32),
                
//                 // Sign Up Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account? ",
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/signup');
//                       },
//                       child: Text(
//                         'Sign Up',
//                         style: AppTheme.bodyMedium.copyWith(
//                           color: AppTheme.primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ).animate().fadeIn(delay: 1400.ms),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
      
//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));
      
//       setState(() => _isLoading = false);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Login successful!'),
//           backgroundColor: AppTheme.successColor,
//         ),
//       );
      
//       Navigator.pushReplacementNamed(context, '/home');
//     }
//   }
// }