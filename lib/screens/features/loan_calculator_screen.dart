import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTermController = TextEditingController();
  
  double _loanAmount = 10000;
  double _interestRate = 5.5;
  int _loanTerm = 12;
  String _selectedLoanType = 'Personal Loan';
  bool _showResults = false;

  final List<String> _loanTypes = [
    'Personal Loan',
    'Home Loan',
    'Car Loan',
    'Business Loan',
    'Student Loan',
    'Credit Card',
  ];

  @override
  void initState() {
    super.initState();
    _loanAmountController.text = _loanAmount.toString();
    _interestRateController.text = _interestRate.toString();
    _loanTermController.text = _loanTerm.toString();
    
    _loanAmountController.addListener(_calculateLoan);
    _interestRateController.addListener(_calculateLoan);
    _loanTermController.addListener(_calculateLoan);
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    super.dispose();
  }

  void _calculateLoan() {
    final amount = double.tryParse(_loanAmountController.text);
    final rate = double.tryParse(_interestRateController.text);
    final term = int.tryParse(_loanTermController.text);

    if (amount != null && rate != null && term != null) {
      setState(() {
        _loanAmount = amount;
        _interestRate = rate;
        _loanTerm = term;
        _showResults = true;
      });
    }
  }

  double get _monthlyInterestRate => _interestRate / 100 / 12;
  int get _totalPayments => _loanTerm * 12;

  double get _monthlyPayment {
    if (_monthlyInterestRate == 0) return _loanAmount / _totalPayments;
    
    final numerator = _loanAmount * _monthlyInterestRate * pow(1 + _monthlyInterestRate, _totalPayments);
    final denominator = pow(1 + _monthlyInterestRate, _totalPayments) - 1;
    return numerator / denominator;
  }

  double get _totalPayment => _monthlyPayment * _totalPayments;
  double get _totalInterest => _totalPayment - _loanAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Loan Calculator',
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
            onPressed: () => _showLoanInfoDialog(),
            icon: Icon(Icons.info_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Type Selection
            Text(
              'Loan Type',
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
                value: _selectedLoanType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                items: _loanTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getLoanTypeIcon(type),
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLoanType = value!;
                  });
                },
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Input Fields
            Text(
              'Loan Details',
              style: AppTheme.heading4.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 16),

            _buildInputField(
              controller: _loanAmountController,
              label: 'Loan Amount',
              hint: 'Enter loan amount',
              prefix: '\$',
              keyboardType: TextInputType.number,
              delay: 800,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _interestRateController,
                    label: 'Interest Rate',
                    hint: 'Enter interest rate',
                    prefix: '%',
                    keyboardType: TextInputType.number,
                    delay: 1000,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    controller: _loanTermController,
                    label: 'Loan Term',
                    hint: 'Enter loan term',
                    prefix: 'Years',
                    keyboardType: TextInputType.number,
                    delay: 1200,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateLoan,
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
                  'Calculate Loan',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0),

            if (_showResults) ...[
              const SizedBox(height: 32),

              // Results Section
              Text(
                'Loan Summary',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 1600.ms),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.secondaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(0.3),
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
                          'Monthly Payment',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '\$${_monthlyPayment.toStringAsFixed(2)}',
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
                          child: _buildResultItem(
                            'Total Interest',
                            '\$${_totalInterest.toStringAsFixed(2)}',
                            AppTheme.warningColor,
                          ),
                        ),
                        Expanded(
                          child: _buildResultItem(
                            'Total Payment',
                            '\$${_totalPayment.toStringAsFixed(2)}',
                            AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Amortization Schedule
              Text(
                'Amortization Schedule',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 2000.ms),

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
                              'Year',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Payment',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Principal',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Interest',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(
                      _loanTerm,
                      (index) => _buildAmortizationRow(index + 1),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 2200.ms).slideX(begin: 0.3, end: 0),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTheme.heading4.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 2400.ms),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.share,
                      label: 'Share Results',
                      onTap: () => _shareResults(),
                      delay: 2600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.save,
                      label: 'Save Calculation',
                      onTap: () => _saveCalculation(),
                      delay: 2800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.compare_arrows,
                      label: 'Compare Loans',
                      onTap: () => _showCompareDialog(),
                      delay: 3000,
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

  Widget _buildResultItem(String label, String value, Color color) {
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

  Widget _buildAmortizationRow(int year) {
    final yearPayment = _monthlyPayment * 12;
    final yearInterest = _calculateYearInterest(year);
    final yearPrincipal = yearPayment - yearInterest;

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
              year.toString(),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${yearPayment.toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${yearPrincipal.toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${yearInterest.toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.warningColor,
              ),
            ),
          ),
        ],
      ),
    );
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

  IconData _getLoanTypeIcon(String type) {
    switch (type) {
      case 'Personal Loan':
        return Icons.person;
      case 'Home Loan':
        return Icons.home;
      case 'Car Loan':
        return Icons.directions_car;
      case 'Business Loan':
        return Icons.business;
      case 'Student Loan':
        return Icons.school;
      case 'Credit Card':
        return Icons.credit_card;
      default:
        return Icons.account_balance;
    }
  }

  double _calculateYearInterest(int year) {
    double remainingBalance = _loanAmount;
    double totalInterest = 0;
    
    for (int month = 1; month <= year * 12; month++) {
      final monthlyInterest = remainingBalance * _monthlyInterestRate;
      totalInterest += monthlyInterest;
      remainingBalance -= (_monthlyPayment - monthlyInterest);
    }
    
    return totalInterest;
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loan calculation results shared'),
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

  void _showCompareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Compare Loans'),
        content: Text('Compare different loan options and terms to find the best deal for you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to comparison screen
            },
            child: Text('Compare Now'),
          ),
        ],
      ),
    );
  }

  void _showLoanInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Loan Calculator Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This calculator helps you estimate:'),
            const SizedBox(height: 8),
            Text('• Monthly loan payments'),
            Text('• Total interest costs'),
            Text('• Complete amortization schedule'),
            const SizedBox(height: 8),
            Text('Note: Results are estimates and may vary from actual loan terms.'),
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

// Helper function for power calculation
double pow(double x, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
