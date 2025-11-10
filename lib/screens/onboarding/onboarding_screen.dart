import 'package:bien/services/launch_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to Bien',
      'subtitle': 'Smart finance made simple',
      'description': 'Bien brings all your finances together — from smart savings and spending to secure payments, built for simplicity and control.',
      'icon': Icons.account_balance,
      // 'svgIcon': 'assets/icons/logo.svg',
      'color': AppTheme.primaryColor,
      'image': 'assets/illustrations/onboarding_1.png',
    },
    {
      'title': 'Effortless Payments',
      'subtitle': 'Pay anyone, anytime, anywhere',
      'description': 'From airtime and utilities to school fees and merchants — Bien makes paying easy, fast, and secure with just a few taps.',
      'icon': Icons.payment,
      'color': AppTheme.accentColor,
      'image': 'assets/illustrations/onboarding_3.png',
    },
    {
      'title': 'Smart Budgeting',
      'subtitle': 'Stay in control of your money',
      'description': 'Set goals, track expenses, and see where your money goes. Bien gives you clear insights to help you spend wisely and save more.',
      'icon': Icons.pie_chart,
      'color': AppTheme.secondaryColor,
      'image': 'assets/illustrations/onboarding_2.png',
    },
    {
      'title': 'Secure & Private',
      'subtitle': 'Your security is our priority',
      'description': 'Your data and transactions are protected with bank-level encryption. Bien keeps your money — and your information — safe, always.',
      'icon': Icons.security,
      'color': AppTheme.successColor,
      'image': 'assets/illustrations/onboarding_4.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login'); 
                  },
                  child: Text(
                    'Skip',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index], index);
                },
              ),
            ),
            
            // Page Indicator and Navigation
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? _onboardingData[index]['color']
                              : AppTheme.borderColor,
                        ),
                      ).animate().scale(duration: 300.ms),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: AppTheme.borderColor),
                            ),
                            child: Text(
                              'Previous',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      if (_currentPage > 0) const SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_currentPage < _onboardingData.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              await LaunchService.markOnboardingShown();
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _onboardingData[_currentPage]['color'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage < _onboardingData.length - 1 ? 'Next' : 'Get Started',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              data['icon'],
              color: data['color'],
              size: 60,
            ),
          ).animate().scale(duration: 600.ms).then().shake(),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            data['title'],
            style: AppTheme.heading2.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            data['subtitle'],
            style: AppTheme.heading4.copyWith(
              color: data['color'],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            data['description'],
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),
          
          const SizedBox(height: 40),
          
          // Feature Highlights
          if (index == 0) _buildFeatureHighlights(),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {'icon': Icons.savings, 'text': 'Smart Savings'},
      {'icon': Icons.analytics, 'text': 'Seamless Payments'},
      {'icon': Icons.security, 'text': 'Bank-level Security'},
      {'icon': Icons.support_agent, 'text': '24/7 Support'},
    ];

    return Column(
      children: [
        Text(
          'Key Features',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Wrap in SingleChildScrollView to prevent horizontal overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: features.map((feature) {
              return Container(
                width: 80, // Fixed width to prevent overflow
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['text'] as String,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0);
  }
}
