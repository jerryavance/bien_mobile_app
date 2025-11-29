import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/stats_grid.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch wallet data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWallet();
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###.##', 'en_US');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletProvider>().fetchWallet();
            },
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (walletProvider.isLoading && walletProvider.wallet == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (walletProvider.errorMessage != null && walletProvider.wallet == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    walletProvider.errorMessage!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WalletProvider>().fetchWallet();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final wallet = walletProvider.wallet;
          final totalBalance = wallet?.balance ?? 0.0;

          return RefreshIndicator(
            onRefresh: () => context.read<WalletProvider>().fetchWallet(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Available',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            if (walletProvider.isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${wallet?.currency ?? 'UGX'} ${_formatCurrency(totalBalance)}',
                          style: AppTheme.heading1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wallet Code: ${wallet?.id.substring(0, 8) ?? 'N/A'}',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.ms,
                      ),

                  const SizedBox(height: 24),

                  // This Month Stats
                  Text(
                    'This Month Overview',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  const StatsGrid()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.3, end: 0, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Account Status
                  Row(
                    children: [
                      Text(
                        'Account Status',
                        style: AppTheme.heading4.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: wallet?.isActive == true
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          wallet?.isActive == true ? 'Active' : 'Inactive',
                          style: AppTheme.caption.copyWith(
                            color: wallet?.isActive == true
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/top-up');
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
                            Navigator.of(context).pushNamed('/transfer');
                          },
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Transfer'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.ms,
                      ),

                  const SizedBox(height: 24),

                  // Wallet Details
                  Text(
                    'Wallet Details',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 16),

                  _buildWalletDetail(
                    'Wallet ID',
                    wallet?.id ?? 'N/A',
                  ).animate().fadeIn(delay: 700.ms),
                  
                  _buildWalletDetail(
                    'User ID',
                    wallet?.userId ?? 'N/A',
                  ).animate().fadeIn(delay: 800.ms),
                  
                  _buildWalletDetail(
                    'Currency',
                    wallet?.currency ?? 'N/A',
                  ).animate().fadeIn(delay: 900.ms),
                  
                  _buildWalletDetail(
                    'Available Balance',
                    '${wallet?.currency ?? 'UGX'} ${_formatCurrency(wallet?.availableBalance ?? 0)}',
                  ).animate().fadeIn(delay: 1000.ms),
                  
                  if (wallet?.pendingBalance != null && wallet!.pendingBalance > 0)
                    _buildWalletDetail(
                      'Pending Balance',
                      '${wallet.currency} ${_formatCurrency(wallet.pendingBalance)}',
                      highlight: true,
                    ).animate().fadeIn(delay: 1100.ms),
                  
                  _buildWalletDetail(
                    'Last Updated',
                    _formatDate(wallet?.lastUpdated),
                  ).animate().fadeIn(delay: 1200.ms),

                  const SizedBox(height: 24),

                  // Payment Methods Section
                  Text(
                    'Payment Methods',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 1300.ms),

                  const SizedBox(height: 16),

                  _buildPaymentMethodCard(
                    'Mobile Money',
                    'MTN & Airtel',
                    Icons.phone_android,
                    AppTheme.primaryColor,
                    () {
                      Navigator.of(context).pushNamed('/top-up');
                    },
                  ).animate().fadeIn(delay: 1400.ms),

                  _buildPaymentMethodCard(
                    'Bank Transfer',
                    'Coming Soon',
                    Icons.account_balance,
                    AppTheme.accentColor,
                    null,
                  ).animate().fadeIn(delay: 1500.ms),

                  const SizedBox(height: 24),

                  // Cash Out Section
                  Text(
                    'Cash Out Options',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 1600.ms),

                  const SizedBox(height: 16),

                  _buildPaymentMethodCard(
                    'Mobile Money',
                    'Withdraw to MTN/Airtel',
                    Icons.phone_iphone,
                    AppTheme.successColor,
                    () {
                      Navigator.of(context).pushNamed('/cash-out');
                    },
                  ).animate().fadeIn(delay: 1700.ms),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/transactions');
        },
        icon: const Icon(Icons.history),
        label: const Text('Transaction History'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildWalletDetail(String label, String value, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight 
            ? AppTheme.warningColor.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppTheme.warningColor
              : AppTheme.borderColor,
        ),
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
          Flexible(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: highlight
                    ? AppTheme.warningColor
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                    ],
                  ),
                ),
                Icon(
                  onTap != null ? Icons.arrow_forward_ios : Icons.lock_outline,
                  size: 16,
                  color: onTap != null
                      ? AppTheme.textSecondary
                      : AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}