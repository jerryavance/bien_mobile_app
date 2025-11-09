import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  
  String _selectedContact = '';
  String _selectedMethod = 'Bank Transfer';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _recentContacts = [
    {
      'name': 'Jerry Vance Anguzu',
      'phone': '+256 786 493685',
      'avatar': 'JS',
      'color': Colors.blue,
      'isFavorite': true,
    },
    {
      'name': 'Jojo Jojo',
      'phone': '+256 773 493685',
      'avatar': 'SJ',
      'color': Colors.green,
      'isFavorite': true,
    },
    {
      'name': 'Ian Nelson',
      'phone': '+256 787 493685',
      'avatar': 'MW',
      'color': Colors.orange,
      'isFavorite': false,
    },
    {
      'name': 'Emma David',
      'phone': '+256 777 493685',
      'avatar': 'ED',
      'color': Colors.purple,
      'isFavorite': true,
    },
  ];

  final List<Map<String, dynamic>> _transferMethods = [
    {
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'color': AppTheme.primaryColor,
      'fee': 'Free',
      'time': '1-3 business days',
    },
    {
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
      'color': AppTheme.secondaryColor,
      'fee': '\$0.99',
      'time': 'Instant',
    },
    {
      'name': 'FlexiPay',
      'icon': Icons.payment,
      'color': AppTheme.infoColor,
      'fee': '2.9%',
      'time': 'Instant',
    },
    {
      'name': 'Wendi',
      'icon': Icons.account_balance_wallet,
      'color': AppTheme.accentColor,
      'fee': 'Free',
      'time': 'Instant',
    },
    {
      'name': 'International',
      'icon': Icons.attach_money,
      'color': AppTheme.successColor,
      'fee': 'Free',
      'time': 'Instant',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
          'Send Money',
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
            onPressed: () => _showTransferHistory(),
            icon: Icon(Icons.history, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Send Section
              _buildQuickSendSection(),
              
              const SizedBox(height: 24),
              
              // Transfer Method Selection
              _buildTransferMethodSection(),
              
              const SizedBox(height: 24),
              
              // Contact Selection
              _buildContactSelectionSection(),
              
              if (_selectedContact.isNotEmpty) ...[
                const SizedBox(height: 24),
                
                // Amount Input Section
                _buildAmountInputSection(),
                
                const SizedBox(height: 24),
                
                // Note Section
                _buildNoteSection(),
                
                const SizedBox(height: 32),
                
                // Send Button
                _buildSendButton(),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSendSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Send',
                      style: AppTheme.heading4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Send money to your favorite contacts instantly',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickAmountButton('50'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAmountButton('100'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAmountButton('200'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAmountButton('500'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickAmountButton(String amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Text(
          'UGX $amount',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTransferMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer Method',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _transferMethods.length,
            itemBuilder: (context, index) {
              final method = _transferMethods[index];
              final isSelected = _selectedMethod == method['name'];
              
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMethod = method['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (method['color'] as Color).withValues(alpha: 0.1)
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? method['color'] as Color
                            : AppTheme.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          method['name'] as String,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method['fee'] as String,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildContactSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send to',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 600.ms),
        
        const SizedBox(height: 16),
        
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search contacts or enter phone number...',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3, end: 0),
        
        const SizedBox(height: 20),
        
        // Recent Contacts
        Text(
          'Recent Contacts',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 1000.ms),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _recentContacts.length,
          itemBuilder: (context, index) {
            final contact = _recentContacts[index];
            final isSelected = _selectedContact == contact['name'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedContact = contact['name'];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: contact['color'] as Color,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text(
                              contact['avatar'] as String,
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (contact['isFavorite'] as bool)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contact['name'] as String,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact['phone'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 1200 + index * 100)).slideY(begin: 0.3, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildAmountInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 1400.ms),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.secondaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'UGX',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppTheme.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        // Handle amount change
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAmountInfo('Fee', 'Free'),
                  _buildAmountInfo('Time', 'Instant'),
                  _buildAmountInfo('Limit', 'Unlimited'),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildAmountInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 1800.ms),
        
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note for this transfer...',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ).animate().fadeIn(delay: 2000.ms).slideX(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendMoney,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Send Money',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 2200.ms).slideY(begin: 0.3, end: 0);
  }

  void _handleSendMoney() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedContact.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a contact to send money to'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Money sent successfully to $_selectedContact!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  void _showTransferHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer History'),
        content: Text('View your complete transfer history and track all transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transactions');
            },
            child: Text('View History'),
          ),
        ],
      ),
    );
  }
}
