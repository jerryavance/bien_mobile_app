import 'package:bien/models/transaction_model.dart';
import 'package:bien/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../widgets/recent_transactions.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/bill_provider.dart';
import '../../models/bill_models.dart';
import '../bills/category_billers_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

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
    
    // Fetch wallet, transactions, and bills on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final walletProvider = context.read<WalletProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final billProvider = context.read<BillProvider>();
    
    // Fetch wallet first
    await walletProvider.fetchWallet();
    
    // Then fetch transactions
    await transactionProvider.fetchTransactions(refresh: true);
    await transactionProvider.fetchSummary();
    
    // Fetch bill categories
    await billProvider.fetchBillers();
    
    print('✅ Initial data loaded');
    print('Wallet balance: ${walletProvider.balance}');
    print('Transactions count: ${transactionProvider.transactions.length}');
    print('Bill categories: ${billProvider.categories.length}');
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
          const WalletScreen(),
          _buildScanTab(),
          _buildBillsTab(),
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
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Bills',
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
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<WalletProvider>().fetchWallet(),
          context.read<TransactionProvider>().fetchTransactions(refresh: true),
          context.read<TransactionProvider>().fetchSummary(),
          context.read<BillProvider>().fetchBillers(),
        ]);
      },
      child: Stack(
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
                          ).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 12),
                          const RecentTransactions()
                              .animate()
                              .fadeIn(delay: 600.ms)
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
      ),
    );
  }

  Widget _buildFirstRowQuickActions() {
    final actions = [
      {
        'icon': Icons.add_card,
        'label': 'Top-up',
        'onTap': () => Navigator.pushNamed(context, '/top-up'),
      },
      {
        'icon': Icons.money_off,
        'label': 'Cash-Out',
        'onTap': () => Navigator.pushNamed(context, '/cash-out'),
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Bills',
        'onTap': () => Navigator.pushNamed(context, '/bills'),
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Transfer',
        'onTap': () => Navigator.pushNamed(context, '/bien-transfer'),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
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
                        _buildActionGrid(),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Bill Payment Services',
                          style: AppTheme.heading4.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBillCategoriesList(context),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    final allActions = [
      {
        'icon': Icons.add_card,
        'label': 'Top-up',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/top-up');
        },
      },
      {
        'icon': Icons.money_off,
        'label': 'Cash-Out',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/cash-out');
        },
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Transfer',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/bien-transfer');
        },
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Bills',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/bills');
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
      {
        'icon': Icons.credit_card,
        'label': 'Cards',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/cards');
        },
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Analytics',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/analytics');
        },
      },
      {
        'icon': Icons.history,
        'label': 'History',
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/transactions');
        },
      },
    ];

    return Column(
      children: [
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

  Widget _buildBillCategoriesList(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        if (billProvider.isLoadingBillers) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (billProvider.categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No bill categories available',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }

        return Column(
          children: billProvider.categories.map((category) {
            return _buildBillCategoryOption(
              context,
              _getCategoryIcon(category.categoryName),
              category.categoryName,
              '${category.billers.length} ${category.billers.length == 1 ? 'biller' : 'billers'}',
              category,
              _getCategoryColor(category.categoryName),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBillCategoryOption(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    BillCategory category,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryBillersScreen(
              category: category,
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electric')) return Icons.electric_bolt;
    if (name.contains('water') || name.contains('nwsc')) return Icons.water_drop;
    if (name.contains('mobile') || name.contains('airtime')) return Icons.phone_android;
    if (name.contains('tax')) return Icons.account_balance;
    if (name.contains('school') || name.contains('fee')) return Icons.school;
    if (name.contains('tv')) return Icons.tv;
    return Icons.receipt_long;
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electric')) return AppTheme.warningColor;
    if (name.contains('water')) return AppTheme.infoColor;
    if (name.contains('mobile') || name.contains('airtime')) return AppTheme.primaryColor;
    if (name.contains('tax')) return AppTheme.errorColor;
    if (name.contains('school')) return AppTheme.successColor;
    if (name.contains('tv')) return AppTheme.secondaryColor;
    return AppTheme.accentColor;
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

  Widget _buildBillsTab() {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBillers && provider.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: 24),
                Text(
                  'No Bill Categories',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bill categories will appear here',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchBillers();
                  },
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchBillers(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              final color = _getCategoryColor(category.categoryName);
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryBillersScreen(
                        category: category,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(category.categoryName),
                          color: color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        category.categoryName,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.billers.length} ${category.billers.length == 1 ? 'biller' : 'billers'}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
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













// import 'package:bien/models/transaction_model.dart';
// import 'package:bien/widgets/balance_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import '../../core/design_system/app_theme.dart';
// import '../../widgets/recent_transactions.dart';
// import '../../providers/transaction_provider.dart';
// import '../../providers/wallet_provider.dart';
// import '../../providers/bill_provider.dart';
// import '../../models/bill_models.dart';
// import '../bills/category_billers_screen.dart';
// import 'profile_screen.dart';
// import 'wallet_screen.dart';

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
    
//     // Fetch wallet, transactions, and bills on init
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadInitialData();
//     });
//   }

//   Future<void> _loadInitialData() async {
//     final walletProvider = context.read<WalletProvider>();
//     final transactionProvider = context.read<TransactionProvider>();
//     final billProvider = context.read<BillProvider>();
    
//     // Fetch wallet first
//     await walletProvider.fetchWallet();
    
//     // Then fetch transactions
//     await transactionProvider.fetchTransactions(refresh: true);
//     await transactionProvider.fetchSummary();
    
//     // Fetch bill categories
//     await billProvider.fetchBillers();
    
//     print('✅ Initial data loaded');
//     print('Wallet balance: ${walletProvider.balance}');
//     print('Transactions count: ${transactionProvider.transactions.length}');
//     print('Bill categories: ${billProvider.categories.length}');
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
//           const WalletScreen(),
//           _buildScanTab(),
//           _buildBillsTab(),
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
//             icon: Icon(Icons.receipt_long_outlined),
//             activeIcon: Icon(Icons.receipt_long),
//             label: 'Bills',
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
//     return RefreshIndicator(
//       onRefresh: () async {
//         await Future.wait([
//           context.read<WalletProvider>().fetchWallet(),
//           context.read<TransactionProvider>().fetchTransactions(refresh: true),
//           context.read<TransactionProvider>().fetchSummary(),
//           context.read<BillProvider>().fetchBillers(),
//         ]);
//       },
//       child: Stack(
//         children: [
//           // Balance Card as Top Section
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: const BalanceCard()
//                 .animate()
//                 .fadeIn(duration: 600.ms),
//           ),
          
//           // Non-scrollable Quick Actions + Scrollable Transactions
//           Positioned.fill(
//             top: MediaQuery.of(context).size.height * 0.35,
//             child: Column(
//               children: [
//                 // Quick Actions Section (Fixed, non-scrollable)
//                 Container(
//                   color: AppTheme.backgroundColor,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Quick Actions',
//                             style: AppTheme.heading4.copyWith(
//                               color: AppTheme.textPrimary,
//                             ),
//                           ),
//                           TextButton.icon(
//                             onPressed: () {
//                               _showExpandedQuickActions(context);
//                             },
//                             icon: const Icon(Icons.expand_more, size: 20),
//                             label: const Text('More'),
//                             style: TextButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(horizontal: 8),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildFirstRowQuickActions(),
//                     ],
//                   ),
//                 ),
                
//                 // Scrollable Recent Transactions
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Recent Transactions
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Recent Transactions',
//                                 style: AppTheme.heading4.copyWith(
//                                   color: AppTheme.textPrimary,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, '/transactions');
//                                 },
//                                 child: Text(
//                                   'View All',
//                                   style: AppTheme.bodyMedium.copyWith(
//                                     color: AppTheme.primaryColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ).animate().fadeIn(delay: 400.ms),
//                           const SizedBox(height: 12),
//                           const RecentTransactions()
//                               .animate()
//                               .fadeIn(delay: 600.ms)
//                               .slideY(begin: 0.3, end: 0, duration: 600.ms),
//                           const SizedBox(height: 100),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
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
//         'label': 'Bills',
//         'onTap': () => Navigator.pushNamed(context, '/bills'),
//       },
//       {
//         'icon': Icons.send,
//         'label': 'Transfer',
//         'onTap': () => Navigator.pushNamed(context, '/bien-transfer'),
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
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.borderColor,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'All Quick Actions',
//                       style: AppTheme.heading4.copyWith(
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildActionGrid(),
//                     const SizedBox(height: 20),
//                     const Divider(),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Bill Payment Services',
//                       style: AppTheme.heading4.copyWith(
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildBillCategoriesList(context),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
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
//         'icon': Icons.send,
//         'label': 'Transfer',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/bien-transfer');
//         },
//       },
//       {
//         'icon': Icons.credit_card,
//         'label': 'Bills',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/bills');
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
//       {
//         'icon': Icons.credit_card,
//         'label': 'Cards',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/cards');
//         },
//       },
//       {
//         'icon': Icons.calculate,
//         'label': 'Loan Calc',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/loan-calculator');
//         },
//       },
//       {
//         'icon': Icons.assessment,
//         'label': 'Tax Calc',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/tax-calculator');
//         },
//       },
//     ];

//     return Column(
//       children: [
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

//   Widget _buildBillCategoriesList(BuildContext context) {
//     return Consumer<BillProvider>(
//       builder: (context, billProvider, child) {
//         if (billProvider.isLoadingBillers) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(20),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }

//         if (billProvider.categories.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               'No bill categories available',
//               style: AppTheme.bodyMedium.copyWith(
//                 color: AppTheme.textSecondary,
//               ),
//             ),
//           );
//         }

//         return Column(
//           children: billProvider.categories.map((category) {
//             return _buildBillCategoryOption(
//               context,
//               _getCategoryIcon(category.categoryName),
//               category.categoryName,
//               '${category.billers.length} ${category.billers.length == 1 ? 'biller' : 'billers'}',
//               category,
//               _getCategoryColor(category.categoryName),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildBillCategoryOption(
//     BuildContext context,
//     IconData icon,
//     String label,
//     String subtitle,
//     BillCategory category,
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
//       subtitle: Text(
//         subtitle,
//         style: AppTheme.bodySmall.copyWith(
//           color: AppTheme.textSecondary,
//         ),
//       ),
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         color: AppTheme.textTertiary,
//         size: 16,
//       ),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CategoryBillersScreen(
//               category: category,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   IconData _getCategoryIcon(String categoryName) {
//     final name = categoryName.toLowerCase();
//     if (name.contains('electric')) return Icons.electric_bolt;
//     if (name.contains('water') || name.contains('nwsc')) return Icons.water_drop;
//     if (name.contains('mobile') || name.contains('airtime')) return Icons.phone_android;
//     if (name.contains('tax')) return Icons.account_balance;
//     if (name.contains('school') || name.contains('fee')) return Icons.school;
//     if (name.contains('tv')) return Icons.tv;
//     return Icons.receipt_long;
//   }

//   Color _getCategoryColor(String categoryName) {
//     final name = categoryName.toLowerCase();
//     if (name.contains('electric')) return AppTheme.warningColor;
//     if (name.contains('water')) return AppTheme.infoColor;
//     if (name.contains('mobile') || name.contains('airtime')) return AppTheme.primaryColor;
//     if (name.contains('tax')) return AppTheme.errorColor;
//     if (name.contains('school')) return AppTheme.successColor;
//     if (name.contains('tv')) return AppTheme.secondaryColor;
//     return AppTheme.accentColor;
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

//   Widget _buildBillsTab() {
//     return Consumer<BillProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoadingBillers && provider.categories.isEmpty) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         if (provider.categories.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.receipt_long_outlined,
//                   size: 80,
//                   color: AppTheme.textTertiary,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'No Bill Categories',
//                   style: AppTheme.heading3.copyWith(
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Bill categories will appear here',
//                   style: AppTheme.bodyMedium.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 ElevatedButton(
//                   onPressed: () {
//                     provider.fetchBillers();
//                   },
//                   child: const Text('Refresh'),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: () => provider.fetchBillers(),
//           child: GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 1.0,
//             ),
//             itemCount: provider.categories.length,
//             itemBuilder: (context, index) {
//               final category = provider.categories[index];
//               final color = _getCategoryColor(category.categoryName);
              
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CategoryBillersScreen(
//                         category: category,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppTheme.surfaceColor,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: AppTheme.borderColor),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 64,
//                         height: 64,
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Icon(
//                           _getCategoryIcon(category.categoryName),
//                           color: color,
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         category.categoryName,
//                         style: AppTheme.bodyMedium.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${category.billers.length} ${category.billers.length == 1 ? 'biller' : 'billers'}',
//                         style: AppTheme.bodySmall.copyWith(
//                           color: AppTheme.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfileTab() {
//     return const ProfileScreen();
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
















// import 'package:bien/models/transaction_model.dart';
// import 'package:bien/widgets/balance_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import '../../core/design_system/app_theme.dart';
// import '../../widgets/recent_transactions.dart';
// import '../../providers/transaction_provider.dart';
// import '../../providers/wallet_provider.dart';
// import 'profile_screen.dart';
// import 'wallet_screen.dart';

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
    
//     // Fetch wallet and transactions on init
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadInitialData();
//     });
//   }

//   Future<void> _loadInitialData() async {
//     final walletProvider = context.read<WalletProvider>();
//     final transactionProvider = context.read<TransactionProvider>();
    
//     // Fetch wallet first
//     await walletProvider.fetchWallet();
    
//     // Then fetch transactions
//     await transactionProvider.fetchTransactions(refresh: true);
//     await transactionProvider.fetchSummary();
    
//     print('✅ Initial data loaded');
//     print('Wallet balance: ${walletProvider.balance}');
//     print('Transactions count: ${transactionProvider.transactions.length}');
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
//           const WalletScreen(), // Use the updated WalletScreen
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
//     return RefreshIndicator(
//       onRefresh: () async {
//         await Future.wait([
//           context.read<WalletProvider>().fetchWallet(),
//           context.read<TransactionProvider>().fetchTransactions(refresh: true),
//           context.read<TransactionProvider>().fetchSummary(),
//         ]);
//       },
//       child: Stack(
//         children: [
//           // Balance Card as Top Section
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: const BalanceCard()
//                 .animate()
//                 .fadeIn(duration: 600.ms),
//           ),
          
//           // Non-scrollable Quick Actions + Scrollable Transactions
//           Positioned.fill(
//             top: MediaQuery.of(context).size.height * 0.35,
//             child: Column(
//               children: [
//                 // Quick Actions Section (Fixed, non-scrollable)
//                 Container(
//                   color: AppTheme.backgroundColor,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Quick Actions',
//                             style: AppTheme.heading4.copyWith(
//                               color: AppTheme.textPrimary,
//                             ),
//                           ),
//                           TextButton.icon(
//                             onPressed: () {
//                               _showExpandedQuickActions(context);
//                             },
//                             icon: const Icon(Icons.expand_more, size: 20),
//                             label: const Text('More'),
//                             style: TextButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(horizontal: 8),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildFirstRowQuickActions(),
//                     ],
//                   ),
//                 ),
                
//                 // Scrollable Recent Transactions
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Recent Transactions
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Recent Transactions',
//                                 style: AppTheme.heading4.copyWith(
//                                   color: AppTheme.textPrimary,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, '/transactions');
//                                 },
//                                 child: Text(
//                                   'View All',
//                                   style: AppTheme.bodyMedium.copyWith(
//                                     color: AppTheme.primaryColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ).animate().fadeIn(delay: 400.ms),
//                           const SizedBox(height: 12),
//                           const RecentTransactions()
//                               .animate()
//                               .fadeIn(delay: 600.ms)
//                               .slideY(begin: 0.3, end: 0, duration: 600.ms),
//                           const SizedBox(height: 100),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
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
//         'label': 'Bills',
//         'onTap': () => Navigator.pushNamed(context, '/bills'),
//       },
//       {
//         'icon': Icons.send,
//         'label': 'Transfer',
//         'onTap': () => Navigator.pushNamed(context, '/bien-transfer'),
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
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.borderColor,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'All Quick Actions',
//                       style: AppTheme.heading4.copyWith(
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildActionGrid(),
//                     const SizedBox(height: 20),
//                     const Divider(),
//                     const SizedBox(height: 12),
//                     Text(
//                       'More Services',
//                       style: AppTheme.heading4.copyWith(
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildMoreOption(
//                       context,
//                       Icons.phone_android,
//                       'Airtime',
//                       'Buy airtime for any network',
//                       '/airtime',
//                       AppTheme.primaryColor,
//                     ),
//                     _buildMoreOption(
//                       context,
//                       Icons.wifi,
//                       'Data Bundles',
//                       'Purchase internet data bundles',
//                       '/data-bundles',
//                       AppTheme.secondaryColor,
//                     ),
//                     _buildMoreOption(
//                       context,
//                       Icons.store,
//                       'Merchant Pay',
//                       'Pay at stores and merchants',
//                       '/merchant-pay',
//                       AppTheme.accentColor,
//                     ),
//                     _buildMoreOption(
//                       context,
//                       Icons.school,
//                       'School Fees',
//                       'Pay school fees instantly',
//                       '/school-fees',
//                       AppTheme.infoColor,
//                     ),
//                     _buildMoreOption(
//                       context,
//                       Icons.water_drop,
//                       'Utility Payment',
//                       'Pay water, electricity & more',
//                       '/utility-payment',
//                       AppTheme.warningColor,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
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
//         'icon': Icons.send,
//         'label': 'Bien',
//         'onTap': () {
//           Navigator.pop(context);
//           Navigator.pushNamed(context, '/bien-transfer');
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
//     String subtitle,
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
//       subtitle: Text(
//         subtitle,
//         style: AppTheme.bodySmall.copyWith(
//           color: AppTheme.textSecondary,
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
//       child: Consumer<TransactionProvider>(
//         builder: (context, provider, child) {
//           final summary = provider.summary;
          
//           return Column(
//             children: [
//               // Summary Cards
//               Container(
//                 height: 140,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _buildSummaryCard(
//                       'Total Income',
//                       'UGX ${(summary?['total_income'] ?? 0).toStringAsFixed(0)}',
//                       '+${provider.monthTransactions.where((t) => t.type == TransactionType.topup).length}',
//                       AppTheme.successColor,
//                       Icons.trending_up,
//                     ),
//                     _buildSummaryCard(
//                       'Total Expense',
//                       'UGX ${(summary?['total_expense'] ?? 0).toStringAsFixed(0)}',
//                       '-${provider.monthTransactions.where((t) => t.type != TransactionType.topup).length}',
//                       AppTheme.errorColor,
//                       Icons.trending_down,
//                     ),
//                     _buildSummaryCard(
//                       'Net Amount',
//                       'UGX ${(summary?['net_amount'] ?? 0).toStringAsFixed(0)}',
//                       '${summary?['total_transactions'] ?? 0} txns',
//                       AppTheme.secondaryColor,
//                       Icons.account_balance,
//                     ),
//                     _buildSummaryCard(
//                       'Completed',
//                       '${summary?['completed'] ?? 0}',
//                       'Pending: ${summary?['pending'] ?? 0}',
//                       AppTheme.accentColor,
//                       Icons.check_circle,
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Transaction Overview',
//                         style: AppTheme.heading4.copyWith(
//                           color: AppTheme.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildStatsCard(
//                         'Today',
//                         provider.todayTransactions.length,
//                         AppTheme.primaryColor,
//                       ),
//                       _buildStatsCard(
//                         'This Week',
//                         provider.weekTransactions.length,
//                         AppTheme.secondaryColor,
//                       ),
//                       _buildStatsCard(
//                         'This Month',
//                         provider.monthTransactions.length,
//                         AppTheme.accentColor,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProfileTab() {
//     return const ProfileScreen();
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
//             style: AppTheme.heading4.copyWith(
//               color: AppTheme.textPrimary,
//               fontWeight: FontWeight.bold,
//             ),
//             overflow: TextOverflow.ellipsis,
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

//   Widget _buildStatsCard(String title, int count, Color color) {
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
//             child: Text(
//               title,
//               style: AppTheme.bodyMedium.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textPrimary,
//               ),
//             ),
//           ),
//           Text(
//             '$count transactions',
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