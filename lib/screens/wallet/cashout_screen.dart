// ==========================================
// FILE: lib/screens/wallet/cashout_screen.dart
// Real API integration for cash-out functionality
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/wallet_provider.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedMethod = 'mtn';
  String _selectedMethodName = 'MTN Mobile Money';
  double _amount = 0;
  double _charges = 0;
  bool _isLoading = false;
  bool _isLoadingMethods = true;
  
  List<Map<String, dynamic>> _availableMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoadingMethods = true);
    
    final walletProvider = context.read<WalletProvider>();
    final methods = await walletProvider.getCashOutMethods();
    
    setState(() {
      _isLoadingMethods = false;
      if (methods != null && methods.isNotEmpty) {
        _availableMethods = methods;
        final firstMethod = methods.first;
        _selectedMethod = firstMethod['method_id'] ?? 'mtn';
        _selectedMethodName = firstMethod['name'] ?? 'MTN Mobile Money';
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

      // Calculate charges (1% with min 500, max 2000)
      _charges = (_amount * 0.01).clamp(500, 2000);
    });
  }

  Future<void> _handleCashOut() async {
    if (!_formKey.currentState!.validate()) return;

    final walletProvider = context.read<WalletProvider>();
    final currentBalance = walletProvider.balance;
    
    // Check if user has sufficient balance
    if (_amount + _charges > currentBalance) {
      _showErrorDialog('Insufficient balance. You need ${AppTheme.formatUGX(_amount + _charges)} but only have ${AppTheme.formatUGX(currentBalance)}');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Clean destination (remove spaces, dashes)
      final cleanDestination = _destinationController.text.replaceAll(RegExp(r'[^\d]'), '');
      
      // Call cash-out API - pass method_id exactly as received
      final transaction = await walletProvider.cashOut(
        method: _selectedMethod,  // Use as-is, don't lowercase
        destination: cleanDestination,
        amount: _amount,
        note: 'Cash out to $_selectedMethodName',
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (transaction != null) {
          _showSuccessDialog(transaction.id, transaction.reference);
        } else {
          _showErrorDialog(
            walletProvider.errorMessage ?? 'Cash out failed. Please try again.',
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('An error occurred: $e');
      }
    }
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
        title: const Text('Cash Out Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your cash out of ${AppTheme.formatUGX(_amount)} has been processed successfully.',
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
        title: const Text('Cash Out Failed'),
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
        title: const Text('Cash Out'),
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

                    // Step 1: Select Destination
                    Text(
                      'Step 1: Select Destination',
                      style: AppTheme.heading4,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    if (_availableMethods.isEmpty)
                      Center(
                        child: Text(
                          'No cash-out methods available',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    else
                      ..._availableMethods.map((method) {
                        final isSelected = _selectedMethod == method['method_id'];
                        final isAvailable = method['available'] ?? true;
                        
                        return GestureDetector(
                          onTap: isAvailable
                              ? () {
                                  setState(() {
                                    _selectedMethod = method['method_id'];
                                    _selectedMethodName = method['name'];
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
                                  child: Text(
                                    method['name'] as String,
                                    style: AppTheme.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
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
                      }).toList(),

                    const SizedBox(height: 24),

                    // Step 2: Enter Details
                    Text(
                      'Step 2: Enter Cash Out Details',
                      style: AppTheme.heading4,
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 16),

                    // Destination Number
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
                        final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                        if (cleaned.length < 9) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 800.ms),

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
                        final amount = double.tryParse(
                          value.replaceAll(',', ''),
                        );
                        if (amount == null || amount < 1000) {
                          return 'Minimum cash out is UGX 1,000';
                        }
                        if (amount + _charges > currentBalance) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 1000.ms),

                    if (_amount > 0) ...[
                      const SizedBox(height: 24),

                      // Step 3: Preview
                      Text(
                        'Step 3: Transaction Preview',
                        style: AppTheme.heading4,
                      ).animate().fadeIn(delay: 1200.ms),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.warningColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPreviewRow('Method', _selectedMethodName),
                            _buildPreviewRow('Destination', _destinationController.text),
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
                      ).animate().fadeIn(delay: 1400.ms),
                    ],

                    const SizedBox(height: 32),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _amount <= 0) ? null : _handleCashOut,
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
                    ).animate().fadeIn(delay: 1600.ms),
                  ],
                ),
              ),
            ),
    );
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
}
















// // ==========================================
// // FILE: lib/screens/wallet/cashout_screen.dart
// // Real API integration for cash-out functionality
// // ==========================================
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import '../../core/design_system/app_theme.dart';
// import '../../providers/wallet_provider.dart';

// class CashOutScreen extends StatefulWidget {
//   const CashOutScreen({super.key});

//   @override
//   State<CashOutScreen> createState() => _CashOutScreenState();
// }

// class _CashOutScreenState extends State<CashOutScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _destinationController = TextEditingController();
//   final _amountController = TextEditingController();
  
//   String _selectedMethod = 'mtn';
//   String _selectedMethodName = 'MTN Mobile Money';
//   double _amount = 0;
//   double _charges = 0;
//   bool _isLoading = false;
//   bool _isLoadingMethods = true;
  
//   List<Map<String, dynamic>> _availableMethods = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadPaymentMethods();
//   }

//   @override
//   void dispose() {
//     _destinationController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadPaymentMethods() async {
//     setState(() => _isLoadingMethods = true);
    
//     final walletProvider = context.read<WalletProvider>();
//     final methods = await walletProvider.getCashOutMethods();
    
//     setState(() {
//       _isLoadingMethods = false;
//       if (methods != null && methods.isNotEmpty) {
//         _availableMethods = methods;
//         final firstMethod = methods.first;
//         _selectedMethod = firstMethod['method_id'] ?? 'mtn';
//         _selectedMethodName = firstMethod['name'] ?? 'MTN Mobile Money';
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

//       // Calculate charges (1% with min 500, max 2000)
//       _charges = (_amount * 0.01).clamp(500, 2000);
//     });
//   }

//   Future<void> _handleCashOut() async {
//     if (!_formKey.currentState!.validate()) return;

//     final walletProvider = context.read<WalletProvider>();
//     final currentBalance = walletProvider.balance;
    
//     // Check if user has sufficient balance
//     if (_amount + _charges > currentBalance) {
//       _showErrorDialog('Insufficient balance. You need ${AppTheme.formatUGX(_amount + _charges)} but only have ${AppTheme.formatUGX(currentBalance)}');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Clean destination (remove spaces, dashes)
//       final cleanDestination = _destinationController.text.replaceAll(RegExp(r'[^\d]'), '');
      
//       // Call cash-out API
//       final transaction = await walletProvider.cashOut(
//         method: _selectedMethod.toLowerCase(),
//         destination: cleanDestination,
//         amount: _amount,
//         note: 'Cash out to $_selectedMethodName',
//       );

//       setState(() => _isLoading = false);

//       if (mounted) {
//         if (transaction != null) {
//           _showSuccessDialog(transaction.id, transaction.reference);
//         } else {
//           _showErrorDialog(
//             walletProvider.errorMessage ?? 'Cash out failed. Please try again.',
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
//         title: const Text('Cash Out Successful'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Your cash out of ${AppTheme.formatUGX(_amount)} has been processed successfully.',
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
//         title: const Text('Cash Out Failed'),
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
//         title: const Text('Cash Out'),
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
//                     // Available Balance
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: AppTheme.goldGradient,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
//                           const SizedBox(width: 16),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Available Balance',
//                                 style: AppTheme.bodyMedium.copyWith(
//                                   color: Colors.white.withOpacity(0.9),
//                                 ),
//                               ),
//                               Text(
//                                 AppTheme.formatUGX(currentBalance),
//                                 style: AppTheme.heading3.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ).animate().fadeIn(duration: 600.ms),

//                     const SizedBox(height: 24),

//                     // Step 1: Select Destination
//                     Text(
//                       'Step 1: Select Destination',
//                       style: AppTheme.heading4,
//                     ).animate().fadeIn(delay: 200.ms),

//                     const SizedBox(height: 16),

//                     if (_availableMethods.isEmpty)
//                       Center(
//                         child: Text(
//                           'No cash-out methods available',
//                           style: AppTheme.bodyMedium.copyWith(
//                             color: AppTheme.textSecondary,
//                           ),
//                         ),
//                       )
//                     else
//                       ..._availableMethods.map((method) {
//                         final isSelected = _selectedMethod == method['method_id'];
//                         final isAvailable = method['available'] ?? true;
                        
//                         return GestureDetector(
//                           onTap: isAvailable
//                               ? () {
//                                   setState(() {
//                                     _selectedMethod = method['method_id'];
//                                     _selectedMethodName = method['name'];
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
//                                   child: Text(
//                                     method['name'] as String,
//                                     style: AppTheme.bodyLarge.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                       color: AppTheme.textPrimary,
//                                     ),
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
//                       'Step 2: Enter Cash Out Details',
//                       style: AppTheme.heading4,
//                     ).animate().fadeIn(delay: 600.ms),

//                     const SizedBox(height: 16),

//                     // Destination Number
//                     TextFormField(
//                       controller: _destinationController,
//                       keyboardType: TextInputType.phone,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number',
//                         hintText: '0700 123 456',
//                         prefixIcon: Icon(Icons.phone),
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
//                     ).animate().fadeIn(delay: 800.ms),

//                     const SizedBox(height: 16),

//                     // Amount Input
//                     TextFormField(
//                       controller: _amountController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Amount to Cash Out',
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
//                           return 'Minimum cash out is UGX 1,000';
//                         }
//                         if (amount + _charges > currentBalance) {
//                           return 'Insufficient balance';
//                         }
//                         return null;
//                       },
//                     ).animate().fadeIn(delay: 1000.ms),

//                     if (_amount > 0) ...[
//                       const SizedBox(height: 24),

//                       // Step 3: Preview
//                       Text(
//                         'Step 3: Transaction Preview',
//                         style: AppTheme.heading4,
//                       ).animate().fadeIn(delay: 1200.ms),

//                       const SizedBox(height: 16),

//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: AppTheme.warningColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: AppTheme.warningColor.withOpacity(0.3),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             _buildPreviewRow('Method', _selectedMethodName),
//                             _buildPreviewRow('Destination', _destinationController.text),
//                             _buildPreviewRow('Amount', AppTheme.formatUGX(_amount)),
//                             _buildPreviewRow('Charges', AppTheme.formatUGX(_charges)),
//                             const Divider(),
//                             _buildPreviewRow(
//                               'Total Deduction',
//                               AppTheme.formatUGX(_amount + _charges),
//                               isBold: true,
//                             ),
//                             _buildPreviewRow(
//                               'You Will Receive',
//                               AppTheme.formatUGX(_amount),
//                               isBold: true,
//                               color: AppTheme.successColor,
//                             ),
//                           ],
//                         ),
//                       ).animate().fadeIn(delay: 1400.ms),
//                     ],

//                     const SizedBox(height: 32),

//                     // Confirm Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: (_isLoading || _amount <= 0) ? null : _handleCashOut,
//                         child: _isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Confirm Cash Out'),
//                       ),
//                     ).animate().fadeIn(delay: 1600.ms),
//                   ],
//                 ),
//               ),
//             ),
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