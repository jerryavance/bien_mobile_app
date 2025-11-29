// ==========================================
// FILE: lib/screens/wallet/bien_transfer_screen.dart
// UPDATED: Two-step flow with validation confirmation
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/wallet_provider.dart';

class BienTransferScreen extends StatefulWidget {
  const BienTransferScreen({super.key});

  @override
  State<BienTransferScreen> createState() => _BienTransferScreenState();
}

class _BienTransferScreenState extends State<BienTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  double _amount = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    setState(() {
      _amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    });
  }

  // Step 1: Validate transaction
  Future<void> _handleValidation() async {
    if (!_formKey.currentState!.validate()) return;

    final walletProvider = context.read<WalletProvider>();
    final currentBalance = walletProvider.balance;
    
    if (_amount > currentBalance) {
      _showErrorDialog('Insufficient balance. You need ${AppTheme.formatUGX(_amount)} but only have ${AppTheme.formatUGX(currentBalance)}');
      return;
    }

    setState(() => _isLoading = true);

    final cleanRecipient = _recipientController.text.trim();
    
    final validationData = await walletProvider.validateTransfer(
      recipientId: cleanRecipient,
      amount: _amount,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (validationData != null) {
        _showValidationDialog(validationData);
      } else {
        _showErrorDialog(
          walletProvider.errorMessage ?? 'Validation failed. Please try again.',
        );
      }
    }
  }

  void _showValidationDialog(Map<String, dynamic> data) {
    final recipientName = data['full_name'] ?? 'Unknown';
    final accountName = data['account_name'] ?? '';
    final currency = data['currency'] ?? 'UGX';
    final charges = data['charges'] as Map<String, dynamic>?;
    final chargeAmount = (charges?['charge'] ?? 0).toDouble();
    final taxAmount = (charges?['tax'] ?? 0).toDouble();
    final totalCharges = (charges?['total'] ?? 0).toDouble();
    final validationRef = data['validation_ref'] as String?;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            const Text('Confirm Transfer'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please confirm the transfer details:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildValidationRow('Recipient', recipientName),
              if (accountName.isNotEmpty)
                _buildValidationRow('Account', accountName),
              _buildValidationRow('Recipient ID', _recipientController.text),
              const Divider(height: 24),
              _buildValidationRow('Amount', '$currency ${AppTheme.formatUGX(_amount)}'),
              _buildValidationRow('Fee', 'FREE', color: AppTheme.successColor),
              if (chargeAmount > 0 || taxAmount > 0) ...[
                _buildValidationRow('Charge', '$currency ${AppTheme.formatUGX(chargeAmount)}'),
                _buildValidationRow('Tax', '$currency ${AppTheme.formatUGX(taxAmount)}'),
              ],
              const Divider(height: 24),
              _buildValidationRow(
                'Total Deduction',
                '$currency ${AppTheme.formatUGX(_amount + totalCharges)}',
                isBold: true,
                color: AppTheme.errorColor,
              ),
              _buildValidationRow(
                'Recipient receives',
                '$currency ${AppTheme.formatUGX(_amount)}',
                isBold: true,
                color: AppTheme.successColor,
              ),
              if (_noteController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note:',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _noteController.text,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instant transfer - No fees for Bien to Bien transfers!',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WalletProvider>().clearValidationData();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: validationRef != null
                ? () {
                    Navigator.pop(context);
                    _handlePayment(validationRef);
                  }
                : null,
            child: const Text('Confirm & Transfer'),
          ),
        ],
      ),
    );
  }

  // Step 2: Complete transfer
  Future<void> _handlePayment(String validationRef) async {
    setState(() => _isLoading = true);

    final walletProvider = context.read<WalletProvider>();
    
    final transaction = await walletProvider.completeTransfer(
      validationRef: validationRef,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (transaction != null) {
        _showSuccessDialog(transaction.id, transaction.reference);
      } else {
        _showErrorDialog(
          walletProvider.errorMessage ?? 'Transfer failed. Please try again.',
        );
      }
    }
  }

  Widget _buildValidationRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: color ?? AppTheme.textPrimary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String transactionId, String? reference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: 64,
        ),
        title: const Text('Transfer Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your transfer of ${AppTheme.formatUGX(_amount)} has been completed successfully.',
              textAlign: TextAlign.center,
            ),
            if (reference != null) ...[
              const SizedBox(height: 16),
              Text(
                'Reference: $reference',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: AppTheme.errorColor,
          size: 64,
        ),
        title: const Text('Transfer Failed'),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final currentBalance = walletProvider.balance;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bien to Bien Transfer'),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
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
                          AppTheme.formatUGX(currentBalance),
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.infoColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transfer money instantly to any Bien user using their phone number or Bien wallet code. No fees charged!',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              Text(
                'Step 1: Enter Recipient Details',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              TextFormField(
                controller: _recipientController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Recipient Phone or Bien Code',
                  hintText: '0700123456 or A123456',
                  prefixIcon: Icon(Icons.person),
                  helperText: 'Enter phone number or Bien wallet code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient details';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 24),

              Text(
                'Step 2: Enter Amount',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount to Send',
                  hintText: '10,000',
                  prefixText: 'UGX ',
                  prefixIcon: Icon(Icons.money),
                ),
                onChanged: (value) => _calculateAmount(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(
                    value.replaceAll(',', ''),
                  );
                  if (amount == null || amount < 100) {
                    return 'Minimum transfer is UGX 100';
                  }
                  if (amount > currentBalance) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildQuickAmount(5000)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAmount(10000)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAmount(20000)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAmount(50000)),
                ],
              ).animate().fadeIn(delay: 1200.ms),

              const SizedBox(height: 24),

              Text(
                'Step 3: Add Note (Optional)',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 1400.ms),

              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Add a note for this transfer...',
                  prefixIcon: Icon(Icons.note),
                ),
              ).animate().fadeIn(delay: 1600.ms),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _amount <= 0) ? null : _handleValidation,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Continue to Confirm'),
                ),
              ).animate().fadeIn(delay: 2200.ms),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: AppTheme.successColor),
                        const SizedBox(width: 12),
                        Text(
                          'Free Transfers',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No fees charged for Bien to Bien transfers. Send money instantly to friends and family!',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 2400.ms),
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
        _calculateAmount();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text('${amount ~/ 1000}K'),
    );
  }
}



















// // ==========================================
// // FILE: lib/screens/wallet/bien_transfer_screen.dart
// // Bien to Bien transfer with real API integration
// // ==========================================
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import '../../core/design_system/app_theme.dart';
// import '../../providers/wallet_provider.dart';

// class BienTransferScreen extends StatefulWidget {
//   const BienTransferScreen({super.key});

//   @override
//   State<BienTransferScreen> createState() => _BienTransferScreenState();
// }

// class _BienTransferScreenState extends State<BienTransferScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _recipientController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _noteController = TextEditingController();
  
//   double _amount = 0;
//   bool _isLoading = false;
//   Map<String, dynamic>? _recipientInfo;

//   @override
//   void dispose() {
//     _recipientController.dispose();
//     _amountController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   void _calculateAmount() {
//     setState(() {
//       _amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
//     });
//   }

//   Future<void> _handleTransfer() async {
//     if (!_formKey.currentState!.validate()) return;

//     final walletProvider = context.read<WalletProvider>();
//     final currentBalance = walletProvider.balance;
    
//     // Check if user has sufficient balance
//     if (_amount > currentBalance) {
//       _showErrorDialog('Insufficient balance. You need ${AppTheme.formatUGX(_amount)} but only have ${AppTheme.formatUGX(currentBalance)}');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Clean recipient ID (remove spaces)
//       final cleanRecipient = _recipientController.text.trim();
      
//       // Call transfer API
//       final transaction = await walletProvider.transfer(
//         recipientId: cleanRecipient,
//         amount: _amount,
//         note: _noteController.text.isNotEmpty ? _noteController.text : null,
//       );

//       setState(() => _isLoading = false);

//       if (mounted) {
//         if (transaction != null) {
//           _showSuccessDialog(transaction.id, transaction.reference);
//         } else {
//           _showErrorDialog(
//             walletProvider.errorMessage ?? 'Transfer failed. Please try again.',
//           );
//         }
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         _showErrorDialog('An error occurred: $e');
//       }
//     }
//   }

//   void _showSuccessDialog(String transactionId, String? reference) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         icon: Icon(
//           Icons.check_circle,
//           color: AppTheme.successColor,
//           size: 64,
//         ),
//         title: const Text('Transfer Successful'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Your transfer of ${AppTheme.formatUGX(_amount)} has been completed successfully.',
//               textAlign: TextAlign.center,
//             ),
//             if (reference != null) ...[
//               const SizedBox(height: 16),
//               Text(
//                 'Reference: $reference',
//                 style: AppTheme.caption.copyWith(
//                   color: AppTheme.textSecondary,
//                 ),
//               ),
//             ],
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         icon: Icon(
//           Icons.error_outline,
//           color: AppTheme.errorColor,
//           size: 64,
//         ),
//         title: const Text('Transfer Failed'),
//         content: Text(message, textAlign: TextAlign.center),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final walletProvider = context.watch<WalletProvider>();
//     final currentBalance = walletProvider.balance;

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         title: const Text('Bien to Bien Transfer'),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back_ios),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Available Balance
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.primaryGradient,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
//                     const SizedBox(width: 16),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Available Balance',
//                           style: AppTheme.bodyMedium.copyWith(
//                             color: Colors.white.withOpacity(0.9),
//                           ),
//                         ),
//                         Text(
//                           AppTheme.formatUGX(currentBalance),
//                           style: AppTheme.heading3.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ).animate().fadeIn(duration: 600.ms),

//               const SizedBox(height: 24),

//               // Info Card
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppTheme.infoColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: AppTheme.infoColor),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Transfer money instantly to any Bien user using their phone number or Bien wallet code. No fees charged!',
//                         style: AppTheme.bodySmall.copyWith(
//                           color: AppTheme.textSecondary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 200.ms),

//               const SizedBox(height: 24),

//               // Step 1: Recipient Details
//               Text(
//                 'Step 1: Enter Recipient Details',
//                 style: AppTheme.heading4,
//               ).animate().fadeIn(delay: 400.ms),

//               const SizedBox(height: 16),

//               // Recipient Input
//               TextFormField(
//                 controller: _recipientController,
//                 keyboardType: TextInputType.text,
//                 decoration: const InputDecoration(
//                   labelText: 'Recipient Phone or Bien Code',
//                   hintText: '0700123456 or A123456',
//                   prefixIcon: Icon(Icons.person),
//                   helperText: 'Enter phone number or Bien wallet code',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter recipient details';
//                   }
//                   return null;
//                 },
//               ).animate().fadeIn(delay: 600.ms),

//               const SizedBox(height: 24),

//               // Step 2: Amount
//               Text(
//                 'Step 2: Enter Amount',
//                 style: AppTheme.heading4,
//               ).animate().fadeIn(delay: 800.ms),

//               const SizedBox(height: 16),

//               // Amount Input
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Amount to Send',
//                   hintText: '10,000',
//                   prefixText: 'UGX ',
//                   prefixIcon: Icon(Icons.money),
//                 ),
//                 onChanged: (value) => _calculateAmount(),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter amount';
//                   }
//                   final amount = double.tryParse(
//                     value.replaceAll(',', ''),
//                   );
//                   if (amount == null || amount < 100) {
//                     return 'Minimum transfer is UGX 100';
//                   }
//                   if (amount > currentBalance) {
//                     return 'Insufficient balance';
//                   }
//                   return null;
//                 },
//               ).animate().fadeIn(delay: 1000.ms),

//               const SizedBox(height: 16),

//               // Quick Amount Buttons
//               Row(
//                 children: [
//                   Expanded(child: _buildQuickAmount(5000)),
//                   const SizedBox(width: 8),
//                   Expanded(child: _buildQuickAmount(10000)),
//                   const SizedBox(width: 8),
//                   Expanded(child: _buildQuickAmount(20000)),
//                   const SizedBox(width: 8),
//                   Expanded(child: _buildQuickAmount(50000)),
//                 ],
//               ).animate().fadeIn(delay: 1200.ms),

//               const SizedBox(height: 24),

//               // Step 3: Note (Optional)
//               Text(
//                 'Step 3: Add Note (Optional)',
//                 style: AppTheme.heading4,
//               ).animate().fadeIn(delay: 1400.ms),

//               const SizedBox(height: 16),

//               // Note Input
//               TextFormField(
//                 controller: _noteController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Note',
//                   hintText: 'Add a note for this transfer...',
//                   prefixIcon: Icon(Icons.note),
//                 ),
//               ).animate().fadeIn(delay: 1600.ms),

//               if (_amount > 0) ...[
//                 const SizedBox(height: 24),

//                 // Transaction Preview
//                 Text(
//                   'Transaction Summary',
//                   style: AppTheme.heading4,
//                 ).animate().fadeIn(delay: 1800.ms),

//                 const SizedBox(height: 16),

//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: AppTheme.successColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: AppTheme.successColor.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildPreviewRow('Recipient', _recipientController.text),
//                       _buildPreviewRow('Amount', AppTheme.formatUGX(_amount)),
//                       _buildPreviewRow('Fee', 'FREE', color: AppTheme.successColor),
//                       const Divider(),
//                       _buildPreviewRow(
//                         'Total',
//                         AppTheme.formatUGX(_amount),
//                         isBold: true,
//                       ),
//                     ],
//                   ),
//                 ).animate().fadeIn(delay: 2000.ms),
//               ],

//               const SizedBox(height: 32),

//               // Transfer Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: (_isLoading || _amount <= 0) ? null : _handleTransfer,
//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text('Complete Transfer'),
//                 ),
//               ).animate().fadeIn(delay: 2200.ms),

//               const SizedBox(height: 16),

//               // Benefits Card
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppTheme.successColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.verified, color: AppTheme.successColor),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Free Transfers',
//                           style: AppTheme.bodyMedium.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: AppTheme.successColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'No fees charged for Bien to Bien transfers. Send money instantly to friends and family!',
//                       style: AppTheme.bodySmall.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 2400.ms),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickAmount(int amount) {
//     return OutlinedButton(
//       onPressed: () {
//         _amountController.text = amount.toString();
//         _calculateAmount();
//       },
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//       child: Text('${amount ~/ 1000}K'),
//     );
//   }

//   Widget _buildPreviewRow(String label, String value, {bool isBold = false, Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: AppTheme.bodyMedium.copyWith(
//               color: AppTheme.textSecondary,
//               fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: AppTheme.bodyMedium.copyWith(
//               color: color ?? AppTheme.textPrimary,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }