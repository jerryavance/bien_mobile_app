// ==========================================
// FILE: lib/screens/bills/bill_payment_screen.dart
// Dynamic bill payment form with validation flow
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../models/bill_models.dart';
import '../../providers/bill_provider.dart';
import '../../providers/wallet_provider.dart';

class BillPaymentScreen extends StatefulWidget {
  final BillCategory category;
  final Biller biller;

  const BillPaymentScreen({
    super.key,
    required this.category,
    required this.biller,
  });

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _fieldValues = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each field
    for (var field in widget.biller.fields) {
      _controllers[field.fieldName] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Step 1: Validate transaction
  Future<void> _handleValidation() async {
    if (!_formKey.currentState!.validate()) return;

    // Extract required values
    final billerId = widget.biller.billId;
    String? itemId;
    String? customerId;
    double? amount;
    String? phoneNumber;

    for (var field in widget.biller.fields) {
      final value = field.isDropdown
          ? _fieldValues[field.fieldName]
          : _controllers[field.fieldName]!.text;

      switch (field.fieldName.toLowerCase()) {
        case 'itemid':
          itemId = value as String?;
          break;
        case 'customerid':
          customerId = value as String?;
          break;
        case 'amount':
          amount = double.tryParse(value.toString());
          break;
        case 'phonenumber':
          phoneNumber = value as String?;
          break;
      }
    }

    // Validate required fields
    if (itemId == null || customerId == null || amount == null || phoneNumber == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final currentBalance = walletProvider.balance;

    if (amount > currentBalance) {
      _showErrorDialog(
        'Insufficient balance. You need ${AppTheme.formatUGX(amount)} but only have ${AppTheme.formatUGX(currentBalance)}',
      );
      return;
    }

    setState(() => _isLoading = true);

    final billProvider = context.read<BillProvider>();
    final validation = await billProvider.validateBillPayment(
      billerId: billerId,
      itemId: itemId,
      customerId: customerId,
      amount: amount,
      phoneNumber: phoneNumber,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (validation != null) {
        _showValidationDialog(validation);
      } else {
        _showErrorDialog(
          billProvider.errorMessage ?? 'Validation failed. Please try again.',
        );
      }
    }
  }

  // Show validation confirmation dialog
  void _showValidationDialog(BillValidationResponse validation) {
    final charges = validation.charges;
    final chargeAmount = (charges?['charge'] ?? 0).toDouble();
    final taxAmount = (charges?['tax'] ?? 0).toDouble();
    final totalCharges = (charges?['total'] ?? 0).toDouble();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            const Text('Confirm Payment'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please confirm the payment details:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildValidationRow('Biller', validation.biller),
              _buildValidationRow('Customer ID', validation.customerId),
              _buildValidationRow('Customer Name', validation.customerName),
              _buildValidationRow('Payment Item', validation.paymentItem),
              const Divider(height: 24),
              _buildValidationRow('Amount', 'UGX ${AppTheme.formatUGX(validation.amount)}'),
              if (chargeAmount > 0)
                _buildValidationRow('Service Charge', 'UGX ${AppTheme.formatUGX(chargeAmount)}'),
              if (taxAmount > 0)
                _buildValidationRow('Tax', 'UGX ${AppTheme.formatUGX(taxAmount)}'),
              const Divider(height: 24),
              _buildValidationRow(
                'Total Amount',
                'UGX ${AppTheme.formatUGX(validation.totalAmount)}',
                isBold: true,
                color: AppTheme.errorColor,
              ),
              if (validation.balanceNarration != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          validation.balanceNarration!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.infoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BillProvider>().clearValidationData();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePayment(validation.retrievalReference);
            },
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }

  // Step 2: Complete payment
  Future<void> _handlePayment(String retrievalReference) async {
    setState(() => _isLoading = true);

    final billProvider = context.read<BillProvider>();
    final payment = await billProvider.completeBillPayment(
      retrievalReference: retrievalReference,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (payment != null) {
        // Refresh wallet balance
        await context.read<WalletProvider>().fetchWallet();
        _showSuccessDialog(payment);
      } else {
        _showErrorDialog(
          billProvider.errorMessage ?? 'Payment failed. Please try again.',
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

  void _showSuccessDialog(BillPaymentResponse payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: 64,
        ),
        title: const Text('Payment Successful'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your payment of ${AppTheme.formatUGX(payment.amount)} has been processed successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    if (payment.token != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Token:', style: AppTheme.bodySmall),
                          Flexible(
                            child: Text(
                              payment.token!,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (payment.units != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Units:', style: AppTheme.bodySmall),
                          Text(
                            '${payment.units} kWh',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reference:', style: AppTheme.bodySmall),
                        Flexible(
                          child: Text(
                            payment.transactionReference,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
        title: const Text('Payment Failed'),
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

    // Sort fields by priority
    final sortedFields = List<BillField>.from(widget.biller.fields)
      ..sort((a, b) => a.fieldPriority.compareTo(b.fieldPriority));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.biller.billName),
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
              // Balance Card
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
                        'Fill in the required details to pay your ${widget.biller.billName} bill',
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
                'Payment Details',
                style: AppTheme.heading4,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              // Dynamic form fields
              ...sortedFields.asMap().entries.map((entry) {
                final index = entry.key;
                final field = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFormField(field, index),
                );
              }).toList(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleValidation,
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
              ).animate().fadeIn(delay: Duration(milliseconds: 600 + sortedFields.length * 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(BillField field, int index) {
    if (field.isDropdown) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: field.fieldDescription,
          prefixIcon: const Icon(Icons.arrow_drop_down_circle),
        ),
        value: _fieldValues[field.fieldName] as String?,
        items: field.values.map((value) {
          return DropdownMenuItem<String>(
            value: value.value,
            child: Text(value.valueDescription),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _fieldValues[field.fieldName] = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select ${field.fieldDescription.toLowerCase()}';
          }
          return null;
        },
      ).animate().fadeIn(
        delay: Duration(milliseconds: 600 + index * 100),
      );
    }

    return TextFormField(
      controller: _controllers[field.fieldName],
      keyboardType: field.isNumber || field.isPhone
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: field.fieldDescription,
        prefixIcon: Icon(_getFieldIcon(field)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter ${field.fieldDescription.toLowerCase()}';
        }
        if (field.fieldName.toLowerCase() == 'amount') {
          final amount = double.tryParse(value);
          if (amount == null || amount <= 0) {
            return 'Please enter a valid amount';
          }
        }
        return null;
      },
    ).animate().fadeIn(
      delay: Duration(milliseconds: 600 + index * 100),
    );
  }

  IconData _getFieldIcon(BillField field) {
    final name = field.fieldName.toLowerCase();
    if (name.contains('amount')) return Icons.money;
    if (name.contains('phone')) return Icons.phone;
    if (name.contains('customer')) return Icons.person;
    if (name.contains('meter')) return Icons.electric_meter;
    if (name.contains('account')) return Icons.account_circle;
    return Icons.edit;
  }
}