import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit profile
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          
          // Show loading or user data
          if (authProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          // Get user initials for avatar
          String getInitials() {
            if (user?.fullName != null && user!.fullName.isNotEmpty) {
              final names = user.fullName.split(' ');
              if (names.length >= 2) {
                return '${names[0][0]}${names[1][0]}'.toUpperCase();
              }
              return user.fullName[0].toUpperCase();
            }
            return 'U';
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          getInitials(),
                          style: AppTheme.heading1.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'User',
                        style: AppTheme.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'user@example.com',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      if (user?.phoneNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user!.phoneNumber,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('Verified', 
                            user?.isPhoneVerified == true ? 'Yes' : 'No'),
                          _buildProfileStat('Email', 
                            user?.isEmailVerified == true ? 'Verified' : 'Pending'),
                          _buildProfileStat('Status', 'Active'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                const SizedBox(height: 24),
                
                // Account Settings
                Text(
                  'Account Settings',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  'Personal Information',
                  'Update your personal details',
                  Icons.person,
                  () {},
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Security Settings',
                  'Manage passwords and 2FA',
                  Icons.security,
                  () {
                    Navigator.pushNamed(context, '/security-settings');
                  },
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Notification Preferences',
                  'Customize your alerts',
                  Icons.notifications,
                  () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Privacy Settings',
                  'Control your data sharing',
                  Icons.privacy_tip,
                  () {},
                ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                const SizedBox(height: 24),
                
                // Financial Tools
                Text(
                  'Financial Tools',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 1200.ms),
                
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  'Budget Planner',
                  'Create and manage budgets',
                  Icons.account_balance_wallet,
                  () {
                    Navigator.pushNamed(context, '/budget');
                  },
                ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Investment Portfolio',
                  'Track your investments',
                  Icons.trending_up,
                  () {
                    Navigator.pushNamed(context, '/investments');
                  },
                ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Tax Documents',
                  'Access tax forms and reports',
                  Icons.description,
                  () {},
                ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Currency Converter',
                  'Convert between currencies',
                  Icons.currency_exchange,
                  () {
                    Navigator.pushNamed(context, '/currency-converter');
                  },
                ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Bill Payments',
                  'Manage and pay bills',
                  Icons.receipt_long,
                  () {
                    Navigator.pushNamed(context, '/bill-payments');
                  },
                ).animate().fadeIn(delay: 2200.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Loan Calculator',
                  'Calculate loan payments',
                  Icons.calculate,
                  () {
                    Navigator.pushNamed(context, '/loan-calculator');
                  },
                ).animate().fadeIn(delay: 2400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Tax Calculator',
                  'Estimate tax calculations',
                  Icons.assessment,
                  () {
                    Navigator.pushNamed(context, '/tax-calculator');
                  },
                ).animate().fadeIn(delay: 2600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                const SizedBox(height: 24),
                
                // Support & Help
                Text(
                  'Support & Help',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 2000.ms),
                
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  'Help Center',
                  'Find answers to common questions',
                  Icons.help,
                  () {
                    Navigator.pushNamed(context, '/help-support');
                  },
                ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Contact Support',
                  'Get in touch with our team',
                  Icons.support_agent,
                  () {},
                ).animate().fadeIn(delay: 2800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Feedback',
                  'Share your thoughts with us',
                  Icons.feedback,
                  () {},
                ).animate().fadeIn(delay: 3000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                const SizedBox(height: 24),
                
                // App Information
                Text(
                  'App Information',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 3200.ms),
                
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  'About Bien',
                  'Version 1.0.0',
                  Icons.info,
                  () {},
                ).animate().fadeIn(delay: 3000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Terms of Service',
                  'Read our terms and conditions',
                  Icons.description,
                  () {},
                ).animate().fadeIn(delay: 3200.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                _buildSettingItem(
                  'Privacy Policy',
                  'Learn about data protection',
                  Icons.privacy_tip,
                  () {},
                ).animate().fadeIn(delay: 3400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                const SizedBox(height: 32),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.errorColor),
                            ),
                          )
                        : const Text('Logout'),
                  ),
                ).animate().fadeIn(delay: 3600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.heading4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: AppTheme.errorColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout? You will need to sign in again to access your account.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog
                Navigator.of(dialogContext).pop();
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Logging out...',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                
                // Perform logout
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                
                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Navigate to login screen and remove all previous routes
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully logged out'),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}


















// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../../core/design_system/app_theme.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               // Edit profile
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Profile Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.primaryColor.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.white,
//                     child: Text(
//                       'AVJ',
//                       style: AppTheme.heading1.copyWith(
//                         color: AppTheme.primaryColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Anguzu Vance Jerry',
//                     style: AppTheme.heading3.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Premium Member',
//                     style: AppTheme.bodyMedium.copyWith(
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildProfileStat('Accounts', '3'),
//                       _buildProfileStat('Cards', '2'),
//                       _buildProfileStat('Member Since', '2025'),
//                     ],
//                   ),
//                 ],
//               ),
//             ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             const SizedBox(height: 24),
            
//             // Account Settings
//             Text(
//               'Account Settings',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ).animate().fadeIn(delay: 200.ms),
            
//             const SizedBox(height: 16),
            
//             _buildSettingItem(
//               'Personal Information',
//               'Update your personal details',
//               Icons.person,
//               () {},
//             ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Security Settings',
//               'Manage passwords and 2FA',
//               Icons.security,
//               () {
//                 Navigator.pushNamed(context, '/security-settings');
//               },
//             ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Notification Preferences',
//               'Customize your alerts',
//               Icons.notifications,
//               () {
//                 Navigator.pushNamed(context, '/notifications');
//               },
//             ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Privacy Settings',
//               'Control your data sharing',
//               Icons.privacy_tip,
//               () {},
//             ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             const SizedBox(height: 24),
            
//             // Financial Tools
//             Text(
//               'Financial Tools',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ).animate().fadeIn(delay: 1200.ms),
            
//             const SizedBox(height: 16),
            
//             _buildSettingItem(
//               'Budget Planner',
//               'Create and manage budgets',
//               Icons.account_balance_wallet,
//               () {
//                 Navigator.pushNamed(context, '/budget');
//               },
//             ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Investment Portfolio',
//               'Track your investments',
//               Icons.trending_up,
//               () {
//                 Navigator.pushNamed(context, '/investments');
//               },
//             ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Tax Documents',
//               'Access tax forms and reports',
//               Icons.description,
//               () {},
//             ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Currency Converter',
//               'Convert between currencies',
//               Icons.currency_exchange,
//               () {
//                 Navigator.pushNamed(context, '/currency-converter');
//               },
//             ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Bill Payments',
//               'Manage and pay bills',
//               Icons.receipt_long,
//               () {
//                 Navigator.pushNamed(context, '/bill-payments');
//               },
//             ).animate().fadeIn(delay: 2200.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Loan Calculator',
//               'Calculate loan payments',
//               Icons.calculate,
//               () {
//                 Navigator.pushNamed(context, '/loan-calculator');
//               },
//             ).animate().fadeIn(delay: 2400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Tax Calculator',
//               'Estimate tax calculations',
//               Icons.assessment,
//               () {
//                 Navigator.pushNamed(context, '/tax-calculator');
//               },
//             ).animate().fadeIn(delay: 2600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             const SizedBox(height: 24),
            
//             // Support & Help
//             Text(
//               'Support & Help',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ).animate().fadeIn(delay: 2000.ms),
            
//             const SizedBox(height: 16),
            
//             _buildSettingItem(
//               'Help Center',
//               'Find answers to common questions',
//               Icons.help,
//               () {
//                 Navigator.pushNamed(context, '/help-support');
//               },
//             ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Contact Support',
//               'Get in touch with our team',
//               Icons.support_agent,
//               () {},
//             ).animate().fadeIn(delay: 2800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Feedback',
//               'Share your thoughts with us',
//               Icons.feedback,
//               () {},
//             ).animate().fadeIn(delay: 3000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             const SizedBox(height: 24),
            
//             // App Information
//             Text(
//               'App Information',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ).animate().fadeIn(delay: 3200.ms),
            
//             const SizedBox(height: 16),
            
//             _buildSettingItem(
//               'About Bien',
//               'Version 1.0.0',
//               Icons.info,
//               () {},
//             ).animate().fadeIn(delay: 3000.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Terms of Service',
//               'Read our terms and conditions',
//               Icons.description,
//               () {},
//             ).animate().fadeIn(delay: 3200.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             _buildSettingItem(
//               'Privacy Policy',
//               'Learn about data protection',
//               Icons.privacy_tip,
//               () {},
//             ).animate().fadeIn(delay: 3400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             const SizedBox(height: 32),
            
//             // Logout Button
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () {
//                   // Show logout confirmation
//                   _showLogoutDialog(context);
//                 },
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: AppTheme.errorColor,
//                   side: BorderSide(color: AppTheme.errorColor),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('Logout'),
//               ),
//             ).animate().fadeIn(delay: 3600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileStat(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: AppTheme.heading4.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: AppTheme.caption.copyWith(
//             color: Colors.white.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: AppTheme.surfaceColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: onTap,
//         leading: Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: AppTheme.primaryColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: AppTheme.primaryColor,
//             size: 24,
//           ),
//         ),
//         title: Text(
//           title,
//           style: AppTheme.bodyMedium.copyWith(
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: AppTheme.bodySmall.copyWith(
//             color: AppTheme.textSecondary,
//           ),
//         ),
//         trailing: Icon(
//           Icons.chevron_right,
//           color: AppTheme.textTertiary,
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Logout',
//             style: AppTheme.heading4.copyWith(
//               color: AppTheme.textPrimary,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to logout?',
//             style: AppTheme.bodyMedium.copyWith(
//               color: AppTheme.textSecondary,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Cancel',
//                 style: AppTheme.bodyMedium.copyWith(
//                   color: AppTheme.textSecondary,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Perform logout
//                 Navigator.of(context).pop();
//                 // Navigate to login screen
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.errorColor,
//               ),
//               child: const Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
