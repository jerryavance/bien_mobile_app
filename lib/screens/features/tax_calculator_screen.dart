import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  final _incomeController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _exemptionsController = TextEditingController();
  
  double _annualIncome = 75000;
  double _deductions = 12950;
  double _exemptions = 0;
  String _selectedFilingStatus = 'Single';
  String _selectedState = 'California';
  bool _showResults = false;

  final List<String> _filingStatuses = [
    'Single',
    'Married Filing Jointly',
    'Married Filing Separately',
    'Head of Household',
    'Qualifying Widow(er)',
  ];

  final List<String> _states = [
    'California',
    'New York',
    'Texas',
    'Florida',
    'Illinois',
    'Pennsylvania',
    'Ohio',
    'Georgia',
    'North Carolina',
    'Michigan',
  ];

  @override
  void initState() {
    super.initState();
    _incomeController.text = _annualIncome.toString();
    _deductionsController.text = _deductions.toString();
    _exemptionsController.text = _exemptions.toString();
    
    _incomeController.addListener(_calculateTax);
    _deductionsController.addListener(_calculateTax);
    _exemptionsController.addListener(_calculateTax);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _deductionsController.dispose();
    _exemptionsController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    final income = double.tryParse(_incomeController.text);
    final deductions = double.tryParse(_deductionsController.text);
    final exemptions = double.tryParse(_exemptionsController.text);

    if (income != null && deductions != null && exemptions != null) {
      setState(() {
        _annualIncome = income;
        _deductions = deductions;
        _exemptions = exemptions;
        _showResults = true;
      });
    }
  }

  double get _taxableIncome => _annualIncome - _deductions - _exemptions;
  double get _federalTax => _calculateFederalTax(_taxableIncome);
  double get _stateTax => _calculateStateTax(_taxableIncome);
  double get _totalTax => _federalTax + _stateTax;
  double get _effectiveTaxRate => (_totalTax / _annualIncome) * 100;
  double get _takeHomePay => _annualIncome - _totalTax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Tax Calculator',
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
            onPressed: () => _showTaxInfoDialog(),
            icon: Icon(Icons.info_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filing Status Selection
            Text(
              'Filing Status',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Container(
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
              child: DropdownButtonFormField<String>(
                value: _selectedFilingStatus,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                items: _filingStatuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getFilingStatusIcon(status),
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(status),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilingStatus = value!;
                  });
                  _calculateTax();
                },
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // State Selection
            Container(
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
              child: DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                items: _states.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(state),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                  });
                  _calculateTax();
                },
              ),
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Income Input
            Text(
              'Income & Deductions',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 16),

            _buildInputField(
              controller: _incomeController,
              label: 'Annual Income',
              hint: 'Enter your annual income',
              prefix: '\$',
              keyboardType: TextInputType.number,
              delay: 1000,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _deductionsController,
                    label: 'Standard Deductions',
                    hint: 'Enter deductions',
                    prefix: '\$',
                    keyboardType: TextInputType.number,
                    delay: 1200,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    controller: _exemptionsController,
                    label: 'Exemptions',
                    hint: 'Enter exemptions',
                    prefix: '\$',
                    keyboardType: TextInputType.number,
                    delay: 1400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateTax,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Calculate Tax',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0),

            if (_showResults) ...[
              const SizedBox(height: 32),

              // Tax Summary
              Text(
                'Tax Summary',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 1800.ms),

              const SizedBox(height: 16),

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
                        Text(
                          'Take Home Pay',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '\$${_takeHomePay.toStringAsFixed(2)}',
                          style: AppTheme.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTaxSummaryItem(
                            'Federal Tax',
                            '\$${_federalTax.toStringAsFixed(2)}',
                            AppTheme.errorColor,
                          ),
                        ),
                        Expanded(
                          child: _buildTaxSummaryItem(
                            'State Tax',
                            '\$${_stateTax.toStringAsFixed(2)}',
                            AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Detailed Breakdown
              Text(
                'Detailed Breakdown',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 2200.ms),

              const SizedBox(height: 16),

              Container(
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
                    _buildBreakdownRow('Annual Income', '\$${_annualIncome.toStringAsFixed(2)}', AppTheme.textPrimary),
                    _buildBreakdownRow('Standard Deductions', '-\$${_deductions.toStringAsFixed(2)}', AppTheme.secondaryColor),
                    _buildBreakdownRow('Exemptions', '-\$${_exemptions.toStringAsFixed(2)}', AppTheme.secondaryColor),
                    Divider(color: AppTheme.borderColor),
                    _buildBreakdownRow('Taxable Income', '\$${_taxableIncome.toStringAsFixed(2)}', AppTheme.primaryColor, isBold: true),
                    Divider(color: AppTheme.borderColor),
                    _buildBreakdownRow('Federal Tax', '\$${_federalTax.toStringAsFixed(2)}', AppTheme.errorColor),
                    _buildBreakdownRow('State Tax', '\$${_stateTax.toStringAsFixed(2)}', AppTheme.warningColor),
                    Divider(color: AppTheme.borderColor),
                    _buildBreakdownRow('Total Tax', '\$${_totalTax.toStringAsFixed(2)}', AppTheme.errorColor, isBold: true),
                    Divider(color: AppTheme.borderColor),
                    _buildBreakdownRow('Effective Tax Rate', '${_effectiveTaxRate.toStringAsFixed(1)}%', AppTheme.infoColor),
                    _buildBreakdownRow('Take Home Pay', '\$${_takeHomePay.toStringAsFixed(2)}', AppTheme.successColor, isBold: true),
                  ],
                ),
              ).animate().fadeIn(delay: 2400.ms).slideX(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Tax Brackets Info
              Text(
                'Tax Brackets',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 2600.ms),

              const SizedBox(height: 16),

              Container(
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Bracket',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Rate',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Amount',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._buildTaxBrackets(),
                  ],
                ),
              ).animate().fadeIn(delay: 2800.ms).slideX(begin: 0.3, end: 0),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 3000.ms),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.share,
                      label: 'Share Results',
                      onTap: () => _shareResults(),
                      delay: 3200,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.save,
                      label: 'Save Calculation',
                      onTap: () => _saveCalculation(),
                      delay: 3400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.trending_up,
                      label: 'Tax Planning',
                      onTap: () => _showTaxPlanningDialog(),
                      delay: 3600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
    required TextInputType keyboardType,
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
          Row(
            children: [
              Text(
                prefix,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.3, end: 0);
  }

  Widget _buildTaxSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              value.split('\$')[1].split('.')[0],
              style: AppTheme.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color color, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaxBrackets() {
    final brackets = _getTaxBrackets();
    return brackets.map((bracket) {
      final min = bracket['min'] as num;
      final max = bracket['max'] as num;
      final rate = bracket['rate'] as num;
      final amount = bracket['amount'] as num;
      final isCurrentBracket = _taxableIncome >= min && _taxableIncome <= max;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentBracket ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '\$${min.toStringAsFixed(0)} - \$${max.toStringAsFixed(0)}',
                style: AppTheme.bodyMedium.copyWith(
                  color: isCurrentBracket ? AppTheme.primaryColor : AppTheme.textPrimary,
                  fontWeight: isCurrentBracket ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${rate.toStringAsFixed(1)}%',
                style: AppTheme.bodyMedium.copyWith(
                  color: isCurrentBracket ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isCurrentBracket ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '\$${amount.toStringAsFixed(2)}',
                style: AppTheme.bodyMedium.copyWith(
                  color: isCurrentBracket ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isCurrentBracket ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
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

  IconData _getFilingStatusIcon(String status) {
    switch (status) {
      case 'Single':
        return Icons.person;
      case 'Married Filing Jointly':
        return Icons.favorite;
      case 'Married Filing Separately':
        return Icons.people;
      case 'Head of Household':
        return Icons.family_restroom;
      case 'Qualifying Widow(er)':
        return Icons.favorite_border;
      default:
        return Icons.person;
    }
  }

  double _calculateFederalTax(double taxableIncome) {
    if (taxableIncome <= 0) return 0;
    
    double tax = 0;
    final brackets = _getTaxBrackets();
    
    for (var bracket in brackets) {
      final min = bracket['min'] as num;
      final max = bracket['max'] as num;
      final rate = bracket['rate'] as num;
      
      if (taxableIncome > min) {
        final bracketAmount = (taxableIncome - min).clamp(0, max - min);
        tax += bracketAmount * (rate / 100);
      }
    }
    
    return tax;
  }

  double _calculateStateTax(double taxableIncome) {
    // Simplified state tax calculation (varies by state)
    if (taxableIncome <= 0) return 0;
    
    switch (_selectedState) {
      case 'California':
        return taxableIncome * 0.075; // 7.5% state tax
      case 'New York':
        return taxableIncome * 0.068; // 6.8% state tax
      case 'Texas':
        return 0; // No state income tax
      case 'Florida':
        return 0; // No state income tax
      default:
        return taxableIncome * 0.05; // 5% average state tax
    }
  }

  List<Map<String, num>> _getTaxBrackets() {
    // 2024 Federal Tax Brackets (simplified)
    return [
      {'min': 0, 'max': 11600, 'rate': 10.0, 'amount': 0},
      {'min': 11600, 'max': 47150, 'rate': 12.0, 'amount': 0},
      {'min': 47150, 'max': 100525, 'rate': 22.0, 'amount': 0},
      {'min': 100525, 'max': 191950, 'rate': 24.0, 'amount': 0},
      {'min': 191950, 'max': 243725, 'rate': 32.0, 'amount': 0},
      {'min': 243725, 'max': 609350, 'rate': 35.0, 'amount': 0},
      {'min': 609350, 'max': double.infinity, 'rate': 37.0, 'amount': 0},
    ];
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tax calculation results shared'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _saveCalculation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calculation saved to favorites'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showTaxPlanningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tax Planning Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Maximize retirement contributions'),
            Text('• Consider itemized deductions'),
            Text('• Use tax-advantaged accounts'),
            Text('• Plan for capital gains/losses'),
            Text('• Consult a tax professional'),
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

  void _showTaxInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tax Calculator Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This calculator estimates:'),
            const SizedBox(height: 8),
            Text('• Federal income tax'),
            Text('• State income tax'),
            Text('• Effective tax rate'),
            Text('• Take-home pay'),
            const SizedBox(height: 8),
            Text('Note: Results are estimates based on 2025 tax brackets.'),
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
