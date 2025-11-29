// ==========================================
// FILE: lib/screens/wallet/topup_screen.dart
// UPDATED: Two-step flow with validation confirmation
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/wallet_provider.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedSource = 'mtn';
  String _selectedSourceName = 'MTN Mobile Money';
  double _amount = 0;
  double _charges = 0;
  bool _isLoading = false;
  bool _isLoadingMethods = true;
  
  Map<String, dynamic>? _validationData;
  List<Map<String, dynamic>> _availableMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoadingMethods = true);
    
    final walletProvider = context.read<WalletProvider>();
    final methods = await walletProvider.getTopUpMethods();
    
    setState(() {
      _isLoadingMethods = false;
      if (methods != null && methods.isNotEmpty) {
        _availableMethods = methods;
        final firstMethod = methods.first;
        _selectedSource = firstMethod['method_id'] ?? 'mtn';
        _selectedSourceName = firstMethod['name'] ?? 'MTN Mobile Money';
      }
    });
  }

  void _calculateCharges() {
    setState(() {
      _amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      
      if (_amount <= 0) {
        _charges = 0;
        return;
      }

      _charges = (_amount * 0.01).clamp(500, 2000);
    });
  }

  // Step 1: Validate transaction
  Future<void> _handleValidation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final walletProvider = context.read<WalletProvider>();
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    final validationData = await walletProvider.validateTopUp(
      source: _selectedSource,
      phoneNumber: cleanPhone,
      amount: _amount,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (validationData != null) {
        // Show validation dialog
        _showValidationDialog(validationData);
      } else {
        _showErrorDialog(
          walletProvider.errorMessage ?? 'Validation failed. Please try again.',
        );
      }
    }
  }

  // Show validation data to user for confirmation
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
            Icon(Icons.info_outline, color: AppTheme.infoColor),
            const SizedBox(width: 12),
            const Text('Confirm Transaction'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please confirm the transaction details:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildValidationRow('Recipient', recipientName),
              if (accountName.isNotEmpty)
                _buildValidationRow('Account', accountName),
              _buildValidationRow('Phone Number', _phoneController.text),
              _buildValidationRow('Source', _selectedSourceName),
              const Divider(height: 24),
              _buildValidationRow('Amount', '$currency ${AppTheme.formatUGX(_amount)}'),
              _buildValidationRow('Charge', '$currency ${AppTheme.formatUGX(chargeAmount)}'),
              _buildValidationRow('Tax', '$currency ${AppTheme.formatUGX(taxAmount)}'),
              const Divider(height: 24),
              _buildValidationRow(
                'Total',
                '$currency ${AppTheme.formatUGX(_amount + totalCharges)}',
                isBold: true,
              ),
              _buildValidationRow(
                'You will receive',
                '$currency ${AppTheme.formatUGX(_amount - totalCharges)}',
                isBold: true,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppTheme.warningColor, size: 20),
                    const SizedBox(width: 8),
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
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }

  // Step 2: Complete payment after user confirms
  Future<void> _handlePayment(String validationRef) async {
    setState(() => _isLoading = true);

    final walletProvider = context.read<WalletProvider>();
    
    final transaction = await walletProvider.completeTopUp(
      validationRef: validationRef,
      source: _selectedSource,
      note: 'Top-up from $_selectedSourceName',
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (transaction != null) {
        _showSuccessDialog(transaction.id, transaction.reference);
      } else {
        _showErrorDialog(
          walletProvider.errorMessage ?? 'Payment failed. Please try again.',
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
        title: const Text('Top-Up Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your top-up of ${AppTheme.formatUGX(_amount)} has been initiated successfully.',
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
        title: const Text('Transaction Failed'),
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
        title: const Text('Top Up Wallet'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: _isLoadingMethods
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            AppTheme.formatUGX(currentBalance),
                            style: AppTheme.heading1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    Text(
                      'Step 1: Select Source of Funds',
                      style: AppTheme.heading4,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    if (_availableMethods.isEmpty)
                      Center(
                        child: Text(
                          'No payment methods available',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    else
                      ..._availableMethods.map((method) {
                        final isSelected = _selectedSource == method['method_id'];
                        final isAvailable = method['available'] ?? true;
                        
                        return GestureDetector(
                          onTap: isAvailable
                              ? () {
                                  setState(() {
                                    _selectedSource = method['method_id'];
                                    _selectedSourceName = method['name'];
                                  });
                                  _calculateCharges();
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.primaryColor
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
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.phone_android,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method['name'] as String,
                                        style: AppTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (!isAvailable)
                                        Text(
                                          'Currently unavailable',
                                          style: AppTheme.caption.copyWith(
                                            color: AppTheme.errorColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                          delay: Duration(
                            milliseconds: 400 + _availableMethods.indexOf(method) * 100,
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    Text(
                      'Step 2: Enter Top-Up Details',
                      style: AppTheme.heading4,
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 16),

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
                        final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                        if (cleaned.length < 9) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 1000.ms),

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
                      onChanged: (value) => _calculateCharges(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(
                          value.replaceAll(',', ''),
                        );
                        if (amount == null || amount < 1000) {
                          return 'Minimum top-up is UGX 1,000';
                        }
                        
                        final method = _availableMethods.firstWhere(
                          (m) => m['method_id'] == _selectedSource,
                          orElse: () => {},
                        );
                        
                        if (method.isNotEmpty && method['limits'] != null) {
                          final limits = method['limits'] as Map<String, dynamic>;
                          final maxAmount = limits['max_amount'] as int?;
                          if (maxAmount != null && amount > maxAmount) {
                            return 'Maximum amount is UGX ${AppTheme.formatUGX(maxAmount.toDouble())}';
                          }
                        }
                        
                        return null;
                      },
                    ).animate().fadeIn(delay: 1200.ms),

                    const SizedBox(height: 16),

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
                    ).animate().fadeIn(delay: 2000.ms),

                    const SizedBox(height: 16),

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
                              'Transaction details will be shown for confirmation before processing.',
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
}














// // ==========================================
// // FILE: lib/screens/wallet/topup_screen.dart
// // Real API integration for top-up functionality
// // ==========================================
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import '../../core/design_system/app_theme.dart';
// import '../../providers/wallet_provider.dart';

// class TopUpScreen extends StatefulWidget {
//   const TopUpScreen({super.key});

//   @override
//   State<TopUpScreen> createState() => _TopUpScreenState();
// }

// class _TopUpScreenState extends State<TopUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _amountController = TextEditingController();
  
//   String _selectedSource = 'mtn';  // Default to 'mtn' not 'MTN'
//   String _selectedSourceName = 'MTN Mobile Money';
//   double _amount = 0;
//   double _charges = 0;
//   bool _isLoading = false;
//   bool _isLoadingMethods = true;
  
//   Map<String, dynamic>? _validationData;
//   List<Map<String, dynamic>> _availableMethods = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadPaymentMethods();
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadPaymentMethods() async {
//     setState(() => _isLoadingMethods = true);
    
//     final walletProvider = context.read<WalletProvider>();
//     final methods = await walletProvider.getTopUpMethods();
    
//     setState(() {
//       _isLoadingMethods = false;
//       if (methods != null && methods.isNotEmpty) {
//         _availableMethods = methods;
//         // Set default to first available method
//         final firstMethod = methods.first;
//         _selectedSource = firstMethod['method_id'] ?? 'mtn';
//         _selectedSourceName = firstMethod['name'] ?? 'MTN Mobile Money';
//       }
//     });
//   }

//   void _calculateCharges() {
//     setState(() {
//       _amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      
//       if (_amount <= 0) {
//         _charges = 0;
//         return;
//       }

//       // Get limits from selected method
//       final method = _availableMethods.firstWhere(
//         (m) => m['method_id'] == _selectedSource,
//         orElse: () => {},
//       );
      
//       // Simple charge calculation (1% with min 500, max 2000)
//       _charges = (_amount * 0.01).clamp(500, 2000);
//     });
//   }

//   Future<void> _handleTopUp() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final walletProvider = context.read<WalletProvider>();
    
//     try {
//       // Clean phone number (remove spaces, dashes)
//       final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      
//       // Call top-up API - pass method_id exactly as received from backend
//       final transaction = await walletProvider.topUp(
//         source: _selectedSource,  // This should be 'mtn' or 'airtel', not lowercase conversion
//         phoneNumber: cleanPhone,
//         amount: _amount,
//       );

//       setState(() => _isLoading = false);

//       if (mounted) {
//         if (transaction != null) {
//           // Success
//           _showSuccessDialog(transaction.id, transaction.reference);
//         } else {
//           // Error
//           _showErrorDialog(
//             walletProvider.errorMessage ?? 'Top-up failed. Please try again.',
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
//         title: const Text('Top-Up Initiated'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Please check your phone for a prompt to authorize this transaction of ${AppTheme.formatUGX(_amount)}',
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
//               Navigator.pop(context); // Close dialog
//               Navigator.pop(context); // Go back to previous screen
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
//         title: const Text('Top-Up Failed'),
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
//         title: const Text('Top Up Wallet'),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back_ios),
//         ),
//       ),
//       body: _isLoadingMethods
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Current Balance Card
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: AppTheme.primaryGradient,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppTheme.primaryColor.withOpacity(0.3),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Balance',
//                             style: AppTheme.bodyMedium.copyWith(
//                               color: Colors.white.withOpacity(0.9),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             AppTheme.formatUGX(currentBalance),
//                             style: AppTheme.heading1.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

//                     const SizedBox(height: 24),

//                     // Step 1: Select Source
//                     Text(
//                       'Step 1: Select Source of Funds',
//                       style: AppTheme.heading4,
//                     ).animate().fadeIn(delay: 200.ms),

//                     const SizedBox(height: 16),

//                     if (_availableMethods.isEmpty)
//                       Center(
//                         child: Text(
//                           'No payment methods available',
//                           style: AppTheme.bodyMedium.copyWith(
//                             color: AppTheme.textSecondary,
//                           ),
//                         ),
//                       )
//                     else
//                       ..._availableMethods.map((method) {
//                         final isSelected = _selectedSource == method['method_id'];
//                         final isAvailable = method['available'] ?? true;
                        
//                         return GestureDetector(
//                           onTap: isAvailable
//                               ? () {
//                                   setState(() {
//                                     _selectedSource = method['method_id'];
//                                     _selectedSourceName = method['name'];
//                                   });
//                                   _calculateCharges();
//                                 }
//                               : null,
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: isSelected 
//                                   ? AppTheme.primaryColor.withOpacity(0.1)
//                                   : AppTheme.surfaceColor,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: isSelected 
//                                     ? AppTheme.primaryColor
//                                     : AppTheme.borderColor,
//                                 width: isSelected ? 2 : 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 48,
//                                   height: 48,
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.primaryColor.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Icon(
//                                     Icons.phone_android,
//                                     color: AppTheme.primaryColor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         method['name'] as String,
//                                         style: AppTheme.bodyLarge.copyWith(
//                                           fontWeight: FontWeight.w600,
//                                           color: AppTheme.textPrimary,
//                                         ),
//                                       ),
//                                       if (!isAvailable)
//                                         Text(
//                                           'Currently unavailable',
//                                           style: AppTheme.caption.copyWith(
//                                             color: AppTheme.errorColor,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (isSelected)
//                                   Icon(
//                                     Icons.check_circle,
//                                     color: AppTheme.primaryColor,
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ).animate().fadeIn(
//                           delay: Duration(
//                             milliseconds: 400 + _availableMethods.indexOf(method) * 100,
//                           ),
//                         );
//                       }).toList(),

//                     const SizedBox(height: 24),

//                     // Step 2: Enter Details
//                     Text(
//                       'Step 2: Enter Top-Up Details',
//                       style: AppTheme.heading4,
//                     ).animate().fadeIn(delay: 800.ms),

//                     const SizedBox(height: 16),

//                     // Phone Number Input
//                     TextFormField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                         labelText: 'Phone Number',
//                         hintText: '0700 123 456',
//                         prefixIcon: const Icon(Icons.phone),
//                         helperText: 'Enter the number to collect funds from',
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter phone number';
//                         }
//                         final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
//                         if (cleaned.length < 9) {
//                           return 'Please enter a valid phone number';
//                         }
//                         return null;
//                       },
//                     ).animate().fadeIn(delay: 1000.ms),

//                     const SizedBox(height: 16),

//                     // Amount Input
//                     TextFormField(
//                       controller: _amountController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Amount',
//                         hintText: '10,000',
//                         prefixText: 'UGX ',
//                         prefixIcon: Icon(Icons.money),
//                       ),
//                       onChanged: (value) => _calculateCharges(),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter amount';
//                         }
//                         final amount = double.tryParse(
//                           value.replaceAll(',', ''),
//                         );
//                         if (amount == null || amount < 1000) {
//                           return 'Minimum top-up is UGX 1,000';
//                         }
                        
//                         // Check against method limits
//                         final method = _availableMethods.firstWhere(
//                           (m) => m['method_id'] == _selectedSource,
//                           orElse: () => {},
//                         );
                        
//                         if (method.isNotEmpty && method['limits'] != null) {
//                           final limits = method['limits'] as Map<String, dynamic>;
//                           final maxAmount = limits['max_amount'] as int?;
//                           if (maxAmount != null && amount > maxAmount) {
//                             return 'Maximum amount is UGX ${AppTheme.formatUGX(maxAmount.toDouble())}';
//                           }
//                         }
                        
//                         return null;
//                       },
//                     ).animate().fadeIn(delay: 1200.ms),

//                     const SizedBox(height: 16),

//                     // Quick Amount Buttons
//                     Row(
//                       children: [
//                         Expanded(child: _buildQuickAmount(10000)),
//                         const SizedBox(width: 8),
//                         Expanded(child: _buildQuickAmount(20000)),
//                         const SizedBox(width: 8),
//                         Expanded(child: _buildQuickAmount(50000)),
//                         const SizedBox(width: 8),
//                         Expanded(child: _buildQuickAmount(100000)),
//                       ],
//                     ).animate().fadeIn(delay: 1400.ms),

//                     if (_amount > 0) ...[
//                       const SizedBox(height: 24),

//                       // Step 3: Transaction Preview
//                       Text(
//                         'Step 3: Transaction Preview',
//                         style: AppTheme.heading4,
//                       ).animate().fadeIn(delay: 1600.ms),

//                       const SizedBox(height: 16),

//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: AppTheme.successColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: AppTheme.successColor.withOpacity(0.3),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             _buildPreviewRow('Source', _selectedSourceName),
//                             _buildPreviewRow('From Number', _phoneController.text),
//                             _buildPreviewRow('Amount', AppTheme.formatUGX(_amount)),
//                             _buildPreviewRow('Charges', AppTheme.formatUGX(_charges)),
//                             const Divider(),
//                             _buildPreviewRow(
//                               'Total to Receive',
//                               AppTheme.formatUGX(_amount - _charges),
//                               isBold: true,
//                             ),
//                           ],
//                         ),
//                       ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0),
//                     ],

//                     const SizedBox(height: 32),

//                     // Confirm Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: (_isLoading || _amount <= 0) ? null : _handleTopUp,
//                         child: _isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Proceed to Top Up'),
//                       ),
//                     ).animate().fadeIn(delay: 2000.ms),

//                     const SizedBox(height: 16),

//                     // Info Card
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppTheme.infoColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, color: AppTheme.infoColor),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'You will receive a prompt on your phone to authorize this transaction.',
//                               style: AppTheme.bodySmall.copyWith(
//                                 color: AppTheme.textSecondary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ).animate().fadeIn(delay: 2200.ms),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildQuickAmount(int amount) {
//     return OutlinedButton(
//       onPressed: () {
//         _amountController.text = amount.toString();
//         _calculateCharges();
//       },
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//       child: Text('${amount ~/ 1000}K'),
//     );
//   }

//   Widget _buildPreviewRow(String label, String value, {bool isBold = false}) {
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
//               color: AppTheme.textPrimary,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }