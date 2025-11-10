import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '1M';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _holdings = [
    {
      'symbol': 'AAPL',
      'name': 'Apple Inc.',
      'shares': 25.5,
      'avgPrice': 150.25,
      'currentPrice': 175.80,
      'change': 17.05,
      'changePercent': 11.35,
      'value': 4482.90,
      'sector': 'Technology',
      'color': AppTheme.primaryColor,
    },
    {
      'symbol': 'GOOGL',
      'name': 'Alphabet Inc.',
      'shares': 15.0,
      'avgPrice': 2800.00,
      'currentPrice': 2950.50,
      'change': 150.50,
      'changePercent': 5.38,
      'value': 44257.50,
      'sector': 'Technology',
      'color': AppTheme.secondaryColor,
    },
    {
      'symbol': 'TSLA',
      'name': 'Tesla Inc.',
      'shares': 30.0,
      'avgPrice': 800.00,
      'currentPrice': 950.25,
      'change': 150.25,
      'changePercent': 18.78,
      'value': 28507.50,
      'sector': 'Automotive',
      'color': AppTheme.accentColor,
    },
    {
      'symbol': 'MSFT',
      'name': 'Microsoft Corp.',
      'shares': 20.0,
      'avgPrice': 300.00,
      'currentPrice': 325.75,
      'change': 25.75,
      'changePercent': 8.58,
      'value': 6515.00,
      'sector': 'Technology',
      'color': AppTheme.infoColor,
    },
    {
      'symbol': 'AMZN',
      'name': 'Amazon.com Inc.',
      'shares': 18.0,
      'avgPrice': 3200.00,
      'currentPrice': 3400.00,
      'change': 200.00,
      'changePercent': 6.25,
      'value': 61200.00,
      'sector': 'Consumer',
      'color': AppTheme.warningColor,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Investment Portfolio'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              '1W',
              '1M',
              '3M',
              '6M',
              '1Y',
              'ALL',
            ].map((period) => PopupMenuItem(
              value: period,
              child: Text(period),
            )).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Portfolio Summary
          Container(
            margin: const EdgeInsets.all(16),
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
                  'Portfolio Value',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$144,963.90',
                  style: AppTheme.heading1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Return',
                            style: AppTheme.caption.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+\$18,456.78',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return %',
                            style: AppTheme.caption.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+14.6%',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, duration: 600.ms),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: const [
                Tab(text: 'Holdings'),
                Tab(text: 'Performance'),
                Tab(text: 'Watchlist'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHoldingsTab(),
                _buildPerformanceTab(),
                _buildWatchlistTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Holdings',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          ..._holdings.map((holding) => _buildHoldingItem(holding)),
          
          const SizedBox(height: 24),
          
          // Sector Allocation
          Text(
            'Sector Allocation',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 16),
          
          _buildSectorAllocation(),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(Map<String, dynamic> holding) {
    final change = holding['change'] as double;
    final changePercent = holding['changePercent'] as double;
    final isPositive = change >= 0;

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (holding['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    holding['symbol'] as String,
                    style: AppTheme.bodyMedium.copyWith(
                      color: holding['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding['name'] as String,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${holding['shares']} shares',
                      style: AppTheme.bodySmall.copyWith(
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
                    '\$${holding['value'].toStringAsFixed(2)}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}\$${change.toStringAsFixed(2)} (${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                        style: AppTheme.caption.copyWith(
                          color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avg Price: \$${holding['avgPrice'].toStringAsFixed(2)}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'Current: \$${holding['currentPrice'].toStringAsFixed(2)}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorAllocation() {
    final sectors = <String, double>{};
    double totalValue = 0;

    for (final holding in _holdings) {
      final sector = holding['sector'] as String;
      final value = holding['value'] as double;
      sectors[sector] = (sectors[sector] ?? 0) + value;
      totalValue += value;
    }

    return Column(
      children: sectors.entries.map((entry) {
        final percentage = (entry.value / totalValue) * 100;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Performance Chart Placeholder
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 48,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Performance Chart',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chart data for $_selectedPeriod period',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Key Metrics',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 16),
          
          _buildMetricCard('Sharpe Ratio', '1.85', '+0.12', AppTheme.successColor),
          _buildMetricCard('Beta', '1.12', '-0.05', AppTheme.infoColor),
          _buildMetricCard('Alpha', '2.34%', '+0.45%', AppTheme.secondaryColor),
          _buildMetricCard('Max Drawdown', '-8.5%', '-2.1%', AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String change, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                change,
                style: AppTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistTab() {
    final watchlist = [
      {'symbol': 'NVDA', 'name': 'NVIDIA Corp.', 'price': 485.75, 'change': 12.50, 'changePercent': 2.64},
      {'symbol': 'META', 'name': 'Meta Platforms', 'price': 320.25, 'change': -8.75, 'changePercent': -2.66},
      {'symbol': 'NFLX', 'name': 'Netflix Inc.', 'price': 450.00, 'change': 15.25, 'changePercent': 3.51},
      {'symbol': 'CRM', 'name': 'Salesforce Inc.', 'price': 280.50, 'change': 5.25, 'changePercent': 1.91},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Watchlist',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          ...watchlist.map((stock) => _buildWatchlistItem(stock)),
          
          const SizedBox(height: 24),
          
          // Add to Watchlist Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Add stock to watchlist
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Stock to Watchlist'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(Map<String, dynamic> stock) {
    final change = stock['change'] as double;
    final changePercent = stock['changePercent'] as double;
    final isPositive = change >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
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
                stock['symbol'] as String,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock['name'] as String,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UGX ${stock['price'].toStringAsFixed(2)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''} UGX ${change.toStringAsFixed(2)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                style: AppTheme.caption.copyWith(
                  color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
