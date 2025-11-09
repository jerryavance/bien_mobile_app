import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class BillPaymentsScreen extends StatefulWidget {
  const BillPaymentsScreen({super.key});

  @override
  State<BillPaymentsScreen> createState() => _BillPaymentsScreenState();
}

class _BillPaymentsScreenState extends State<BillPaymentsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Utilities',
    'Internet & Phone',
    'Insurance',
    'Subscriptions',
    'Rent & Mortgage',
    'Credit Cards',
    'Other',
  ];

  final List<Map<String, dynamic>> _bills = [
    {
      'id': '1',
      'name': 'Electricity Bill',
      'provider': 'PowerCorp',
      'amount': 8900,
      'dueDate': '2025-01-15',
      'category': 'Utilities',
      'isPaid': false,
      'isOverdue': false,
      'icon': Icons.electric_bolt,
      'color': AppTheme.warningColor,
    },
    {
      'id': '2',
      'name': 'Internet & Phone',
      'provider': 'ConnectNet',
      'amount': 12999,
      'dueDate': '2025-01-20',
      'category': 'Internet & Phone',
      'isPaid': false,
      'isOverdue': false,
      'icon': Icons.wifi,
      'color': AppTheme.primaryColor,
    },
    {
      'id': '3',
      'name': 'Car Insurance',
      'provider': 'SafeDrive Insurance',
      'amount': 24500,
      'dueDate': '2025-01-10',
      'category': 'Insurance',
      'isPaid': true,
      'isOverdue': false,
      'icon': Icons.car_crash,
      'color': AppTheme.successColor,
    },
    {
      'id': '4',
      'name': 'Netflix Subscription',
      'provider': 'Netflix',
      'amount': 15099,
      'dueDate': '2025-01-25',
      'category': 'Subscriptions',
      'isPaid': false,
      'isOverdue': false,
      'icon': Icons.tv,
      'color': AppTheme.errorColor,
    },
    {
      'id': '5',
      'name': 'Rent Payment',
      'provider': 'City Apartments',
      'amount': 12000,
      'dueDate': '2025-01-01',
      'category': 'Rent & Mortgage',
      'isPaid': true,
      'isOverdue': false,
      'icon': Icons.home,
      'color': AppTheme.secondaryColor,
    },
    {
      'id': '6',
      'name': 'DFCU Card Payment',
      'provider': 'DFCU Bank',
      'amount': 45075,
      'dueDate': '2025-01-05',
      'category': 'Credit Cards',
      'isPaid': false,
      'isOverdue': true,
      'icon': Icons.credit_card,
      'color': AppTheme.errorColor,
    },
  ];

  final List<Map<String, dynamic>> _quickPayments = [
    {
      'name': 'Pay All Bills',
      'icon': Icons.payment,
      'color': AppTheme.primaryColor,
      'description': 'Pay all pending bills at once',
    },
    {
      'name': 'Auto-Pay Setup',
      'icon': Icons.schedule,
      'color': AppTheme.secondaryColor,
      'description': 'Set up automatic bill payments',
    },
    {
      'name': 'Bill Reminders',
      'icon': Icons.notifications,
      'color': AppTheme.accentColor,
      'description': 'Manage payment reminders',
    },
    {
      'name': 'Payment History',
      'icon': Icons.history,
      'color': AppTheme.infoColor,
      'description': 'View all payment history',
    },
  ];

  List<Map<String, dynamic>> get _filteredBills {
    if (_selectedCategory == 'All') {
      return _bills;
    }
    return _bills.where((bill) => bill['category'] == _selectedCategory).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Bill Payments',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddBillDialog(),
            icon: Icon(Icons.add, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bills Due',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UGX ${_getTotalDue().toStringAsFixed(2)}',
                          style: AppTheme.heading1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Paid',
                        _getPaidCount(),
                        AppTheme.successColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Pending',
                        _getPendingCount(),
                        AppTheme.warningColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Overdue',
                        _getOverdueCount(),
                        AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bills...',
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: AppTheme.surfaceColor,
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Quick Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 16),

          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickPayments.length,
              itemBuilder: (context, index) {
                return _buildQuickActionCard(_quickPayments[index], index);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Bills List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Your Bills',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredBills.length} bills',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),

          const SizedBox(height: 16),

          // Bills List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBills.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredBills.length,
                        itemBuilder: (context, index) {
                          return _buildBillTile(_filteredBills[index], index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: AppTheme.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action, int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: action['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action['icon'],
              color: action['color'],
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            action['name'],
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            action['description'],
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 800 + index * 100)).slideX(begin: 0.3, end: 0);
  }

  Widget _buildBillTile(Map<String, dynamic> bill, int index) {
    final dueDate = DateTime.parse(bill['dueDate']);
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue <= 3 && daysUntilDue >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bill['isPaid']
              ? AppTheme.successColor.withOpacity(0.3)
              : isOverdue
                  ? AppTheme.errorColor.withOpacity(0.3)
                  : isDueSoon
                      ? AppTheme.warningColor.withOpacity(0.3)
                      : AppTheme.borderColor,
        ),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bill['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            bill['icon'],
            color: bill['color'],
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                bill['name'],
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (bill['isPaid'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PAID',
                  style: AppTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'OVERDUE',
                  style: AppTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isDueSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'DUE SOON',
                  style: AppTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              bill['provider'],
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Due: ${_formatDate(dueDate)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: isOverdue
                        ? AppTheme.errorColor
                        : isDueSoon
                            ? AppTheme.warningColor
                            : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'UGX ${bill['amount'].toStringAsFixed(2)}',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: bill['isPaid']
            ? Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 24,
              )
            : IconButton(
                onPressed: () => _payBill(bill),
                icon: Icon(
                  Icons.payment,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
        onTap: () => _showBillDetails(bill),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 1000 + index * 100)).slideX(begin: 0.3, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.receipt_long,
              color: AppTheme.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No bills found',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up with your bills!',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  double _getTotalDue() {
    return _bills
        .where((bill) => !bill['isPaid'])
        .fold(0.0, (sum, bill) => sum + bill['amount']);
  }

  int _getPaidCount() {
    return _bills.where((bill) => bill['isPaid']).length;
  }

  int _getPendingCount() {
    return _bills.where((bill) => !bill['isPaid'] && !bill['isOverdue']).length;
  }

  int _getOverdueCount() {
    return _bills.where((bill) => bill['isOverdue']).length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return '${difference.abs()} days ago';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return 'in $difference days';
    }
  }

  void _payBill(Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pay UGX ${bill['amount'].toStringAsFixed(2)} to ${bill['provider']}?'),
            const SizedBox(height: 16),
            Text(
              'Due: ${_formatDate(DateTime.parse(bill['dueDate']))}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(bill);
            },
            child: Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _processPayment(Map<String, dynamic> bill) {
    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          bill['isPaid'] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! ${bill['name']} has been paid.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _showBillDetails(Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bill['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Provider', bill['provider']),
            _buildDetailRow('Amount', 'UGX ${bill['amount'].toStringAsFixed(2)}'),
            _buildDetailRow('Due Date', bill['dueDate']),
            _buildDetailRow('Category', bill['category']),
            _buildDetailRow('Status', bill['isPaid'] ? 'Paid' : 'Pending'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (!bill['isPaid'])
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _payBill(bill);
              },
              child: Text('Pay Now'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bill Name',
                hintText: 'e.g., Electricity Bill',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Provider',
                hintText: 'e.g., UEDCL',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Due Date',
                hintText: 'YYYY-MM-DD',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('New bill added successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text('Add Bill'),
          ),
        ],
      ),
    );
  }
}
