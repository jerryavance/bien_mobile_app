// ==========================================
// FILE: lib/screens/cards/card_transfer_screen.dart
// Transfer money from card to wallet/bank/mobile
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/card_provider.dart';

class CardTransferScreen extends StatefulWidget {
  const CardTransferScreen({super.key});

  @override
  State<CardTransferScreen> createState() => _CardTransferScreenState();
}

class _CardTransferScreenState extends State<CardTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();
  
  String _selectedDestinationType = 'wallet';
  bool _showValidation = false;

  final Map<String, Map<String, dynamic>> _destinationTypes = {
    'wallet': {
      'title': 'Bien Wallet',
      'icon': Icons.account_balance_wallet,
      'subtitle': 'Transfer to your Bien wallet',
      'placeholder': 'Wallet ID (optional)',
      'hint': 'Leave empty to use your default wallet',
    },
    'bank': {
      'title': 'Bank Account',
      'icon': Icons.account_balance,
      'subtitle': 'Transfer to any bank account',
      'placeholder': 'Enter bank account number',
      'hint': 'Enter the account number',
    },
    'mobile': {
      'title': 'Mobile Money',
      'icon': Icons.phone_android,
      'subtitle': 'MTN, Airtel mobile money',
      'placeholder': 'Enter phone number',
      'hint': 'Format: 256XXXXXXXXX',
    },
  };

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final cardId = args['cardId'] as String;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Transfer from Card',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          final card = cardProvider.cards.firstWhere((c) => c.id == cardId);

          if (_showValidation && cardProvider.validationData != null) {
            return _buildValidationView(cardProvider, card);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Info
                  _buildCardInfo(card),
                  
                  const SizedBox(height: 24),

                  // Destination Type Selection
                  _buildDestinationTypeSection(),

                  const SizedBox(height: 24),

                  // Destination Input
                  _buildDestinationInput(),

                  const SizedBox(height: 24),

                  // Amount Input
                  _buildAmountSection(card),

                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cardProvider.isProcessing
                          ? null
                          : () => _validateTransfer(cardProvider, cardId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: cardProvider.isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Continue',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  if (cardProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppTheme.errorColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cardProvider.errorMessage!,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardInfo(card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.credit_card,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.cardholderName,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verve •••• ${card.last4Digits}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Available',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${card.currency} ${_formatAmount(card.balance)}',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer To',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Destination type options
        ..._destinationTypes.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildDestinationOption(
              entry.value['title'],
              entry.key,
              entry.value['icon'],
              entry.value['subtitle'],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDestinationOption(String title, String value, IconData icon, String subtitle) {
    final isSelected = _selectedDestinationType == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDestinationType = value;
          _destinationController.clear();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1) 
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationInput() {
    final destinationInfo = _destinationTypes[_selectedDestinationType]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destination Details',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        TextFormField(
          controller: _destinationController,
          keyboardType: _selectedDestinationType == 'mobile' 
              ? TextInputType.phone 
              : TextInputType.text,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: destinationInfo['placeholder'],
            helperText: destinationInfo['hint'],
            helperStyle: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (_selectedDestinationType == 'wallet') {
              // Wallet is optional
              return null;
            }
            
            if (value == null || value.isEmpty) {
              return 'Please enter ${destinationInfo['placeholder']}';
            }
            
            if (_selectedDestinationType == 'mobile') {
              if (!RegExp(r'^256\d{9}$').hasMatch(value)) {
                return 'Invalid phone number format';
              }
            }
            
            if (_selectedDestinationType == 'bank') {
              if (value.length < 10) {
                return 'Account number too short';
              }
            }
            
            return null;
          },
        ),

        // Bank selector for bank transfers
        if (_selectedDestinationType == 'bank') ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Bank',
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            items: [
              'Stanbic Bank',
              'Centenary Bank',
              'Bank of Africa',
              'DFCU Bank',
              'Equity Bank',
              'Standard Chartered',
            ].map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(bank),
              );
            }).toList(),
            onChanged: (value) {
              // Store selected bank
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a bank';
              }
              return null;
            },
          ),
        ],

        // Mobile network selector
        if (_selectedDestinationType == 'mobile') ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Network',
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            items: [
              'MTN Mobile Money',
              'Airtel Money',
            ].map((network) {
              return DropdownMenuItem(
                value: network,
                child: Text(network),
              );
            }).toList(),
            onChanged: (value) {
              // Store selected network
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a network';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAmountSection(card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amount',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Available: ${card.currency} ${_formatAmount(card.balance)}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixText: 'UGX ',
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount > card.balance) {
              return 'Insufficient balance';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        // Quick Amount Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickAmountButton('5,000'),
            _buildQuickAmountButton('10,000'),
            _buildQuickAmountButton('20,000'),
            _buildQuickAmountButton('50,000'),
            _buildQuickAmountButton('All', isAll: true, balance: card.balance),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String amount, {bool isAll = false, double? balance}) {
    return InkWell(
      onTap: () {
        if (isAll && balance != null) {
          _amountController.text = balance.toStringAsFixed(0);
        } else {
          _amountController.text = amount.replaceAll(',', '');
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isAll ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAll ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          isAll ? amount : 'UGX $amount',
          style: AppTheme.bodyMedium.copyWith(
            color: isAll ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isAll ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildValidationView(CardProvider cardProvider, card) {
    final validation = cardProvider.validationData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Confirm Transfer',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          
          Text(
            'Review transfer details carefully',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                _buildValidationRow('From', 'Verve •••• ${card.last4Digits}'),
                _buildValidationRow(
                  'To',
                  _getDestinationDisplay(),
                ),
                const Divider(height: 32),
                _buildValidationRow('Amount', 'UGX ${_formatAmount(validation['amount'])}'),
                _buildValidationRow('Fee', 'UGX ${_formatAmount(validation['fee'] ?? 0)}'),
                const Divider(height: 32),
                _buildValidationRow(
                  'Total Debit',
                  'UGX ${_formatAmount(validation['total_amount'])}',
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Warning message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please ensure the destination details are correct. This action cannot be undone.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cardProvider.isProcessing
                  ? null
                  : () => _completeTransfer(cardProvider, validation['validation_ref']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: cardProvider.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Confirm Transfer',
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              setState(() => _showValidation = false);
              cardProvider.clearValidationData();
            },
            child: Text(
              'Cancel',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTheme.bodyLarge.copyWith(
                color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateTransfer(CardProvider cardProvider, String cardId) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final destination = _selectedDestinationType == 'wallet' 
        ? (_destinationController.text.isEmpty ? 'default' : _destinationController.text)
        : _destinationController.text;

    final validation = await cardProvider.validateCardTransfer(
      cardId: cardId,
      amount: amount,
      destination: destination,
      destinationType: _selectedDestinationType,
    );

    if (validation != null) {
      setState(() => _showValidation = true);
    }
  }

  Future<void> _completeTransfer(CardProvider cardProvider, String validationRef) async {
    final transaction = await cardProvider.completeCardTransfer(
      validationRef: validationRef,
      note: 'Transfer from card to ${_destinationTypes[_selectedDestinationType]!['title']}',
    );

    if (!mounted) return;

    if (transaction != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transfer completed successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  String _getDestinationDisplay() {
    final destination = _destinationController.text;
    final type = _destinationTypes[_selectedDestinationType]!;
    
    if (_selectedDestinationType == 'wallet') {
      return destination.isEmpty ? 'My Bien Wallet' : destination;
    }
    
    return '$destination (${type['title']})';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}