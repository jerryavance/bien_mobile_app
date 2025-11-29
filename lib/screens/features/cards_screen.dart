// ==========================================
// FILE: lib/screens/features/cards_screen.dart
// Redesigned with Bien Verve card
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_theme.dart';
import '../../providers/card_provider.dart';
import '../../models/card_models.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hideCardDetails = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().fetchCards();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'My Cards',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddCardDialog,
            icon: Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cardProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    cardProvider.errorMessage!,
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cardProvider.fetchCards(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (cardProvider.cards.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Card Carousel
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: cardProvider.cards.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      cardProvider.selectCard(cardProvider.cards[index]);
                    },
                    itemBuilder: (context, index) {
                      return _buildBienCard(
                        cardProvider.cards[index],
                        index,
                      );
                    },
                  ),
                ),

                // Page Indicator
                if (cardProvider.cards.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        cardProvider.cards.length,
                        (index) => Container(
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Top-Up',
                          icon: Icons.add_circle_outline,
                          onTap: () => _handleTopUp(cardProvider.selectedCard),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Transfer',
                          icon: Icons.send_outlined,
                          onTap: () => _handleTransfer(cardProvider.selectedCard),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card Details Section
                if (cardProvider.selectedCard != null)
                  _buildCardDetailsSection(cardProvider.selectedCard!),

                const SizedBox(height: 24),

                // Card Settings Section
                if (cardProvider.selectedCard != null)
                  _buildCardSettingsSection(cardProvider.selectedCard!),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBienCard(CardModel card, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Card Background Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/bien-card.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          // Card Content Overlay
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Logo and Hide/Show Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bien Logo
                    Container(
                      height: 32,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'BIEN',
                          style: AppTheme.heading4.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Hide/Show Toggle
                    IconButton(
                      onPressed: () {
                        setState(() => _hideCardDetails = !_hideCardDetails);
                      },
                      icon: Icon(
                        _hideCardDetails ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Card Number
                Text(
                  _hideCardDetails 
                      ? card.maskedCardNumber 
                      : _formatCardNumber(card.cardNumber),
                  style: AppTheme.heading4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 20),

                // Bottom Row: Cardholder, Expiry, CVV
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cardholder Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARDHOLDER',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.cardholderName.toUpperCase(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Expiry
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPIRES',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.expiryDate,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // CVV
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hideCardDetails ? '***' : card.cvv,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Verve Logo (Bottom Right)
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VERVE',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 300.ms);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsSection(CardModel card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildCopyableDetailRow(
            'Card Number',
            _hideCardDetails ? card.maskedCardNumber : card.cardNumber,
            card.cardNumber,
          ),
          _buildCopyableDetailRow('Cardholder', card.cardholderName, card.cardholderName),
          _buildCopyableDetailRow('Expiry Date', card.expiryDate, card.expiryDate),
          _buildCopyableDetailRow(
            'CVV',
            _hideCardDetails ? '***' : card.cvv,
            card.cvv,
          ),
          _buildDetailRow('Card Type', 'Verve Debit Card'),
          _buildDetailRow('Status', _getStatusText(card.status)),
          _buildDetailRow(
            'Balance',
            '${card.currency} ${_formatAmount(card.balance)}',
            isBalance: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableDetailRow(String label, String displayValue, String copyValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                displayValue,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _copyToClipboard(copyValue, label),
                child: Icon(
                  Icons.copy,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBalance = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: isBalance ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSettingsSection(CardModel card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Settings',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingToggle(
            'Freeze Card',
            'Temporarily disable all transactions',
            card.isFrozen,
            (value) => _handleFreezeToggle(card, value),
            icon: Icons.ac_unit,
          ),

          const Divider(height: 32),

          _buildSettingToggle(
            'Block Card',
            'Permanently disable this card',
            card.isBlocked,
            (value) => _handleBlockToggle(card, value),
            icon: Icons.block,
            isDangerous: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    required IconData icon,
    bool isDangerous = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDangerous 
                ? AppTheme.errorColor.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDangerous ? AppTheme.errorColor : AppTheme.primaryColor,
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDangerous ? AppTheme.errorColor : AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Cards Yet',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first Bien Verve card to get started',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length != 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} ${cardNumber.substring(4, 8)} ${cardNumber.substring(8, 12)} ${cardNumber.substring(12)}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getStatusText(CardStatus status) {
    switch (status) {
      case CardStatus.active:
        return '🟢 Active';
      case CardStatus.frozen:
        return '🔵 Frozen';
      case CardStatus.blocked:
        return '🔴 Blocked';
      case CardStatus.expired:
        return '⚫ Expired';
    }
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTopUp(CardModel? card) {
    if (card == null) return;
    Navigator.pushNamed(
      context,
      '/card-topup',
      arguments: {'cardId': card.id},
    );
  }

  void _handleTransfer(CardModel? card) {
    if (card == null) return;
    Navigator.pushNamed(
      context,
      '/card-transfer',
      arguments: {'cardId': card.id},
    );
  }

  Future<void> _handleFreezeToggle(CardModel card, bool freeze) async {
    final cardProvider = context.read<CardProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(freeze ? 'Freeze Card?' : 'Unfreeze Card?'),
        content: Text(
          freeze
              ? 'This will temporarily disable all transactions on this card.'
              : 'This will reactivate your card for transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: freeze ? AppTheme.warningColor : AppTheme.primaryColor,
            ),
            child: Text(freeze ? 'Freeze' : 'Unfreeze'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = freeze
          ? await cardProvider.freezeCard(card.id)
          : await cardProvider.unfreezeCard(card.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(freeze ? 'Card frozen successfully' : 'Card unfrozen successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cardProvider.errorMessage ?? 'Operation failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleBlockToggle(CardModel card, bool block) async {
    if (!block) return; // Can't unblock a blocked card

    final cardProvider = context.read<CardProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Card?'),
        content: const Text(
          'This will permanently disable this card. This action cannot be undone. '
          'You will need to request a new card.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Block Card'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await cardProvider.blockCard(card.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card blocked successfully'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cardProvider.errorMessage ?? 'Failed to block card'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request New Card'),
        content: const Text(
          'To request a new Bien Verve card, please contact our customer support '
          'or visit your nearest Bien office.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help-support');
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}