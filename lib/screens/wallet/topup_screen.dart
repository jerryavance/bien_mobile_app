import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedSource = 'MTN Mobile Money';
  double _amount = 0;
  double _charges = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _calculateCharges() {
    setState(() {
      _amount = double.tryParse(_amountController.text) ?? 0;
      // Example charge: 1% or min 500 UGX
      _charges = _amount > 0 ? (_amount * 0.01).clamp(500, double.infinity) : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
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
              // Current Balance Card
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTheme.formatUGX(145000),
                      style: AppTheme.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Step 1: Select Source
              Text(
                'Step 1: Select Source of Funds',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              ...UgandaConstants.mobileMoneyNetworks.map((network) {
                final isSelected = _selectedSource == network['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSource = network['name'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (network['color'] as Color).withOpacity(0.1)
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? network['color'] as Color
                            : AppTheme.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (network['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.phone_android,
                            color: network['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            network['name'] as String,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: network['color'] as Color,
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 400 + UgandaConstants.mobileMoneyNetworks.indexOf(network) * 100));
              }),

              const SizedBox(height: 24),

              // Step 2: Enter Details
              Text(
                'Step 2: Enter Top-Up Details',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 16),

              // Phone Number Input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '0700 123 456',
                  prefixIcon: const Icon(Icons.phone),
                  helperText: 'Enter the number to collect funds from',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.replaceAll(RegExp(r'[^\d]'), '').length < 9) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
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
                    return 'Minimum top-up is UGX 1,000';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 1200.ms),

              const SizedBox(height: 16),

              // Quick Amount Buttons
              Row(
                children: [
                  Expanded(child: _buildQuickAmount(10000)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAmount(20000)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAmount(50000)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAmount(100000)),
                ],
              ).animate().fadeIn(delay: 1400.ms),

              if (_amount > 0) ...[
                const SizedBox(height: 24),

                // Step 3: Transaction Preview
                Text(
                  'Step 3: Transaction Preview',
                  style: AppTheme.heading4,
                ).animate().fadeIn(delay: 1600.ms),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildPreviewRow('Source', _selectedSource),
                      _buildPreviewRow('From Number', _phoneController.text),
                      _buildPreviewRow('Amount', AppTheme.formatUGX(_amount)),
                      _buildPreviewRow('Charges', AppTheme.formatUGX(_charges)),
                      const Divider(),
                      _buildPreviewRow(
                        'Total to Receive',
                        AppTheme.formatUGX(_amount - _charges),
                        isBold: true,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0),
              ],

              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTopUp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Proceed to Top Up'),
                ),
              ).animate().fadeIn(delay: 2000.ms),

              const SizedBox(height: 16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.infoColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will receive a prompt on your phone to authorize this transaction.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 2200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmount(int amount) {
    return OutlinedButton(
      onPressed: () {
        _amountController.text = amount.toString();
        _calculateCharges();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text('${amount ~/ 1000}K'),
    );
  }

  Widget _buildPreviewRow(String label, String value, {bool isBold = false}) {
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
              color: AppTheme.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
          title: const Text('Top-Up Initiated'),
          content: Text(
            'Please check your phone for a prompt to authorize this transaction of ${AppTheme.formatUGX(_amount)}',
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