import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new card
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Available',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$24,562.80',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Checking',
                              style: AppTheme.caption.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$18,420.50',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Savings',
                              style: AppTheme.caption.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$6,142.30',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Payment Methods
            Text(
              'Payment Methods',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            // Cards List
            _buildCardItem(
              'Visa ending in 4589',
              'Primary Card',
              'Expires 12/28',
              Icons.credit_card,
              AppTheme.primaryColor,
              true,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            _buildCardItem(
              'Mastercard ending in 1234',
              'Secondary Card',
              'Expires 08/26',
              Icons.credit_card,
              AppTheme.accentColor,
              false,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            _buildCardItem(
              'Apple Pay',
              'Digital Wallet',
              'Connected',
              Icons.phone_iphone,
              AppTheme.infoColor,
              false,
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 1000.ms),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add money
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Transfer money
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Transfer'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Account Details
            Text(
              'Account Details',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 1400.ms),
            
            const SizedBox(height: 16),
            
            _buildAccountDetail('Account Number', '**** **** **** 1234'),
            _buildAccountDetail('Routing Number', '021000021'),
            _buildAccountDetail('Account Type', 'Personal Checking'),
            _buildAccountDetail('Member Since', 'January 2020'),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(String title, String subtitle, String detail, IconData icon, Color color, bool isPrimary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? color : AppTheme.borderColor,
          width: isPrimary ? 2 : 1,
        ),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
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
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Primary',
                style: AppTheme.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountDetail(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
