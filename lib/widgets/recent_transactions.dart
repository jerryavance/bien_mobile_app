import 'package:flutter/material.dart';
import '../core/design_system/app_theme.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'title': 'Netflix Subscription',
        'subtitle': 'Entertainment',
        'amount': 'UGX 15,000',
        'time': '2 hours ago',
        'icon': Icons.tv,
        'color': AppTheme.errorColor,
        'type': 'expense',
      },
      {
        'title': 'Salary Deposit',
        'subtitle': 'Income',
        'amount': 'UGX 1,400,000',
        'time': 'Yesterday',
        'icon': Icons.account_balance,
        'color': AppTheme.successColor,
        'type': 'income',
      },
      {
        'title': 'Grocery Shopping',
        'subtitle': 'Food & Dining',
        'amount': 'UGX 80,000',
        'time': '2 days ago',
        'icon': Icons.shopping_cart,
        'color': AppTheme.warningColor,
        'type': 'expense',
      },
      {
        'title': 'Investment Return',
        'subtitle': 'Portfolio',
        'amount': 'UGX 500,000',
        'time': '3 days ago',
        'icon': Icons.trending_up,
        'color': AppTheme.secondaryColor,
        'type': 'income',
      },
      {
        'title': 'Uber Ride',
        'subtitle': 'Transportation',
        'amount': 'UGX 110,000',
        'time': '4 days ago',
        'icon': Icons.directions_car,
        'color': AppTheme.infoColor,
        'type': 'expense',
      },
    ];

    return Column(
      children: transactions.map((transaction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  color: (transaction['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction['icon'] as IconData,
                  color: transaction['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'] as String,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['subtitle'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['time'] as String,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction['amount'] as String,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: transaction['type'] == 'income'
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (transaction['type'] == 'income'
                              ? AppTheme.successColor
                              : AppTheme.errorColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transaction['type'] == 'income' ? 'Income' : 'Expense',
                      style: AppTheme.caption.copyWith(
                        color: transaction['type'] == 'income'
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
