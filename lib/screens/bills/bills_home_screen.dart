// ==========================================
// FILE: lib/screens/bills/bills_home_screen.dart
// Bill categories list screen
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/bill_provider.dart';
import '../../models/bill_models.dart';
import 'category_billers_screen.dart';

class BillsHomeScreen extends StatefulWidget {
  const BillsHomeScreen({super.key});

  @override
  State<BillsHomeScreen> createState() => _BillsHomeScreenState();
}

class _BillsHomeScreenState extends State<BillsHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().fetchBillers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pay Bills'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BillProvider>().fetchBillers();
            },
          ),
        ],
      ),
      body: Consumer<BillProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBillers) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && provider.categories.isEmpty) {
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
                    provider.errorMessage!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BillProvider>().fetchBillers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bill categories available',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<BillProvider>().fetchBillers(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill Payments',
                                  style: AppTheme.heading3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pay utilities, airtime, and more',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Select a category to view available billers',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                Text(
                  'Bill Categories',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Categories Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(
                      provider.categories[index],
                      index,
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BillCategory category, int index) {
    // Assign colors to categories
    final colors = [
      AppTheme.warningColor,
      AppTheme.infoColor,
      AppTheme.primaryColor,
      AppTheme.errorColor,
      AppTheme.successColor,
      AppTheme.secondaryColor,
    ];

    final color = colors[index % colors.length];

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
      ).animate().fadeIn(
        delay: Duration(milliseconds: 400 + index * 100),
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 300.ms,
      ),
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
}