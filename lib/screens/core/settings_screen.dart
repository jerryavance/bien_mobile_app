import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  String _selectedCurrency = 'UGX';
  String _selectedLanguage = 'English';

  final List<String> _currencies = ['UGX', 'USD', 'EUR', 'GBP'];
  final List<String> _languages = ['English', 'Luganda'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account', Icons.person),
            
            _buildSettingItem(
              'Profile Information',
              'Update your personal details',
              Icons.edit,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Change Password',
              'Update your account password',
              Icons.lock,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Two-Factor Authentication',
              'Add an extra layer of security',
              Icons.security,
              () {
                Navigator.pushNamed(context, '/security-settings');
              },
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildSectionHeader('Preferences', Icons.settings),
            
            _buildToggleSetting(
              'Enable Notifications',
              'Receive alerts for transactions',
              Icons.notifications,
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildToggleSetting(
              'Biometric Authentication',
              'Use fingerprint or face ID',
              Icons.fingerprint,
              _biometricEnabled,
              (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildToggleSetting(
              'Dark Mode',
              'Switch theme (coming soon)',
              Icons.dark_mode,
              _darkModeEnabled,
              (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dark mode coming soon')),
                );
              },
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildDropdownSetting(
              'Currency',
              'Display currency preference',
              Icons.attach_money,
              _selectedCurrency,
              _currencies,
              (value) {
                setState(() {
                  _selectedCurrency = value;
                });
              },
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildDropdownSetting(
              'Language',
              'Choose your language',
              Icons.language,
              _selectedLanguage,
              _languages,
              (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Security Section
            _buildSectionHeader('Security', Icons.shield),
            
            _buildSettingItem(
              'Privacy Settings',
              'Manage data sharing',
              Icons.privacy_tip,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Login History',
              'View recent login activities',
              Icons.history,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Trusted Devices',
              'Manage authorized devices',
              Icons.devices,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSectionHeader('Support', Icons.help),
            
            _buildSettingItem(
              'Help Center',
              'Find answers to questions',
              Icons.help_outline,
              () {
                Navigator.pushNamed(context, '/help-support');
              },
            ).animate().fadeIn(delay: 1300.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Contact Support',
              'Get in touch with our team',
              Icons.support_agent,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Feedback',
              'Share your thoughts',
              Icons.feedback,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // App Information Section
            _buildSectionHeader('App Information', Icons.info),
            
            _buildSettingItem(
              'About Bien Payments',
              'Version 1.0.0',
              Icons.info_outline,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bien Payments v1.0.0')),
                );
              },
            ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Terms of Service',
              'Read our terms',
              Icons.description_outlined,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1700.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            _buildSettingItem(
              'Privacy Policy',
              'Learn about data protection',
              Icons.privacy_tip_outlined,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
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
                child: const Text('Logout'),
              ),
            ).animate().fadeIn(delay: 1900.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
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

  Widget _buildToggleSetting(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(String title, String subtitle, IconData icon, String value, List<String> options, ValueChanged<String> onChanged) {
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
        trailing: DropdownButton<String>(
          value: value,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: options.map((option) => DropdownMenuItem(
            value: option,
            child: Text(option),
          )).toList(),
          underline: Container(),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
                
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
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

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _notificationsEnabled = true;
//   bool _biometricEnabled = false;
//   bool _darkModeEnabled = false;
//   String _selectedCurrency = 'USD';
//   String _selectedLanguage = 'English';

//   final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
//   final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Account Section
//             _buildSectionHeader('Account', Icons.person),
            
//             _buildSettingItem(
//               'Profile Information',
//               'Update your personal details and preferences',
//               Icons.edit,
//               () {},
//             ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Change Password',
//               'Update your account password',
//               Icons.lock,
//               () {},
//             ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Two-Factor Authentication',
//               'Add an extra layer of security',
//               Icons.security,
//               () {
//                 Navigator.pushNamed(context, '/security-settings');
//               },
//             ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 24),
            
//             // Preferences Section
//             _buildSectionHeader('Preferences', Icons.settings),
            
//             _buildToggleSetting(
//               'Enable Notifications',
//               'Receive alerts for transactions and updates',
//               Icons.notifications,
//               _notificationsEnabled,
//               (value) {
//                 setState(() {
//                   _notificationsEnabled = value;
//                 });
//               },
//             ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildToggleSetting(
//               'Biometric Authentication',
//               'Use fingerprint or face ID to login',
//               Icons.fingerprint,
//               _biometricEnabled,
//               (value) {
//                 setState(() {
//                   _biometricEnabled = value;
//                 });
//               },
//             ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildToggleSetting(
//               'Dark Mode',
//               'Switch between light and dark themes',
//               Icons.dark_mode,
//               _darkModeEnabled,
//               (value) {
//                 setState(() {
//                   _darkModeEnabled = value;
//                 });
//               },
//             ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildDropdownSetting(
//               'Currency',
//               'Select your preferred currency',
//               Icons.attach_money,
//               _selectedCurrency,
//               _currencies,
//               (value) {
//                 setState(() {
//                   _selectedCurrency = value;
//                 });
//               },
//             ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildDropdownSetting(
//               'Language',
//               'Choose your preferred language',
//               Icons.language,
//               _selectedLanguage,
//               _languages,
//               (value) {
//                 setState(() {
//                   _selectedLanguage = value;
//                 });
//               },
//             ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 24),
            
//             // Security Section
//             _buildSectionHeader('Security', Icons.shield),
            
//             _buildSettingItem(
//               'Privacy Settings',
//               'Manage your data sharing preferences',
//               Icons.privacy_tip,
//               () {},
//             ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Login History',
//               'View your recent login activities',
//               Icons.history,
//               () {},
//             ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Trusted Devices',
//               'Manage your authorized devices',
//               Icons.devices,
//               () {},
//             ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 24),
            
//             // Financial Section
//             _buildSectionHeader('Financial', Icons.account_balance),
            
//             _buildSettingItem(
//               'Bank Accounts',
//               'Manage your connected bank accounts',
//               Icons.account_balance_wallet,
//               () {},
//             ).animate().fadeIn(delay: 1300.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Payment Methods',
//               'Update your payment preferences',
//               Icons.credit_card,
//               () {},
//             ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Tax Documents',
//               'Access your tax forms and reports',
//               Icons.description,
//               () {},
//             ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Currency Converter',
//               'Convert between different currencies',
//               Icons.currency_exchange,
//               () {
//                 Navigator.pushNamed(context, '/currency-converter');
//               },
//             ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Bill Payments',
//               'Manage and pay your bills',
//               Icons.receipt_long,
//               () {
//                 Navigator.pushNamed(context, '/bill-payments');
//               },
//             ).animate().fadeIn(delay: 1700.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Loan Calculator',
//               'Calculate loan payments and interest',
//               Icons.calculate,
//               () {
//                 Navigator.pushNamed(context, '/loan-calculator');
//               },
//             ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Tax Calculator',
//               'Estimate your tax calculations',
//               Icons.assessment,
//               () {
//                 Navigator.pushNamed(context, '/tax-calculator');
//               },
//             ).animate().fadeIn(delay: 1900.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 24),
            
//             // Support Section
//             _buildSectionHeader('Support', Icons.help),
            
//             _buildSettingItem(
//               'Help Center',
//               'Find answers to common questions',
//               Icons.help_outline,
//               () {
//                 Navigator.pushNamed(context, '/help-support');
//               },
//             ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Contact Support',
//               'Get in touch with our team',
//               Icons.support_agent,
//               () {},
//             ).animate().fadeIn(delay: 1700.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Feedback',
//               'Share your thoughts with us',
//               Icons.feedback,
//               () {},
//             ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 24),
            
//             // App Information Section
//             _buildSectionHeader('App Information', Icons.info),
            
//             _buildSettingItem(
//               'About FinTech Pro',
//               'Version 1.0.0',
//               Icons.info_outline,
//               () {},
//             ).animate().fadeIn(delay: 1900.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Terms of Service',
//               'Read our terms and conditions',
//               Icons.description_outlined,
//               () {},
//             ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Privacy Policy',
//               'Learn about data protection',
//               Icons.privacy_tip_outlined,
//               () {},
//             ).animate().fadeIn(delay: 2100.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             _buildSettingItem(
//               'Help & Support',
//               'Get help and contact support',
//               Icons.help_outline,
//               () {
//                 Navigator.pushNamed(context, '/help-support');
//               },
//             ).animate().fadeIn(delay: 2200.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 32),
            
//             // Logout Button
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () {
//                   _showLogoutDialog(context);
//                 },
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: AppTheme.errorColor,
//                   side: BorderSide(color: AppTheme.errorColor),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('Logout'),
//               ),
//             ).animate().fadeIn(delay: 2300.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
            
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: AppTheme.primaryColor,
//             size: 20,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: AppTheme.heading4.copyWith(
//               color: AppTheme.textPrimary,
//             ),
//           ),
//         ],
//       ),
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

//   Widget _buildToggleSetting(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
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
//         trailing: Switch(
//           value: value,
//           onChanged: onChanged,
//           activeThumbColor: AppTheme.primaryColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownSetting(String title, String subtitle, IconData icon, String value, List<String> options, ValueChanged<String> onChanged) {
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
//         trailing: DropdownButton<String>(
//           value: value,
//           onChanged: (newValue) {
//             if (newValue != null) {
//               onChanged(newValue);
//             }
//           },
//           items: options.map((option) => DropdownMenuItem(
//             value: option,
//             child: Text(option),
//           )).toList(),
//           underline: Container(),
//           icon: Icon(
//             Icons.keyboard_arrow_down,
//             color: AppTheme.textTertiary,
//           ),
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
