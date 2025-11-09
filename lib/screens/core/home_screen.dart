import 'package:bien/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';
import '../../widgets/recent_transactions.dart';
import '../../widgets/stats_grid.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          _buildWalletTab(),
          _buildScanTab(),
          _buildAnalyticsTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickActionModal(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        backgroundColor: AppTheme.surfaceColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_outlined),
            activeIcon: Icon(Icons.qr_code_2),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Balance Card as Top Section
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: const BalanceCard()
              .animate()
              .fadeIn(duration: 600.ms),
        ),
        
        // Non-scrollable Quick Actions + Scrollable Transactions
        Positioned.fill(
          top: MediaQuery.of(context).size.height * 0.35,
          child: Column(
            children: [
              // Quick Actions Section (Fixed, non-scrollable)
              Container(
                color: AppTheme.backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quick Actions',
                          style: AppTheme.heading4.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _showExpandedQuickActions(context);
                          },
                          icon: const Icon(Icons.expand_more, size: 20),
                          label: const Text('More'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFirstRowQuickActions(),
                  ],
                ),
              ),
              
              // Scrollable Recent Transactions
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: AppTheme.heading4.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/transactions');
                              },
                              child: Text(
                                'View All',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 12),
                        const RecentTransactions()
                            .animate()
                            .fadeIn(delay: 800.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFirstRowQuickActions() {
    final actions = [
      {
        'icon': Icons.phone_android,
        'label': 'Top-up',
        'onTap': () => Navigator.pushNamed(context, '/top-up'),
      },
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Cash-Out',
        'onTap': () => Navigator.pushNamed(context, '/cash-out'),
      },
      {
        'icon': Icons.credit_card,
        'label': 'Cards',
        'onTap': () => Navigator.pushNamed(context, '/cards'),
      },
      {
        'icon': Icons.savings,
        'label': 'Savings',
        'onTap': () => Navigator.pushNamed(context, '/savings'),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return _buildCircularActionButton(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          onTap: action['onTap'] as VoidCallback,
        );
      }).toList(),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms);
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showExpandedQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Quick Actions',
                      style: AppTheme.heading4.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // All actions in a grid
                    _buildActionGrid(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'More Services',
                      style: AppTheme.heading4.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMoreOption(
                      context,
                      Icons.phone_android,
                      'Airtime',
                      'Buy airtime for any network',
                      '/airtime',
                      AppTheme.primaryColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.wifi,
                      'Data Bundles',
                      'Purchase internet data bundles',
                      '/data-bundles',
                      AppTheme.secondaryColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.store,
                      'Merchant Pay',
                      'Pay at stores and merchants',
                      '/merchant-pay',
                      AppTheme.accentColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.school,
                      'School Fees',
                      'Pay school fees instantly',
                      '/school-fees',
                      AppTheme.infoColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.water_drop,
                      'Utility Payment',
                      'Pay water, electricity & more',
                      '/utility-payment',
                      AppTheme.warningColor,
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Settings & Tools',
                      style: AppTheme.heading4.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMoreOption(
                      context,
                      Icons.security,
                      'Security Settings',
                      'Manage your security',
                      '/security-settings',
                      AppTheme.primaryColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.currency_exchange,
                      'Currency Converter',
                      'Convert currencies',
                      '/currency-converter',
                      AppTheme.secondaryColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.receipt_long,
                      'Bill Payments',
                      'Pay your bills',
                      '/bill-payments',
                      AppTheme.accentColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.calculate,
                      'Loan Calculator',
                      'Calculate loan payments',
                      '/loan-calculator',
                      AppTheme.infoColor,
                    ),
                    _buildMoreOption(
                      context,
                      Icons.assessment,
                      'Tax Calculator',
                      'Calculate your taxes',
                      '/tax-calculator',
                      AppTheme.warningColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    final allActions = [
      {
        'icon': Icons.phone_android,
        'label': 'Top-up',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/top-up');
        },
      },
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Cash-Out',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/cash-out');
        },
      },
      {
        'icon': Icons.credit_card,
        'label': 'Cards',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/cards');
        },
      },
      {
        'icon': Icons.savings,
        'label': 'Savings',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/savings');
        },
      },
      {
        'icon': Icons.send,
        'label': 'Send',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/send-money');
        },
      },
      {
        'icon': Icons.download,
        'label': 'Receive',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/transactions');
        },
      },
      {
        'icon': Icons.trending_up,
        'label': 'Invest',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/investments');
        },
      },
      {
        'icon': Icons.qr_code_scanner,
        'label': 'Scan',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/scan-to-pay');
        },
      },
    ];

    return Column(
      children: [
        // First Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: allActions.sublist(0, 4).map((action) {
            return _buildCircularActionButton(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: action['onTap'] as VoidCallback,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Second Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: allActions.sublist(4, 8).map((action) {
            return _buildCircularActionButton(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: action['onTap'] as VoidCallback,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoreOption(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    String route,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
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
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

 

  Widget _buildWalletTab() {
    return SafeArea(
      child: SingleChildScrollView(
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
                    'UGX 2,444,562',
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
                              'UGX 18,420.50',
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
                              'UGX 6,142.30',
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
            ),
            
            const SizedBox(height: 24),
            
            // This Month Section (moved from home)
            Text(
              'This Month',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const StatsGrid(),
            
            const SizedBox(height: 24),
            
            // Payment Methods
            Text(
              'Payment Methods',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cards List
            _buildCardItem(
              'Visa ending in 4589',
              'Primary Card',
              'Expires 12/28',
              Icons.credit_card,
              AppTheme.primaryColor,
              true,
            ),
            
            _buildCardItem(
              'Mastercard ending in 1234',
              'Secondary Card',
              'Expires 08/26',
              Icons.credit_card,
              AppTheme.accentColor,
              false,
            ),
            
            _buildCardItem(
              'Bien Pay',
              'Digital Wallet',
              'Connected',
              Icons.phone_iphone,
              AppTheme.infoColor,
              false,
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/top-up');
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
                      Navigator.pushNamed(context, '/send-money');
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Transfer'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Details
            Text(
              'Account Details',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildAccountDetail('Account Number', '**** **** **** 1234'),
            _buildAccountDetail('Routing Number', '021000021'),
            _buildAccountDetail('Account Type', 'Personal Checking'),
            _buildAccountDetail('Member Since', 'November 2025'),
          ],
        ),
      ),
    );
  }

  Widget _buildScanTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Scan QR Code',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Open camera to scan QR codes',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/scan-to-pay').then((_) {
                // Return to home tab after scanning
                setState(() {
                  _selectedIndex = 0;
                  _pageController.jumpToPage(0);
                });
              });
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Open Scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SafeArea(
      child: Column(
        children: [
          // Summary Cards
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSummaryCard(
                  'Total Spending',
                  'UGX 3,240',
                  '+8.2%',
                  AppTheme.errorColor,
                  Icons.trending_up,
                ),
                _buildSummaryCard(
                  'Total Income',
                  'UGX 8,420',
                  '+12.5%',
                  AppTheme.successColor,
                  Icons.trending_up,
                ),
                _buildSummaryCard(
                  'Savings Rate',
                  '38.5%',
                  '+5.3%',
                  AppTheme.secondaryColor,
                  Icons.savings,
                ),
                _buildSummaryCard(
                  'Investment',
                  'UGX 1,890',
                  '+7.8%',
                  AppTheme.accentColor,
                  Icons.analytics,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Spending Categories
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending by Category',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildCategoryItem('Food & Dining', 487.50, 15.0, AppTheme.warningColor),
                  _buildCategoryItem('Transportation', 324.80, 10.0, AppTheme.infoColor),
                  _buildCategoryItem('Entertainment', 298.45, 9.2, AppTheme.accentColor),
                  _buildCategoryItem('Shopping', 256.90, 7.9, AppTheme.primaryColor),
                  _buildCategoryItem('Utilities', 198.75, 6.1, AppTheme.secondaryColor),
                  _buildCategoryItem('Healthcare', 156.30, 4.8, AppTheme.successColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
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

  Widget _buildSummaryCard(String title, String amount, String change, Color color, IconData icon) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                change,
                style: AppTheme.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, double amount, double percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'UGX ${amount.toStringAsFixed(2)}',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuickActionItem(
                    'Transactions',
                    'View all transactions',
                    Icons.receipt_long,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/transactions');
                    },
                  ),
                  _buildQuickActionItem(
                    'Settings',
                    'App preferences and settings',
                    Icons.settings,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
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
    );
  }
}


















// import 'package:bien/widgets/balance_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../../core/design_system/app_theme.dart';
// import '../../widgets/recent_transactions.dart';
// import '../../widgets/stats_grid.dart';
// import 'profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onTabTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         children: [
//           _buildHomeTab(),
//           _buildWalletTab(),
//           _buildScanTab(),
//           _buildAnalyticsTab(),
//           _buildProfileTab(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showQuickActionModal(context);
//         },
//         backgroundColor: AppTheme.primaryColor,
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 28,
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: _onTabTapped,
//         selectedItemColor: AppTheme.primaryColor,
//         unselectedItemColor: AppTheme.textTertiary,
//         backgroundColor: AppTheme.surfaceColor,
//         elevation: 8,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_balance_wallet_outlined),
//             activeIcon: Icon(Icons.account_balance_wallet),
//             label: 'Wallet',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.qr_code_2_outlined),
//             activeIcon: Icon(Icons.qr_code_2),
//             label: 'Scan',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics_outlined),
//             activeIcon: Icon(Icons.analytics),
//             label: 'Analytics',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHomeTab() {
//     return Stack(
//       children: [
//         // Balance Card as Top Section
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: const BalanceCard()
//               .animate()
//               .fadeIn(duration: 600.ms),
//         ),
        
//         // Non-scrollable Quick Actions + Scrollable Transactions
//         Positioned.fill(
//           top: MediaQuery.of(context).size.height * 0.35,
//           child: Column(
//             children: [
//               // Quick Actions Section (Fixed, non-scrollable)
//               Container(
//                 color: AppTheme.backgroundColor,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Quick Actions',
//                           style: AppTheme.heading4.copyWith(
//                             color: AppTheme.textPrimary,
//                           ),
//                         ),
//                         TextButton.icon(
//                           onPressed: () {
//                             _showExpandedQuickActions(context);
//                           },
//                           icon: const Icon(Icons.expand_more, size: 20),
//                           label: const Text('More'),
//                           style: TextButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     _buildFirstRowQuickActions(),
//                   ],
//                 ),
//               ),
              
//               // Scrollable Recent Transactions
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Recent Transactions
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Recent Transactions',
//                               style: AppTheme.heading4.copyWith(
//                                 color: AppTheme.textPrimary,
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pushNamed(context, '/transactions');
//                               },
//                               child: Text(
//                                 'View All',
//                                 style: AppTheme.bodyMedium.copyWith(
//                                   color: AppTheme.primaryColor,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ).animate().fadeIn(delay: 600.ms),
//                         const SizedBox(height: 12),
//                         const RecentTransactions()
//                             .animate()
//                             .fadeIn(delay: 800.ms)
//                             .slideY(begin: 0.3, end: 0, duration: 600.ms),
//                         const SizedBox(height: 100),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFirstRowQuickActions() {
//     final actions = [
//       {
//         'icon': Icons.phone_android,
//         'label': 'Top-up',
//         'onTap': () => Navigator.pushNamed(context, '/top-up'),
//       },
//       {
//         'icon': Icons.account_balance_wallet,
//         'label': 'Cash-Out',
//         'onTap': () => Navigator.pushNamed(context, '/cash-out'),
//       },
//       {
//         'icon': Icons.credit_card,
//         'label': 'Cards',
//         'onTap': () => Navigator.pushNamed(context, '/cards'),
//       },
//       {
//         'icon': Icons.savings,
//         'label': 'Savings',
//         'onTap': () => Navigator.pushNamed(context, '/savings'),
//       },
//     ];

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: actions.map((action) {
//         return _buildCircularActionButton(
//           icon: action['icon'] as IconData,
//           label: action['label'] as String,
//           onTap: action['onTap'] as VoidCallback,
//         );
//       }).toList(),
//     ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms);
//   }

//   Widget _buildCircularActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: AppTheme.primaryColor,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: AppTheme.primaryColor.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: AppTheme.bodySmall.copyWith(
//               fontWeight: FontWeight.w500,
//               color: AppTheme.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showExpandedQuickActions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: AppTheme.surfaceColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: AppTheme.borderColor,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'All Quick Actions',
//                     style: AppTheme.heading4.copyWith(
//                       color: AppTheme.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // All actions in a grid
//                   _buildActionGrid(),
//                   const SizedBox(height: 20),
//                   const Divider(),
//                   const SizedBox(height: 12),
//                   Text(
//                     'More Options',
//                     style: AppTheme.heading4.copyWith(
//                       color: AppTheme.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildMoreOption(
//                     context,
//                     Icons.security,
//                     'Security Settings',
//                     '/security-settings',
//                     AppTheme.primaryColor,
//                   ),
//                   _buildMoreOption(
//                     context,
//                     Icons.currency_exchange,
//                     'Currency Converter',
//                     '/currency-converter',
//                     AppTheme.secondaryColor,
//                   ),
//                   _buildMoreOption(
//                     context,
//                     Icons.receipt_long,
//                     'Bill Payments',
//                     '/bill-payments',
//                     AppTheme.accentColor,
//                   ),
//                   _buildMoreOption(
//                     context,
//                     Icons.calculate,
//                     'Loan Calculator',
//                     '/loan-calculator',
//                     AppTheme.infoColor,
//                   ),
//                   _buildMoreOption(
//                     context,
//                     Icons.assessment,
//                     'Tax Calculator',
//                     '/tax-calculator',
//                     AppTheme.warningColor,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionGrid() {
//     final allActions = [
//       {
//         'icon': Icons.phone_android,
//         'label': 'Top-up',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/top-up');
//         },
//       },
//       {
//         'icon': Icons.account_balance_wallet,
//         'label': 'Cash-Out',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/cash-out');
//         },
//       },
//       {
//         'icon': Icons.credit_card,
//         'label': 'Cards',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/cards');
//         },
//       },
//       {
//         'icon': Icons.savings,
//         'label': 'Savings',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/savings');
//         },
//       },
//       {
//         'icon': Icons.send,
//         'label': 'Send',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/send-money');
//         },
//       },
//       {
//         'icon': Icons.download,
//         'label': 'Receive',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/transactions');
//         },
//       },
//       {
//         'icon': Icons.trending_up,
//         'label': 'Invest',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/investments');
//         },
//       },
//       {
//         'icon': Icons.qr_code_scanner,
//         'label': 'Scan',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/scan-to-pay');
//         },
//       },
//     ];

//     return Column(
//       children: [
//         // First Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: allActions.sublist(0, 4).map((action) {
//             return _buildCircularActionButton(
//               icon: action['icon'] as IconData,
//               label: action['label'] as String,
//               onTap: action['onTap'] as VoidCallback,
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 24),
//         // Second Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: allActions.sublist(4, 8).map((action) {
//             return _buildCircularActionButton(
//               icon: action['icon'] as IconData,
//               label: action['label'] as String,
//               onTap: action['onTap'] as VoidCallback,
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildMoreOption(
//     BuildContext context,
//     IconData icon,
//     String label,
//     String route,
//     Color color,
//   ) {
//     return ListTile(
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: color, size: 20),
//       ),
//       title: Text(
//         label,
//         style: AppTheme.bodyMedium.copyWith(
//           color: AppTheme.textPrimary,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         color: AppTheme.textTertiary,
//         size: 16,
//       ),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.pushNamed(context, route);
//       },
//     );
//   }

//   Widget _buildWalletTab() {
//     return SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Total Balance Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.secondaryGradient,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.secondaryColor.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total Available',
//                     style: AppTheme.bodyMedium.copyWith(
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'UGX 2,444,562',
//                     style: AppTheme.heading1.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Checking',
//                               style: AppTheme.caption.copyWith(
//                                 color: Colors.white.withOpacity(0.6),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'UGX 18,420.50',
//                               style: AppTheme.bodyLarge.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Savings',
//                               style: AppTheme.caption.copyWith(
//                                 color: Colors.white.withOpacity(0.6),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'UGX 6,142.30',
//                               style: AppTheme.bodyLarge.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // This Month Section (moved from home)
//             Text(
//               'This Month',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const StatsGrid(),
            
//             const SizedBox(height: 24),
            
//             // Payment Methods
//             Text(
//               'Payment Methods',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Cards List
//             _buildCardItem(
//               'Visa ending in 4589',
//               'Primary Card',
//               'Expires 12/28',
//               Icons.credit_card,
//               AppTheme.primaryColor,
//               true,
//             ),
            
//             _buildCardItem(
//               'Mastercard ending in 1234',
//               'Secondary Card',
//               'Expires 08/26',
//               Icons.credit_card,
//               AppTheme.accentColor,
//               false,
//             ),
            
//             _buildCardItem(
//               'Bien Pay',
//               'Digital Wallet',
//               'Connected',
//               Icons.phone_iphone,
//               AppTheme.infoColor,
//               false,
//             ),
            
//             const SizedBox(height: 24),
            
//             // Quick Actions
//             Text(
//               'Quick Actions',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/top-up');
//                     },
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Money'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.successColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/send-money');
//                     },
//                     icon: const Icon(Icons.swap_horiz),
//                     label: const Text('Transfer'),
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 24),
            
//             // Account Details
//             Text(
//               'Account Details',
//               style: AppTheme.heading4.copyWith(
//                 color: AppTheme.textPrimary,
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             _buildAccountDetail('Account Number', '**** **** **** 1234'),
//             _buildAccountDetail('Routing Number', '021000021'),
//             _buildAccountDetail('Account Type', 'Personal Checking'),
//             _buildAccountDetail('Member Since', 'November 2025'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildScanTab() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.qr_code_scanner,
//             size: 80,
//             color: AppTheme.primaryColor,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Scan QR Code',
//             style: AppTheme.heading3.copyWith(
//               color: AppTheme.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Open camera to scan QR codes',
//             style: AppTheme.bodyMedium.copyWith(
//               color: AppTheme.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pushNamed(context, '/scan-to-pay').then((_) {
//                 // Return to home tab after scanning
//                 setState(() {
//                   _selectedIndex = 0;
//                   _pageController.jumpToPage(0);
//                 });
//               });
//             },
//             icon: const Icon(Icons.camera_alt),
//             label: const Text('Open Scanner'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primaryColor,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalyticsTab() {
//     return SafeArea(
//       child: Column(
//         children: [
//           // Summary Cards
//           Container(
//             height: 140,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _buildSummaryCard(
//                   'Total Spending',
//                   'UGX 3,240',
//                   '+8.2%',
//                   AppTheme.errorColor,
//                   Icons.trending_up,
//                 ),
//                 _buildSummaryCard(
//                   'Total Income',
//                   'UGX 8,420',
//                   '+12.5%',
//                   AppTheme.successColor,
//                   Icons.trending_up,
//                 ),
//                 _buildSummaryCard(
//                   'Savings Rate',
//                   '38.5%',
//                   '+5.3%',
//                   AppTheme.secondaryColor,
//                   Icons.savings,
//                 ),
//                 _buildSummaryCard(
//                   'Investment',
//                   'UGX 1,890',
//                   '+7.8%',
//                   AppTheme.accentColor,
//                   Icons.analytics,
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 24),
          
//           // Spending Categories
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Spending by Category',
//                     style: AppTheme.heading4.copyWith(
//                       color: AppTheme.textPrimary,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   _buildCategoryItem('Food & Dining', 487.50, 15.0, AppTheme.warningColor),
//                   _buildCategoryItem('Transportation', 324.80, 10.0, AppTheme.infoColor),
//                   _buildCategoryItem('Entertainment', 298.45, 9.2, AppTheme.accentColor),
//                   _buildCategoryItem('Shopping', 256.90, 7.9, AppTheme.primaryColor),
//                   _buildCategoryItem('Utilities', 198.75, 6.1, AppTheme.secondaryColor),
//                   _buildCategoryItem('Healthcare', 156.30, 4.8, AppTheme.successColor),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileTab() {
//     return const ProfileScreen();
//   }

//   Widget _buildCardItem(String title, String subtitle, String detail, IconData icon, Color color, bool isPrimary) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.surfaceColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isPrimary ? color : AppTheme.borderColor,
//           width: isPrimary ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTheme.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: AppTheme.bodySmall.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   detail,
//                   style: AppTheme.caption.copyWith(
//                     color: AppTheme.textTertiary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isPrimary)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Primary',
//                 style: AppTheme.caption.copyWith(
//                   color: color,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAccountDetail(String label, String value) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.surfaceColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.borderColor),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: AppTheme.bodyMedium.copyWith(
//               color: AppTheme.textSecondary,
//             ),
//           ),
//           Text(
//             value,
//             style: AppTheme.bodyMedium.copyWith(
//               color: AppTheme.textPrimary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, String amount, String change, Color color, IconData icon) {
//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.surfaceColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 20,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 change,
//                 style: AppTheme.caption.copyWith(
//                   color: color,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             amount,
//             style: AppTheme.heading3.copyWith(
//               color: AppTheme.textPrimary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: AppTheme.bodySmall.copyWith(
//               color: AppTheme.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryItem(String name, double amount, double percentage, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.surfaceColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.borderColor),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: AppTheme.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 Text(
//                   '${percentage.toStringAsFixed(1)}% of total',
//                   style: AppTheme.bodySmall.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             'UGX ${amount.toStringAsFixed(2)}',
//             style: AppTheme.bodyLarge.copyWith(
//               fontWeight: FontWeight.w600,
//               color: AppTheme.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showQuickActionModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: AppTheme.surfaceColor,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppTheme.textTertiary,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Quick Actions',
//                     style: AppTheme.heading4.copyWith(
//                       color: AppTheme.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   _buildQuickActionItem(
//                     'Transactions',
//                     'View all transactions',
//                     Icons.receipt_long,
//                     () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/transactions');
//                     },
//                   ),
//                   _buildQuickActionItem(
//                     'Settings',
//                     'App preferences and settings',
//                     Icons.settings,
//                     () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/settings');
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionItem(
//       String title, String subtitle, IconData icon, VoidCallback onTap) {
//     return ListTile(
//       onTap: onTap,
//       leading: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: AppTheme.primaryColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: AppTheme.primaryColor,
//           size: 24,
//         ),
//       ),
//       title: Text(
//         title,
//         style: AppTheme.bodyMedium.copyWith(
//           fontWeight: FontWeight.w600,
//           color: AppTheme.textPrimary,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: AppTheme.bodySmall.copyWith(
//           color: AppTheme.textSecondary,
//         ),
//       ),
//       trailing: Icon(
//         Icons.chevron_right,
//         color: AppTheme.textTertiary,
//       ),
//     );
//   }
// }