import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Income', 'Expense', 'Pending', 'Failed'];

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': '1',
      'title': 'Netflix Subscription',
      'subtitle': 'Entertainment',
      'amount': 15000.0,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'completed',
      'type': 'expense',
      'icon': Icons.tv,
      'color': AppTheme.errorColor,
    },
    {
      'id': '2',
      'title': 'Salary Deposit',
      'subtitle': 'Income',
      'amount': 4200000.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'completed',
      'type': 'income',
      'icon': Icons.account_balance,
      'color': AppTheme.successColor,
    },
    {
      'id': '3',
      'title': 'Grocery Shopping',
      'subtitle': 'Food & Dining',
      'amount': -87000.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'completed',
      'type': 'expense',
      'icon': Icons.shopping_cart,
      'color': AppTheme.warningColor,
    },
    {
      'id': '4',
      'title': 'Investment Return',
      'subtitle': 'Portfolio',
      'amount': 1560000.0,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'completed',
      'type': 'income',
      'icon': Icons.trending_up,
      'color': AppTheme.secondaryColor,
    },
    {
      'id': '5',
      'title': 'Uber Ride',
      'subtitle': 'Transportation',
      'amount': -23000.0,
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'status': 'completed',
      'type': 'expense',
      'icon': Icons.directions_car,
      'color': AppTheme.infoColor,
    },
    {
      'id': '6',
      'title': 'Freelance Payment',
      'subtitle': 'Income',
      'amount': 5000000.0,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'pending',
      'type': 'income',
      'icon': Icons.work,
      'color': AppTheme.accentColor,
    },
    {
      'id': '7',
      'title': 'Electric Bill',
      'subtitle': 'Utilities',
      'amount': -89000.0,
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'status': 'completed',
      'type': 'expense',
      'icon': Icons.electric_bolt,
      'color': AppTheme.warningColor,
    },
    {
      'id': '8',
      'title': 'Amazon Purchase',
      'subtitle': 'Shopping',
      'amount': -156000.0,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'completed',
      'type': 'expense',
      'icon': Icons.shopping_bag,
      'color': AppTheme.primaryColor,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> filtered = _transactions;

    // Filter by type
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Income') {
        filtered = filtered.where((t) => t['type'] == 'income').toList();
      } else if (_selectedFilter == 'Expense') {
        filtered = filtered.where((t) => t['type'] == 'expense').toList();
      } else if (_selectedFilter == 'Pending') {
        filtered = filtered.where((t) => t['status'] == 'pending').toList();
      } else if (_selectedFilter == 'Failed') {
        filtered = filtered.where((t) => t['status'] == 'failed').toList();
      }
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
          t['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  String _formatAmount(double amount) {
    // Format large UGX amounts with K and M suffixes
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),

          // Filter Chips
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),

          // Transaction Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredTransactions.length} transactions',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  _getTotalAmount(),
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),

          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return _buildTransactionItem(transaction, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, int index) {
    final isIncome = transaction['type'] == 'income';
    final amount = transaction['amount'] as double;
    final status = transaction['status'] as String;

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
          const SizedBox(width: 12),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        transaction['subtitle'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction['date'] as DateTime),
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${_formatAmount(amount.abs())}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'UGX',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (600 + index * 100).ms).slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = AppTheme.successColor;
        label = 'Done';
        break;
      case 'pending':
        color = AppTheme.warningColor;
        label = 'Pending';
        break;
      case 'failed':
        color = AppTheme.errorColor;
        label = 'Failed';
        break;
      default:
        color = AppTheme.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 9,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getTotalAmount() {
    double total = 0;
    for (final transaction in _filteredTransactions) {
      total += transaction['amount'] as double;
    }
    return 'UGX ${_formatAmount(total)}';
  }

  void _showFilterModal(BuildContext context) {
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
                    'Filter Transactions',
                    style: AppTheme.heading4.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._filters.map((filter) => ListTile(
                    title: Text(filter),
                    trailing: _selectedFilter == filter
                        ? Icon(Icons.check, color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}