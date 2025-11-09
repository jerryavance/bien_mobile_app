import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/design_system/app_theme.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  // Helper method to format large UGX amounts
  String _formatAmount(String amount) {
    // Remove 'UGX ' prefix and parse
    final numStr = amount.replaceAll('UGX ', '').replaceAll(',', '');
    final num = double.tryParse(numStr) ?? 0;
    
    // Format based on size
    if (num >= 1000000) {
      return 'UGX ${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return 'UGX ${(num / 1000).toStringAsFixed(1)}K';
    } else {
      return 'UGX ${NumberFormat('#,###').format(num)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'Income',
        'amount': 'UGX 50,000',
        'change': '+12.5%',
        'isPositive': true,
        'icon': Icons.trending_up,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Expenses',
        'amount': 'UGX 20,000',
        'change': '-8.2%',
        'isPositive': false,
        'icon': Icons.trending_down,
        'color': AppTheme.errorColor,
      },
      {
        'title': 'Savings',
        'amount': 'UGX 15,000',
        'change': '+15.3%',
        'isPositive': true,
        'icon': Icons.savings,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Investments',
        'amount': 'UGX 100000',
        'change': '+5.7%',
        'isPositive': true,
        'icon': Icons.analytics,
        'color': AppTheme.accentColor,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1, // Slightly taller to accommodate content
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
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
                      _formatAmount(stat['amount'] as String),
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        (stat['isPositive'] as bool) 
                            ? Icons.arrow_upward 
                            : Icons.arrow_downward,
                        color: stat['color'] as Color,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stat['change'] as String,
                        style: AppTheme.caption.copyWith(
                          color: stat['color'] as Color,
                          fontWeight: FontWeight.w600,
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
  }
}
