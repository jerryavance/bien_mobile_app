// ==========================================
// FILE: lib/widgets/recent_transactions.dart
// EXACT same design as before, but with REAL data
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Show loading skeleton if loading and no data yet
        if (provider.isLoading && provider.transactions.isEmpty) {
          return _buildSkeleton();
        }

        // Show empty state
        if (provider.transactions.isEmpty) {
          return _buildEmptyState();
        }

        // Take only the latest 5
        final recent = provider.transactions.take(5).toList();

        return Column(
          children: recent.map((tx) => _buildTransactionCard(tx)).toList(),
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.topup;
    final color = isIncome ? AppTheme.successColor : AppTheme.errorColor;
    final icon = _getIcon(transaction.type);

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
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // Middle: Title, Subtitle, Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeLabel,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description ?? transaction.recipientName ?? 'Transaction',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(transaction.createdAt),
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Right: Amount + Income/Expense tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}UGX ${NumberFormat('#,###', 'en_US').format(transaction.amount)}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isIncome ? 'Income' : 'Expense',
                  style: AppTheme.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.topup:
        return Icons.account_balance;
      case TransactionType.cashout:
        return Icons.money_off;
      case TransactionType.transfer:
        return Icons.send;
      case TransactionType.airtime:
        return Icons.phone_android;
      case TransactionType.data:
        return Icons.wifi;
      case TransactionType.utility:
        return Icons.bolt;
      case TransactionType.school:
        return Icons.school;
      case TransactionType.merchant:
        return Icons.store;
      default:
        return Icons.swap_horiz;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat('MMM d').format(date);
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(4, (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, color: AppTheme.borderColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 120, color: AppTheme.borderColor),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 80, color: AppTheme.borderColor),
                ],
              ),
            ),
            Column(
              children: [
                Container(height: 20, width: 80, color: AppTheme.borderColor),
                const SizedBox(height: 8),
                Container(height: 20, width: 60, color: AppTheme.borderColor),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent activity will appear here',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}