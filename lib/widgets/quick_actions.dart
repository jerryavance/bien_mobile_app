import 'package:flutter/material.dart';
import '../core/design_system/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.savings,
        'label': 'Top-up',
        'color': AppTheme.successColor,
        'onTap': () {
          // Navigate to savings screen
          Navigator.pushNamed(context, '/top-up');
        },
      },
      {
        'icon': Icons.savings,
        'label': 'Cash-Out',
        'color': AppTheme.successColor,
        'onTap': () {
          // Navigate to savings screen
          Navigator.pushNamed(context, '/cash-out');
        },
      },
      {
        'icon': Icons.send,
        'label': 'Send',
        'color': AppTheme.primaryColor,
        'onTap': () {
          // Navigate to send money screen
          Navigator.pushNamed(context, '/send-money');
        },
      },
      {
        'icon': Icons.download,
        'label': 'Receive',
        'color': AppTheme.secondaryColor,
        'onTap': () {
          // Navigate to receive money screen
          Navigator.pushNamed(context, '/transactions');
        },
      },
      {
        'icon': Icons.trending_up,
        'label': 'Invest',
        'color': AppTheme.accentColor,
        'onTap': () {
          // Navigate to investment screen
          Navigator.pushNamed(context, '/investments');
        },
      },
      {
        'icon': Icons.credit_card,
        'label': 'Cards',
        'color': AppTheme.infoColor,
        'onTap': () {
          // Navigate to cards screen
          Navigator.pushNamed(context, '/cards');
        },
      },
      {
        'icon': Icons.savings,
        'label': 'Savings',
        'color': AppTheme.successColor,
        'onTap': () {
          // Navigate to savings screen
          Navigator.pushNamed(context, '/savings');
        },
      },
      {
        'icon': Icons.more_horiz,
        'label': 'More',
        'color': AppTheme.textSecondary,
        'onTap': () {
          _showMoreOptions(context);
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: action['onTap'] as VoidCallback,
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  action['label'] as String,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMoreOption(
                    context,
                    Icons.security,
                    'Security Settings',
                    '/security-settings',
                    AppTheme.primaryColor,
                  ),
                  _buildMoreOption(
                    context,
                    Icons.currency_exchange,
                    'Currency Converter',
                    '/currency-converter',
                    AppTheme.secondaryColor,
                  ),
                  _buildMoreOption(
                    context,
                    Icons.receipt_long,
                    'Bill Payments',
                    '/bill-payments',
                    AppTheme.accentColor,
                  ),
                  _buildMoreOption(
                    context,
                    Icons.calculate,
                    'Loan Calculator',
                    '/loan-calculator',
                    AppTheme.infoColor,
                  ),
                  _buildMoreOption(
                    context,
                    Icons.assessment,
                    'Tax Calculator',
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
    );
  }

  Widget _buildMoreOption(
    BuildContext context,
    IconData icon,
    String label,
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
}
