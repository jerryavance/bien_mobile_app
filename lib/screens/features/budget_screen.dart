import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String _selectedPeriod = 'This Month';

  final List<Map<String, dynamic>> _budgetCategories = [
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant,
      'color': AppTheme.warningColor,
      'budget': 600.0,
      'spent': 487.50,
      'remaining': 112.50,
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': AppTheme.infoColor,
      'budget': 400.0,
      'spent': 324.80,
      'remaining': 75.20,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': AppTheme.accentColor,
      'budget': 300.0,
      'spent': 298.45,
      'remaining': 1.55,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': AppTheme.primaryColor,
      'budget': 500.0,
      'spent': 256.90,
      'remaining': 243.10,
    },
    {
      'name': 'Utilities',
      'icon': Icons.electric_bolt,
      'color': AppTheme.secondaryColor,
      'budget': 250.0,
      'spent': 198.75,
      'remaining': 51.25,
    },
    {
      'name': 'Healthcare',
      'icon': Icons.medical_services,
      'color': AppTheme.successColor,
      'budget': 200.0,
      'spent': 156.30,
      'remaining': 43.70,
    },
  ];

  double get _totalBudget => _budgetCategories.fold(0, (sum, category) => sum + (category['budget'] as double));
  double get _totalSpent => _budgetCategories.fold(0, (sum, category) => sum + (category['spent'] as double));
  double get _totalRemaining => _totalBudget - _totalSpent;
  double get _budgetUtilization => (_totalSpent / _totalBudget) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Budget Planner'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              'This Week',
              'This Month',
              'Last Month',
              'Next Month',
            ].map((period) => PopupMenuItem(
              value: period,
              child: Text(period),
            )).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Overview Card
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
                    'Budget Overview',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UGX ${_totalBudget.toStringAsFixed(0)}',
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
                              'Spent',
                              style: AppTheme.caption.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UGX ${_totalSpent.toStringAsFixed(0)}',
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
                              'Remaining',
                              style: AppTheme.caption.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UGX ${_totalRemaining.toStringAsFixed(0)}',
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
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _budgetUtilization / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_budgetUtilization.toStringAsFixed(1)}% of budget used',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Create new budget
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Budget'),
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
                      // Adjust budget
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Adjust'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Budget Categories
            Text(
              'Budget Categories',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 16),
            
            ..._budgetCategories.map((category) => _buildBudgetCategory(category)),
            
            const SizedBox(height: 24),
            
            // Budget Tips
            Text(
              'Budget Tips',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 16),
            
            _buildTipCard(
              'Track Daily Spending',
              'Monitor your expenses daily to stay within budget limits',
              Icons.track_changes,
              AppTheme.infoColor,
            ),
            
            _buildTipCard(
              'Set Realistic Goals',
              'Create achievable budget targets based on your income',
              Icons.flag,
              AppTheme.successColor,
            ),
            
            _buildTipCard(
              'Review Monthly',
              'Analyze your spending patterns and adjust budgets accordingly',
              Icons.analytics,
              AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCategory(Map<String, dynamic> category) {
    final budget = category['budget'] as double;
    final spent = category['spent'] as double;
    final remaining = category['remaining'] as double;
    final utilization = (spent / budget) * 100;
    final isOverBudget = spent > budget;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget ? AppTheme.errorColor : AppTheme.borderColor,
          width: isOverBudget ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'] as String,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Budget: UGX ${budget.toStringAsFixed(0)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'UGX ${spent.toStringAsFixed(0)}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOverBudget ? AppTheme.errorColor : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${utilization.toStringAsFixed(1)}%',
                    style: AppTheme.caption.copyWith(
                      color: isOverBudget ? AppTheme.errorColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? AppTheme.errorColor : (category['color'] as Color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: UGX ${remaining.toStringAsFixed(0)}',
                style: AppTheme.bodySmall.copyWith(
                  color: remaining > 0 ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Over Budget',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
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
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
