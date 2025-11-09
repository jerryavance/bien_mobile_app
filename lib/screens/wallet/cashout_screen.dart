import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _amountController = TextEditingController();
  final _bankAccountController = TextEditingController();
  
  String _selectedMethod = 'Mobile Money';
  String _selectedNetwork = 'MTN Mobile Money';
  String _selectedBank = '';
  double _amount = 0;
  double _charges = 0;
  bool _isLoading = false;

  final List<Map<String, String>> _cashOutMethods = [
    {'name': 'Mobile Money', 'icon': 'phone'},
    {'name': 'Bank Transfer', 'icon': 'bank'},
    {'name': 'Bien to Bien', 'icon': 'transfer'},
  ];

  final List<String> _ugandanBanks = [
    'Stanbic Bank',
    'Centenary Bank',
    'dfcu Bank',
    'Bank of Africa',
    'Equity Bank',
    'Standard Chartered',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    _amountController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  void _calculateCharges() {
    setState(() {
      _amount = double.tryParse(_amountController.text) ?? 0;
      if (_amount <= 0) {
        _charges = 0;
        return;
      }

      // Calculate charges based on method
      switch (_selectedMethod) {
        case 'Mobile Money':
          _charges = (_amount * 0.01).clamp(500, 2000); // 1% max 2,000 UGX
          break;
        case 'Bank Transfer':
          _charges = 1500; // Flat 1,500 UGX
          break;
        case 'Bien to Bien':
          _charges = 0; // Free
          break;
        default:
          _charges = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Cash Out'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          AppTheme.formatUGX(145000),
                          style: AppTheme.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Step 1: Select Destination
              Text(
                'Step 1: Select Destination',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              Row(
                children: _cashOutMethods.map((method) {
                  final isSelected = _selectedMethod == method['name'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMethod = method['name']!;
                        });
                        _calculateCharges();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getMethodIcon(method['icon']!),
                              color: isSelected 
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              method['name']!,
                              style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // Step 2: Enter Details
              Text(
                'Step 2: Enter Cash Out Details',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              // Dynamic fields based on method
              if (_selectedMethod == 'Mobile Money') ...[
                // Network Selection
                DropdownButtonFormField<String>(
                  value: _selectedNetwork,
                  decoration: const InputDecoration(
                    labelText: 'Select Network',
                    prefixIcon: Icon(Icons.network_cell),
                  ),
                  items: UgandaConstants.mobileMoneyNetworks.map((network) {
                    return DropdownMenuItem(
                      value: network['name'] as String,
                      child: Text(network['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedNetwork = value!);
                  },
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _destinationController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '0700 123 456',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 1000.ms),
              ] else if (_selectedMethod == 'Bank Transfer') ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Bank',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: _ugandanBanks.map((bank) {
                    return DropdownMenuItem(value: bank, child: Text(bank));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedBank = value!);
                  },
                  validator: (value) => value == null ? 'Please select a bank' : null,
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _bankAccountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    hintText: 'Enter bank account number',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account number';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 1000.ms),
              ] else if (_selectedMethod == 'Bien to Bien') ...[
                TextFormField(
                  controller: _destinationController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Phone or Bien ID',
                    hintText: '0700 123 456 or BIEN12345',
                    prefixIcon: Icon(Icons.person),
                    helperText: 'Enter Bien user phone number or ID',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter recipient details';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 800.ms),
              ],

              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount to Cash Out',
                  hintText: '10,000',
                  prefixText: 'UGX ',
                  prefixIcon: Icon(Icons.money),
                ),
                onChanged: (value) => _calculateCharges(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 1000) {
                    return 'Minimum cash out is UGX 1,000';
                  }
                  if (amount > 145000) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 1200.ms),

              if (_amount > 0) ...[
                const SizedBox(height: 24),

                // Step 3: Preview
                Text(
                  'Step 3: Transaction Preview',
                  style: AppTheme.heading4,
                ).animate().fadeIn(delay: 1400.ms),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildPreviewRow('Method', _selectedMethod),
                      if (_selectedMethod == 'Mobile Money')
                        _buildPreviewRow('Network', _selectedNetwork),
                      if (_selectedMethod == 'Bank Transfer')
                        _buildPreviewRow('Bank', _selectedBank),
                      _buildPreviewRow('Destination', 
                        _selectedMethod == 'Bank Transfer' 
                            ? _bankAccountController.text 
                            : _destinationController.text),
                      _buildPreviewRow('Amount', AppTheme.formatUGX(_amount)),
                      _buildPreviewRow('Charges', AppTheme.formatUGX(_charges)),
                      const Divider(),
                      _buildPreviewRow(
                        'Total Deduction',
                        AppTheme.formatUGX(_amount + _charges),
                        isBold: true,
                      ),
                      _buildPreviewRow(
                        'You Will Receive',
                        AppTheme.formatUGX(_amount),
                        isBold: true,
                        color: AppTheme.successColor,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1600.ms),
              ],

              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCashOut,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm Cash Out'),
                ),
              ).animate().fadeIn(delay: 1800.ms),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(String icon) {
    switch (icon) {
      case 'phone': return Icons.phone_android;
      case 'bank': return Icons.account_balance;
      case 'transfer': return Icons.swap_horiz;
      default: return Icons.payment;
    }
  }

  Widget _buildPreviewRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: color ?? AppTheme.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCashOut() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
          title: const Text('Cash Out Successful'),
          content: Text(
            'Your cash out of ${AppTheme.formatUGX(_amount)} has been processed successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }
}