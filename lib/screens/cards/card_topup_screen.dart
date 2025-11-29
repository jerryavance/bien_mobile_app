// ==========================================
// FILE: lib/screens/cards/card_topup_screen.dart
// Card top-up with validation flow
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/card_provider.dart';
import '../../providers/wallet_provider.dart';

class CardTopUpScreen extends StatefulWidget {
  const CardTopUpScreen({super.key});

  @override
  State<CardTopUpScreen> createState() => _CardTopUpScreenState();
}

class _CardTopUpScreenState extends State<CardTopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _selectedSource = 'wallet';
  bool _showValidation = false;

  @override
  void dispose() {
    _amountController.dispose();
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
          'Top-Up Card',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer2<CardProvider, WalletProvider>(
        builder: (context, cardProvider, walletProvider, child) {
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

                  // Source Selection
                  _buildSourceSection(walletProvider),

                  const SizedBox(height: 24),

                  // Amount Input
                  _buildAmountSection(),

                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cardProvider.isProcessing
                          ? null
                          : () => _validateTopUp(cardProvider, cardId),
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
                'Balance',
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

  Widget _buildSourceSection(WalletProvider walletProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top-Up From',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Wallet Option
        _buildSourceOption(
          'Bien Wallet',
          'wallet',
          Icons.account_balance_wallet,
          'Balance: UGX ${_formatAmount(walletProvider.balance)}',
        ),

        const SizedBox(height: 8),

        // Mobile Money Option
        _buildSourceOption(
          'Mobile Money',
          'mobile',
          Icons.phone_android,
          'MTN, Airtel',
        ),
      ],
    );
  }

  Widget _buildSourceOption(String title, String value, IconData icon, String subtitle) {
    final isSelected = _selectedSource == value;
    
    return InkWell(
      onTap: () => setState(() => _selectedSource = value),
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

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return InkWell(
      onTap: () {
        _amountController.text = amount.replaceAll(',', '');
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Text(
          'UGX $amount',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
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
            'Confirm Top-Up',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
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
                _buildValidationRow('Card', 'Verve •••• ${card.last4Digits}'),
                _buildValidationRow('Amount', 'UGX ${_formatAmount(validation['amount'])}'),
                _buildValidationRow('Fee', 'UGX ${_formatAmount(validation['fee'] ?? 0)}'),
                const Divider(height: 32),
                _buildValidationRow(
                  'Total',
                  'UGX ${_formatAmount(validation['total_amount'])}',
                  isTotal: true,
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
                  : () => _completeTopUp(cardProvider, validation['validation_ref']),
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
                      'Confirm Top-Up',
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
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateTopUp(CardProvider cardProvider, String cardId) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    final validation = await cardProvider.validateCardTopUp(
      cardId: cardId,
      amount: amount,
      source: _selectedSource,
    );

    if (validation != null) {
      setState(() => _showValidation = true);
    }
  }

  Future<void> _completeTopUp(CardProvider cardProvider, String validationRef) async {
    final transaction = await cardProvider.completeCardTopUp(
      validationRef: validationRef,
    );

    if (!mounted) return;

    if (transaction != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Card top-up successful!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}