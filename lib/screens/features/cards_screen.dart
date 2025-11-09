import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _selectedCardIndex = 0;

  final List<Map<String, dynamic>> _cards = [
    {
      'name': 'Visa Platinum',
      'number': '**** **** **** 1234',
      'expiry': '12/25',
      'cvv': '123',
      'balance': '\$2,450.00',
      'color': Colors.blue,
      'type': 'Credit',
      'limit': '\$5,000',
      'used': '\$2,550',
    },
    {
      'name': 'Mastercard Gold',
      'number': '**** **** **** 5678',
      'expiry': '09/26',
      'cvv': '456',
      'balance': '\$1,890.00',
      'color': Colors.orange,
      'type': 'Debit',
      'limit': null,
      'used': null,
    },
    {
      'name': 'Amex Black',
      'number': '**** **** **** 9012',
      'expiry': '06/27',
      'cvv': '789',
      'balance': '\$3,200.00',
      'color': Colors.black,
      'type': 'Credit',
      'limit': '\$10,000',
      'used': '\$6,800',
    },
  ];

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
            onPressed: () {
              // Navigate to add card screen
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Card Carousel
          Container(
            height: 220,
            margin: const EdgeInsets.all(16),
            child: PageView.builder(
              itemCount: _cards.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedCardIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final card = _cards[index];
                return _buildCard(card, index);
              },
            ),
          ),
          
          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _cards.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedCardIndex == index
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Card Details
          Expanded(
            child: Container(
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
                  
                  const SizedBox(height: 20),
                  
                  _buildDetailRow('Card Type', _cards[_selectedCardIndex]['type']),
                  _buildDetailRow('Card Number', _cards[_selectedCardIndex]['number']),
                  _buildDetailRow('Expiry Date', _cards[_selectedCardIndex]['expiry']),
                  _buildDetailRow('CVV', _cards[_selectedCardIndex]['cvv']),
                  
                  if (_cards[_selectedCardIndex]['type'] == 'Credit') ...[
                    const SizedBox(height: 20),
                    _buildDetailRow('Credit Limit', _cards[_selectedCardIndex]['limit']),
                    _buildDetailRow('Used Amount', _cards[_selectedCardIndex]['used']),
                    _buildCreditUsageBar(),
                  ],
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle freeze card
                          },
                          icon: Icon(Icons.block, color: AppTheme.warningColor),
                          label: Text(
                            'Freeze Card',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.warningColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppTheme.warningColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle card settings
                          },
                          icon: Icon(Icons.settings, color: Colors.white),
                          label: Text(
                            'Settings',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            card['color'],
            card['color'].withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: card['color'].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['name'],
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  card['type'] == 'Credit' ? Icons.credit_card : Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
            
            const Spacer(),
            
            Text(
              card['number'],
              style: AppTheme.heading4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRES',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      card['expiry'],
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BALANCE',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      card['balance'],
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms);
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            value ?? 'N/A',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditUsageBar() {
    final card = _cards[_selectedCardIndex];
    final limit = double.parse(card['limit'].replaceAll('\$', '').replaceAll(',', ''));
    final used = double.parse(card['used'].replaceAll('\$', '').replaceAll(',', ''));
    final percentage = (used / limit) * 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit Usage',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppTheme.borderColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage > 80 ? AppTheme.errorColor : AppTheme.primaryColor,
          ),
          minHeight: 8,
        ),
      ],
    );
  }
}
