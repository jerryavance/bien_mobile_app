// ==========================================
// FILE: lib/screens/bills/category_billers_screen.dart
// List of billers in a category
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';
import '../../models/bill_models.dart';
import 'bill_payment_screen.dart';

class CategoryBillersScreen extends StatelessWidget {
  final BillCategory category;

  const CategoryBillersScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(category.categoryName),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.categoryName),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.categoryName,
                        style: AppTheme.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.billers.length} available ${category.billers.length == 1 ? 'biller' : 'billers'}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
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
            'Select Biller',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Billers List
          ...category.billers.asMap().entries.map((entry) {
            final index = entry.key;
            final biller = entry.value;
            return _buildBillerCard(context, biller, index);
          }).toList(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBillerCard(BuildContext context, Biller biller, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getBillerIcon(biller.billName),
            color: AppTheme.primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          biller.billName,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              biller.billDescription,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${biller.fields.length} required fields',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textSecondary,
          size: 20,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BillPaymentScreen(
                category: category,
                biller: biller,
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 400 + index * 100),
    ).slideX(
      begin: 0.3,
      end: 0,
      duration: 300.ms,
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

  IconData _getBillerIcon(String billerName) {
    final name = billerName.toLowerCase();
    if (name.contains('mtn')) return Icons.signal_cellular_alt;
    if (name.contains('airtel')) return Icons.signal_cellular_alt;
    if (name.contains('umeme') || name.contains('uedcl')) return Icons.electric_bolt;
    if (name.contains('nwsc')) return Icons.water_drop;
    if (name.contains('ura')) return Icons.account_balance;
    if (name.contains('school') || name.contains('pay')) return Icons.school;
    if (name.contains('dstv') || name.contains('star')) return Icons.tv;
    return Icons.receipt;
  }
}