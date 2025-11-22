import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';
// import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Phone number country codes for East Africa and Zambia
  final List<Map<String, String>> _countryCodes = [
    {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬'},
    {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+255', 'country': 'Tanzania', 'flag': '🇹🇿'},
    {'code': '+250', 'country': 'Rwanda', 'flag': '🇷🇼'},
    {'code': '+257', 'country': 'Burundi', 'flag': '🇧🇮'},
    {'code': '+260', 'country': 'Zambia', 'flag': '🇿🇲'},
  ];
  
  String _selectedCountryCode = '+256';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                const SizedBox(height: 40),
                
                // Back Button and Title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Create Account',
                        style: AppTheme.heading1.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 8),
                
                Text(
                  'Join us and start managing your finances',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 32),
                
                // First Name and Last Name Row
                Row(
                  children: [
                    // First Name Field
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          hintText: 'John',
                          prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
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
                            return 'Required';
                          }
                          if (value.length < 2) {
                            return 'Too short';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Letters only';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Last Name Field
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Doe',
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
                            return 'Required';
                          }
                          if (value.length < 2) {
                            return 'Too short';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Letters only';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'john.doe@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
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
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Phone Field with Country Code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Code Selector
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                          items: _countryCodes.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Row(
                                children: [
                                  Text(
                                    country['flag']!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    country['code']!,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCountryCode = value!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone Number Field
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '700 000 000',
                          prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
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
                            return 'Phone number required';
                          }
                          if (value.length < 9) {
                            return 'Must be 9-10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
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
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return 'Must contain uppercase, lowercase and number';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 1200.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 1400.ms).slideX(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1600.ms),
                
                const SizedBox(height: 32),
                
                // Sign Up Button
                ElevatedButton(
                  onPressed: (_agreeToTerms && !_isLoading) ? _handleSignup : null,
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
                          'Create Account',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 32),
                
                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
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
                ).animate().fadeIn(delay: 2000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
      
      try {
        // API Call
        // final response = await AuthService.register(
        //   firstName: _firstNameController.text.trim(),
        //   lastName: _lastNameController.text.trim(),
        //   email: _emailController.text.trim(),
        //   phoneNumber: fullPhoneNumber,
        //   password: _passwordController.text,
        // );
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() => _isLoading = false);
        
        // Navigate to OTP verification
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'identifier': fullPhoneNumber,
            'isEmail': false,
            'verificationType': 'signup',
            // Pass userId from response: 'userId': response.data.userId,
          },
        );
        
      } catch (e) {
        setState(() => _isLoading = false);
        
        String errorMessage = 'Registration failed. Please try again.';
        
        // Handle specific errors
        // if (e is ApiException) {
        //   if (e.statusCode == 409) {
        //     errorMessage = e.message ?? 'Email or phone already registered';
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























// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../../core/design_system/app_theme.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//   bool _agreeToTerms = false;
//   bool _isLoading = false;

//   // Phone number country codes for East Africa and Zambia
//   final List<Map<String, String>> _countryCodes = [
//     {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬'},
//     {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪'},
//     {'code': '+255', 'country': 'Tanzania', 'flag': '🇹🇿'},
//     {'code': '+250', 'country': 'Rwanda', 'flag': '🇷🇼'},
//     {'code': '+257', 'country': 'Burundi', 'flag': '🇧🇮'},
//     {'code': '+260', 'country': 'Zambia', 'flag': '🇿🇲'},
//   ];
  
//   String _selectedCountryCode = '+256';

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
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
//                 const SizedBox(height: 40),
                
//                 // Back Button and Title
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: Icon(
//                         Icons.arrow_back_ios,
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Create Account',
//                         style: AppTheme.heading1.copyWith(
//                           color: AppTheme.textPrimary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(width: 48),
//                   ],
//                 ).animate().fadeIn(delay: 200.ms),
                
//                 const SizedBox(height: 8),
                
//                 Text(
//                   'Join us and start managing your finances',
//                   style: AppTheme.bodyMedium.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ).animate().fadeIn(delay: 400.ms),
                
//                 const SizedBox(height: 32),
                
//                 // Full Name Field
//                 TextFormField(
//                   controller: _fullNameController,
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                     labelText: 'Full Name',
//                     hintText: 'Enter your full name',
//                     prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
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
//                       return 'Please enter your full name';
//                     }
//                     if (value.length < 2) {
//                       return 'Name must be at least 2 characters';
//                     }
//                     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
//                       return 'Name can only contain letters';
//                     }
//                     return null;
//                   },
//                 ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
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
//                 ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
//                 // Phone Field with Country Code
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Country Code Selector
//                     Container(
//                       height: 60,
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: AppTheme.surfaceColor,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppTheme.borderColor),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _selectedCountryCode,
//                           icon: Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
//                           items: _countryCodes.map((country) {
//                             return DropdownMenuItem<String>(
//                               value: country['code'],
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     country['flag']!,
//                                     style: const TextStyle(fontSize: 20),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     country['code']!,
//                                     style: AppTheme.bodyMedium.copyWith(
//                                       color: AppTheme.textPrimary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() => _selectedCountryCode = value!);
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     // Phone Number Field
//                     Expanded(
//                       child: TextFormField(
//                         controller: _phoneController,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           LengthLimitingTextInputFormatter(10),
//                         ],
//                         decoration: InputDecoration(
//                           labelText: 'Phone Number',
//                           hintText: '700 000 000',
//                           prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppTheme.borderColor),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppTheme.borderColor),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
//                           ),
//                           filled: true,
//                           fillColor: AppTheme.surfaceColor,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter phone number';
//                           }
//                           if (value.length < 9) {
//                             return 'Phone number must be 9-10 digits';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
//                 // Password Field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: !_isPasswordVisible,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Create a strong password',
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
//                       return 'Please enter a password';
//                     }
//                     if (value.length < 8) {
//                       return 'Password must be at least 8 characters';
//                     }
//                     if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
//                       return 'Must contain uppercase, lowercase and number';
//                     }
//                     return null;
//                   },
//                 ).animate().fadeIn(delay: 1200.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
//                 // Confirm Password Field
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: !_isConfirmPasswordVisible,
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//                     hintText: 'Confirm your password',
//                     prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                         color: AppTheme.textSecondary,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ).animate().fadeIn(delay: 1400.ms).slideX(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 20),
                
//                 // Terms and Conditions
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreeToTerms,
//                       onChanged: (value) {
//                         setState(() {
//                           _agreeToTerms = value ?? false;
//                         });
//                       },
//                       activeColor: AppTheme.primaryColor,
//                     ),
//                     Expanded(
//                       child: RichText(
//                         text: TextSpan(
//                           style: AppTheme.bodySmall.copyWith(
//                             color: AppTheme.textSecondary,
//                           ),
//                           children: [
//                             const TextSpan(text: 'I agree to the '),
//                             TextSpan(
//                               text: 'Terms of Service',
//                               style: TextStyle(
//                                 color: AppTheme.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const TextSpan(text: ' and '),
//                             TextSpan(
//                               text: 'Privacy Policy',
//                               style: TextStyle(
//                                 color: AppTheme.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ).animate().fadeIn(delay: 1600.ms),
                
//                 const SizedBox(height: 32),
                
//                 // Sign Up Button
//                 ElevatedButton(
//                   onPressed: (_agreeToTerms && !_isLoading) ? _handleSignup : null,
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
//                           'Create Account',
//                           style: AppTheme.bodyLarge.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0),
                
//                 const SizedBox(height: 32),
                
//                 // Sign In Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Already have an account? ',
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: Text(
//                         'Sign In',
//                         style: AppTheme.bodyMedium.copyWith(
//                           color: AppTheme.primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ).animate().fadeIn(delay: 2000.ms),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleSignup() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
      
//       final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
      
//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));
      
//       setState(() => _isLoading = false);
      
//       // Navigate to OTP verification
//       Navigator.pushNamed(
//         context,
//         '/otp-verification',
//         arguments: {
//           'identifier': fullPhoneNumber,
//           'isEmail': false,
//           'verificationType': 'signup',
//         },
//       );
//     }
//   }
// }