import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/design_system/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceHidden = false;

  @override
  void initState() {
    super.initState();
    // Fetch wallet balance on init
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
    return Consumer2<AuthProvider, WalletProvider>(
      builder: (context, authProvider, walletProvider, child) {
        final user = authProvider.user;
        final wallet = walletProvider.wallet;
        final balance = wallet?.balance ?? 0.0;
        final isLoading = walletProvider.isLoading;

        return Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar with Profile and Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: user?.profileImage != null
                                ? NetworkImage(user!.profileImage!)
                                : null,
                            child: user?.profileImage == null
                                ? Text(
                                    user?.initials ?? 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                user?.fullName ?? 'User',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search,
                                color: Colors.white, size: 26),
                            onPressed: () {
                              // Search functionality
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 26),
                            onPressed: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Balance Section
                  Text(
                    'Total Balance',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'UGX ',
                        style: AppTheme.heading4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Text(
                          _isBalanceHidden
                              ? '••••••••'
                              : _formatCurrency(balance),
                          style: AppTheme.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBalanceHidden = !_isBalanceHidden;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isBalanceHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isBalanceHidden ? 'Show' : 'Hide',
                                style: AppTheme.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Show error if any
                  if (walletProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        walletProvider.errorMessage!,
                        style: AppTheme.caption.copyWith(
                          color: Colors.red.shade200,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Top-up Button (Centered and smaller)
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushNamed('/top-up');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2AC4F3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text(
                          'Top-up Wallet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}