import 'package:flutter/material.dart';
import '../../core/design_system/app_theme.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedNetwork = 'MTN';
  double _amount = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Buy Airtime'),
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
              Text('Select Network', style: AppTheme.heading4),
              const SizedBox(height: 16),
              Row(
                children: UgandaConstants.telecomNetworks.map((network) {
                  final isSelected = _selectedNetwork == network['code'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedNetwork = network['code'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? (network['color'] as Color).withOpacity(0.1) : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? network['color'] as Color : AppTheme.borderColor, width: isSelected ? 2 : 1),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.signal_cellular_alt, color: network['color'] as Color, size: 32),
                            const SizedBox(height: 8),
                            Text(network['code'] as String, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '0700 123 456',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '10,000',
                  prefixText: 'UGX ',
                  prefixIcon: Icon(Icons.money),
                ),
                onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(v);
                  if (amt == null || amt < 500) return 'Minimum UGX 500';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) {
                        setState(() => _isLoading = false);
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
                            title: const Text('Airtime Sent'),
                            content: Text('${AppTheme.formatUGX(_amount)} sent to ${_phoneController.text}'),
                            actions: [ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text('Done'))],
                          ),
                        );
                      }
                    }
                  },
                  child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Buy Airtime'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}