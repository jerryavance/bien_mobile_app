import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final List<Map<String, dynamic>> _savingsGoals = [
    {
      'title': 'Emergency Fund',
      'target': 10000.0,
      'current': 6500.0,
      'icon': Icons.shield,
      'color': AppTheme.primaryColor,
      'deadline': '2025-12-31',
      'category': 'Emergency',
    },
    {
      'title': 'Vacation Fund',
      'target': 5000.0,
      'current': 3200.0,
      'icon': Icons.flight,
      'color': AppTheme.secondaryColor,
      'deadline': '2025-06-15',
      'category': 'Travel',
    },
    {
      'title': 'New Car',
      'target': 25000.0,
      'current': 8500.0,
      'icon': Icons.directions_car,
      'color': AppTheme.accentColor,
      'deadline': '2025-03-20',
      'category': 'Vehicle',
    },
    {
      'title': 'Home Renovation',
      'target': 15000.0,
      'current': 4200.0,
      'icon': Icons.home,
      'color': AppTheme.successColor,
      'deadline': '2025-09-30',
      'category': 'Home',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalTarget = _savingsGoals.fold(0.0, (sum, goal) => sum + goal['target']);
    final totalCurrent = _savingsGoals.fold(0.0, (sum, goal) => sum + goal['current']);
    final totalProgress = (totalCurrent / totalTarget) * 100;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Savings Goals',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to add savings goal screen
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Savings Overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
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
                  Text(
                    'Total Savings Progress',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'UGX ${totalCurrent.toStringAsFixed(0)}',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  Text(
                    'of UGX ${totalTarget.toStringAsFixed(0)}',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  LinearProgressIndicator(
                    value: totalProgress / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '${totalProgress.toStringAsFixed(1)}% Complete',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.add,
                    label: 'Add Goal',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      // Navigate to add goal screen
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.trending_up,
                    label: 'Track Progress',
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      // Navigate to progress tracking screen
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    color: AppTheme.accentColor,
                    onTap: () {
                      // Navigate to analytics screen
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 32),
            
            // Savings Goals
            Text(
              'Your Goals',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 16),
            
            ...List.generate(
              _savingsGoals.length,
              (index) => _buildSavingsGoal(_savingsGoals[index], index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
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
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoal(Map<String, dynamic> goal, int index) {
    final progress = (goal['current'] / goal['target']) * 100;
    final remaining = goal['target'] - goal['current'];
    final deadline = DateTime.parse(goal['deadline']);
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: goal['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  goal['icon'],
                  color: goal['color'],
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'],
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      goal['category'],
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.textSecondary,
                ),
                onSelected: (value) {
                  // Handle menu actions
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Goal'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Goal', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(1)}%',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: AppTheme.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(goal['color']),
                minHeight: 8,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Financial Details
          Row(
            children: [
              Expanded(
                child: _buildFinancialDetail(
                  'Current',
                  'UGX ${goal['current'].toStringAsFixed(0)}',
                  AppTheme.textSecondary,
                ),
              ),
              Expanded(
                child: _buildFinancialDetail(
                  'Target',
                  'UGX ${goal['target'].toStringAsFixed(0)}',
                  AppTheme.textPrimary,
                ),
              ),
              Expanded(
                child: _buildFinancialDetail(
                  'Remaining',
                  'UGX ${remaining.toStringAsFixed(0)}',
                  AppTheme.warningColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Deadline and Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: daysLeft < 30 ? AppTheme.errorColor.withOpacity(0.1) : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$daysLeft days left',
                  style: AppTheme.caption.copyWith(
                    color: daysLeft < 30 ? AppTheme.errorColor : AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              ElevatedButton(
                onPressed: () {
                  // Navigate to add money to goal screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goal['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add Money',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (800 + index * 200).ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildFinancialDetail(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
