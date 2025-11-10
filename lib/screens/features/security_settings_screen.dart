import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = true;
  bool _pinEnabled = true;
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  String _selectedPin = '1234';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Security Settings',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status Card
            Container(
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
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Score',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Excellent',
                          style: AppTheme.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your account is well protected',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '95/100',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Authentication Methods
            Text(
              'Authentication Methods',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            _buildSecurityOption(
              icon: Icons.fingerprint,
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face ID to unlock the app',
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
              delay: 400,
            ),

            _buildSecurityOption(
              icon: Icons.verified_user,
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security to your account',
              trailing: Switch(
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
              delay: 600,
            ),

            _buildSecurityOption(
              icon: Icons.pin,
              title: 'PIN Code',
              subtitle: 'Set a 4-digit PIN for quick access',
              trailing: Switch(
                value: _pinEnabled,
                onChanged: (value) {
                  setState(() {
                    _pinEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
              delay: 800,
            ),

            const SizedBox(height: 24),

            // Privacy Settings
            Text(
              'Privacy Settings',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 1000.ms),

            const SizedBox(height: 16),

            _buildSecurityOption(
              icon: Icons.notifications,
              title: 'Security Notifications',
              subtitle: 'Get notified about suspicious activities',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
              delay: 1200,
            ),

            _buildSecurityOption(
              icon: Icons.location_on,
              title: 'Location Services',
              subtitle: 'Allow location tracking for security',
              trailing: Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
              delay: 1400,
            ),

            const SizedBox(height: 24),

            // Security Actions
            Text(
              'Security Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 1600.ms),

            const SizedBox(height: 16),

            _buildActionButton(
              icon: Icons.lock_reset,
              title: 'Change PIN',
              subtitle: 'Update your 4-digit PIN code',
              onTap: () => _showChangePinDialog(),
              delay: 1800,
            ),

            _buildActionButton(
              icon: Icons.password,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _showChangePasswordDialog(),
              delay: 2000,
            ),

            _buildActionButton(
              icon: Icons.devices,
              title: 'Manage Devices',
              subtitle: 'View and remove connected devices',
              onTap: () => _showManageDevicesDialog(),
              delay: 2200,
            ),

            _buildActionButton(
              icon: Icons.history,
              title: 'Login History',
              subtitle: 'View recent login attempts',
              onTap: () => _showLoginHistoryDialog(),
              delay: 2400,
            ),

            const SizedBox(height: 32),

            // Emergency Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppTheme.errorColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Emergency Actions',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use these options only in emergency situations',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showFreezeAccountDialog(),
                          icon: Icon(Icons.pause_circle, color: AppTheme.errorColor),
                          label: Text(
                            'Freeze Account',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showReportFraudDialog(),
                          icon: Icon(Icons.report, color: AppTheme.errorColor),
                          label: Text(
                            'Report Fraud',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 2600.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.3, end: 0);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.secondaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textTertiary,
          size: 16,
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.3, end: 0);
  }

  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your new 4-digit PIN'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                hintText: 'Enter new PIN',
                counterText: '',
              ),
              onChanged: (value) {
                _selectedPin = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PIN updated successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter current password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm new password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showManageDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Devices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeviceTile('iPhone 14 Pro', 'Last active: 2 minutes ago', true),
            const SizedBox(height: 12),
            _buildDeviceTile('MacBook Pro', 'Last active: 1 hour ago', false),
            const SizedBox(height: 12),
            _buildDeviceTile('iPad Air', 'Last active: 1 day ago', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(String name, String lastActive, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? AppTheme.primaryColor : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.phone_iphone : Icons.computer,
            color: isCurrent ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCurrent ? AppTheme.primaryColor : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  lastActive,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current',
                style: AppTheme.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLoginHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginEntry('iPhone 14 Pro', 'Kampala, UG', '2 minutes ago', true),
            const SizedBox(height: 12),
            _buildLoginEntry('MacBook Pro', 'Arua, UG', '1 hour ago', false),
            const SizedBox(height: 12),
            _buildLoginEntry('iPad Air', 'Mbarara, UG', '1 day ago', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginEntry(String device, String location, String time, bool isSuccessful) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccessful ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccessful ? AppTheme.successColor : AppTheme.errorColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccessful ? Icons.check_circle : Icons.error,
            color: isSuccessful ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$location • $time',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFreezeAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Freeze Account'),
        content: Text('Are you sure you want to freeze your account? This will prevent all transactions and access until you contact support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account frozen. Contact support to reactivate.'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text('Freeze Account'),
          ),
        ],
      ),
    );
  }

  void _showReportFraudDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Fraud'),
        content: Text('If you suspect fraudulent activity, please contact our fraud department immediately at fraud@fintechpro.com or call +1 (800) 123-4567.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
