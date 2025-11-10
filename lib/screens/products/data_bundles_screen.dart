import 'package:flutter/material.dart';
import '../../core/design_system/app_theme.dart';

class DataBundlesScreen extends StatefulWidget {
  const DataBundlesScreen({super.key});

  @override
  State<DataBundlesScreen> createState() => _DataBundlesScreenState();
}

class _DataBundlesScreenState extends State<DataBundlesScreen> {
  final _phoneController = TextEditingController();
  String _selectedNetwork = 'MTN';
  Map<String, dynamic>? _selectedBundle;

  final List<Map<String, dynamic>> _dataBundles = [
    {'size': '100MB', 'validity': '24 Hours', 'price': 1000},
    {'size': '500MB', 'validity': '3 Days', 'price': 3000},
    {'size': '1GB', 'validity': '7 Days', 'price': 5000},
    {'size': '2GB', 'validity': '30 Days', 'price': 10000},
    {'size': '5GB', 'validity': '30 Days', 'price': 20000},
    {'size': '10GB', 'validity': '30 Days', 'price': 35000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Data Bundles'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? (network['color'] as Color).withOpacity(0.1) : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? network['color'] as Color : AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.signal_cellular_alt, color: network['color'] as Color),
                          const SizedBox(height: 8),
                          Text(network['code'] as String, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold)),
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
            ),
            const SizedBox(height: 24),
            Text('Select Data Bundle', style: AppTheme.heading4),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _dataBundles.length,
              itemBuilder: (context, index) {
                final bundle = _dataBundles[index];
                final isSelected = _selectedBundle == bundle;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBundle = bundle),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(bundle['size'], style: AppTheme.heading3.copyWith(color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary)),
                        const SizedBox(height: 8),
                        Text(bundle['validity'], style: AppTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text(AppTheme.formatUGX(bundle['price'].toDouble()), style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedBundle == null || _phoneController.text.isEmpty ? null : () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
                      title: const Text('Data Bundle Purchased'),
                      content: Text('${_selectedBundle!['size']} sent to ${_phoneController.text}'),
                      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text('Done'))],
                    ),
                  );
                },
                child: const Text('Buy Data Bundle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}