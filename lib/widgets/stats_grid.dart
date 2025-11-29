import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/design_system/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return 'UGX ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'UGX ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'UGX ${NumberFormat('#,###').format(amount)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Calculate stats from monthly transactions
        final monthTxs = provider.monthTransactions;
        
        // Calculate income (top-ups)
        final income = monthTxs
            .where((t) => t.type == TransactionType.topup && t.isCompleted)
            .fold<double>(0.0, (sum, t) => sum + t.amount);
        
        // Calculate expenses (all non-topup transactions)
        final expenses = monthTxs
            .where((t) => t.type != TransactionType.topup && t.isCompleted)
            .fold<double>(0.0, (sum, t) => sum + t.amount);
        
        // Calculate net (income - expenses)
        final net = income - expenses;
        
        // Count completed transactions
        final completedCount = monthTxs.where((t) => t.isCompleted).length;
        final totalCount = monthTxs.length;

        final stats = [
          {
            'title': 'Income',
            'amount': income,
            'change': '+${monthTxs.where((t) => t.type == TransactionType.topup).length}',
            'isPositive': true,
            'icon': Icons.trending_up,
            'color': AppTheme.successColor,
          },
          {
            'title': 'Expenses',
            'amount': expenses,
            'change': '-${monthTxs.where((t) => t.type != TransactionType.topup && t.isCompleted).length}',
            'isPositive': false,
            'icon': Icons.trending_down,
            'color': AppTheme.errorColor,
          },
          {
            'title': 'Net',
            'amount': net,
            'change': net >= 0 ? 'Surplus' : 'Deficit',
            'isPositive': net >= 0,
            'icon': Icons.account_balance,
            'color': net >= 0 ? AppTheme.secondaryColor : AppTheme.warningColor,
          },
          {
            'title': 'Completed',
            'amount': completedCount.toDouble(),
            'change': '$totalCount total',
            'isPositive': true,
            'icon': Icons.check_circle,
            'color': AppTheme.accentColor,
          },
        ];

        // Show loading state
        if (provider.isLoading && provider.transactions.isEmpty) {
          return _buildLoadingSkeleton();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            final amount = stat['amount'] as double;
            
            // For completed transactions, show count instead of formatted amount
            final displayAmount = stat['title'] == 'Completed' 
                ? amount.toInt().toString()
                : _formatAmount(amount);

            return Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          stat['title'] as String,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (stat['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          stat['icon'] as IconData,
                          color: stat['color'] as Color,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          displayAmount,
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (stat['title'] != 'Completed') ...[
                            Icon(
                              (stat['isPositive'] as bool) 
                                  ? Icons.arrow_upward 
                                  : Icons.arrow_downward,
                              color: stat['color'] as Color,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              stat['change'] as String,
                              style: AppTheme.caption.copyWith(
                                color: stat['color'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}