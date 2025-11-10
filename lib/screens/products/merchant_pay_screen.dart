import 'package:flutter/material.dart';
import '../../core/design_system/app_theme.dart';

class MerchantPayScreen extends StatefulWidget {
  const MerchantPayScreen({super.key});

  @override
  State<MerchantPayScreen> createState() => _MerchantPayScreenState();
}

class _MerchantPayScreenState extends State<MerchantPayScreen> {
  final _merchantCodeController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pay Merchant'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter merchant code manually or use Scan to Pay',
                      style: AppTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _merchantCodeController,
              decoration: const InputDecoration(
                labelText: 'Merchant Code',
                hintText: 'Enter 6-digit merchant code',
                prefixIcon: Icon(Icons.store),
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
                      content: Text('Paid ${AppTheme.formatUGX(double.tryParse(_amountController.text) ?? 0)} to merchant'),
                      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text('Done'))],
                    ),
                  );
                },
                child: const Text('Pay Merchant'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/scan-to-pay');
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code Instead'),
            ),
          ],
        ),
      ),
    );
  }
}