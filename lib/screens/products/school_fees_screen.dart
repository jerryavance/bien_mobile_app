import 'package:flutter/material.dart';
import '../../core/design_system/app_theme.dart';

class SchoolFeesScreen extends StatefulWidget {
  const SchoolFeesScreen({super.key});

  @override
  State<SchoolFeesScreen> createState() => _SchoolFeesScreenState();
}

class _SchoolFeesScreenState extends State<SchoolFeesScreen> {
  final _studentNumberController = TextEditingController();
  final _schoolCodeController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedSystem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pay School Fees'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Payment System', style: AppTheme.heading4),
            const SizedBox(height: 16),
            ...UgandaConstants.schoolPaymentSystems.map((system) {
              final isSelected = _selectedSystem == system['code'];
              return GestureDetector(
                onTap: () => setState(() => _selectedSystem = system['code'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.successColor.withOpacity(0.1) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppTheme.successColor : AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: AppTheme.successColor, size: 32),
                      const SizedBox(width: 16),
                      Expanded(child: Text(system['name'] as String, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600))),
                      if (isSelected) Icon(Icons.check_circle, color: AppTheme.successColor),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedSystem != null) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  hintText: 'Enter student number',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolCodeController,
                decoration: const InputDecoration(
                  labelText: 'School Code',
                  hintText: 'Enter school code',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '500,000',
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
                        content: Text('School fees of ${AppTheme.formatUGX(double.tryParse(_amountController.text) ?? 0)} paid'),
                        actions: [ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text('Done'))],
                      ),
                    );
                  },
                  child: const Text('Pay School Fees'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}