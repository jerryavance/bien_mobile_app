import 'package:flutter/material.dart';
import '../../core/design_system/app_theme.dart';

class UtilityPaymentScreen extends StatefulWidget {
  const UtilityPaymentScreen({super.key});

  @override
  State<UtilityPaymentScreen> createState() => _UtilityPaymentScreenState();
}

class _UtilityPaymentScreenState extends State<UtilityPaymentScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedUtility;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pay Utility'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Utility', style: AppTheme.heading4),
            const SizedBox(height: 16),
            ...UgandaConstants.utilityProviders.map((utility) {
              final isSelected = _selectedUtility == utility['code'];
              return GestureDetector(
                onTap: () => setState(() => _selectedUtility = utility['code'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.electric_bolt, color: AppTheme.warningColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(utility['name'] as String, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600))),
                      if (isSelected) Icon(Icons.check_circle, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedUtility != null) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  hintText: 'Enter your account number',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '50,000',
                  prefixText: 'UGX ',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
                        title: const Text('Payment Successful'),
                        content: Text('Utility payment of ${AppTheme.formatUGX(double.tryParse(_amountController.text) ?? 0)} processed'),
                        actions: [ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text('Done'))],
                      ),
                    );
                  },
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}