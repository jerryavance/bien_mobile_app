import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  final _convertedAmountController = TextEditingController();
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _exchangeRate = 0.85;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥', 'flag': '🇯🇵'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$', 'flag': '🇨🇦'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$', 'flag': '🇦🇺'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF', 'flag': '🇨🇭'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥', 'flag': '🇨🇳'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹', 'flag': '🇮🇳'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$', 'flag': '🇧🇷'},
  ];

  final List<Map<String, dynamic>> _recentConversions = [
    {'from': 'USD', 'to': 'EUR', 'amount': 100, 'rate': 0.85, 'date': '2 min ago'},
    {'from': 'EUR', 'to': 'GBP', 'amount': 500, 'rate': 0.86, 'date': '1 hour ago'},
    {'from': 'GBP', 'to': 'USD', 'amount': 200, 'rate': 1.27, 'date': '3 hours ago'},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _updateExchangeRate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertedAmountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (_amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null) {
        final converted = amount * _exchangeRate;
        _convertedAmountController.text = converted.toStringAsFixed(2);
      }
    } else {
      _convertedAmountController.clear();
    }
  }

  void _updateExchangeRate() {
    // Simulate API call to get real-time exchange rate
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Simulate different exchange rates
          if (_fromCurrency == 'USD' && _toCurrency == 'EUR') {
            _exchangeRate = 0.85;
          } else if (_fromCurrency == 'EUR' && _toCurrency == 'USD') {
            _exchangeRate = 1.18;
          } else if (_fromCurrency == 'USD' && _toCurrency == 'GBP') {
            _exchangeRate = 0.79;
          } else if (_fromCurrency == 'GBP' && _toCurrency == 'USD') {
            _exchangeRate = 1.27;
          } else {
            _exchangeRate = 1.0;
          }
        });
        _onAmountChanged();
      }
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _updateExchangeRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Currency Converter',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => _showExchangeRatesDialog(),
            icon: Icon(Icons.info_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exchange Rate Card
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCurrencyDisplay(_fromCurrency, 'From'),
                      IconButton(
                        onPressed: _swapCurrencies,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      _buildCurrencyDisplay(_toCurrency, 'To'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 16,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          '1 $_fromCurrency = ${_exchangeRate.toStringAsFixed(4)} $_toCurrency',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Amount Input Section
            Text(
              'Convert Amount',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // From Amount
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _getCurrencyFlag(_fromCurrency),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCurrencyName(_fromCurrency),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCurrencySymbol(_fromCurrency),
                              style: AppTheme.heading3.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // To Amount
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _getCurrencyFlag(_toCurrency),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCurrencyName(_toCurrency),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCurrencySymbol(_toCurrency),
                              style: AppTheme.heading3.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _convertedAmountController,
                          readOnly: true,
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Currency Selection
            Text(
              'Select Currencies',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: _fromCurrency,
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                      _updateExchangeRate();
                    },
                    label: 'From',
                    delay: 800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: _toCurrency,
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                      _updateExchangeRate();
                    },
                    label: 'To',
                    delay: 1000,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 1200.ms),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.favorite,
                    label: 'Add to Favorites',
                    onTap: () => _addToFavorites(),
                    delay: 1400,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.share,
                    label: 'Share Rate',
                    onTap: () => _shareExchangeRate(),
                    delay: 1600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.history,
                    label: 'View History',
                    onTap: () => _showConversionHistory(),
                    delay: 1800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Conversions
            Text(
              'Recent Conversions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 2000.ms),

            const SizedBox(height: 16),

            ...List.generate(
              _recentConversions.length,
              (index) => _buildRecentConversion(_recentConversions[index], index),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDisplay(String currencyCode, String label) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              _getCurrencyFlag(currencyCode),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currencyCode,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: _currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency['code'] as String,
                child: Row(
                  children: [
                    Text(currency['flag'] as String),
                    const SizedBox(width: 8),
                    Text(currency['code'] as String),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.3, end: 0);
  }

  Widget _buildRecentConversion(Map<String, dynamic> conversion, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.currency_exchange,
              color: AppTheme.infoColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${conversion['amount']} ${conversion['from']} → ${(conversion['amount'] * conversion['rate']).toStringAsFixed(2)} ${conversion['to']}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rate: ${conversion['rate']} • ${conversion['date']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _repeatConversion(conversion),
            icon: Icon(
              Icons.replay,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 2200 + index * 100)).slideX(begin: 0.3, end: 0);
  }

  String _getCurrencyFlag(String code) {
    final currency = _currencies.firstWhere((c) => c['code'] == code);
    return currency['flag'];
  }

  String _getCurrencyName(String code) {
    final currency = _currencies.firstWhere((c) => c['code'] == code);
    return currency['name'];
  }

  String _getCurrencySymbol(String code) {
    final currency = _currencies.firstWhere((c) => c['code'] == code);
    return currency['symbol'];
  }

  void _addToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_fromCurrency/$_toCurrency to favorites'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _shareExchangeRate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exchange rate shared'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showConversionHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conversion History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('View your complete conversion history'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('View Full History'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _repeatConversion(Map<String, dynamic> conversion) {
    setState(() {
      _fromCurrency = conversion['from'];
      _toCurrency = conversion['to'];
      _amountController.text = conversion['amount'].toString();
    });
    _updateExchangeRate();
  }

  void _showExchangeRatesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exchange Rates Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exchange rates are updated every 15 minutes.'),
            const SizedBox(height: 8),
            Text('Rates may vary slightly due to market fluctuations.'),
            const SizedBox(height: 8),
            Text('For large amounts, please contact our support team.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}
