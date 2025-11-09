import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Account',
    'Payments',
    'Investments',
    'Security',
    'Technical',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer': 'Go to the login screen and tap "Forgot Password". Enter your email address and follow the instructions sent to your email.',
      'category': 'Account',
      'isExpanded': false,
    },
    {
      'question': 'How long do transfers take?',
      'answer': 'Bank transfers typically take 1-3 business days. Mobile money transfers are usually instant. International transfers may take 3-5 business days.',
      'category': 'Payments',
      'isExpanded': false,
    },
    {
      'question': 'How do I set up investment goals?',
      'answer': 'Navigate to the Savings screen and tap "Add Goal". Enter your target amount, deadline, and select a category. You can track your progress over time.',
      'category': 'Investments',
      'isExpanded': false,
    },
    {
      'question': 'Is my money safe?',
      'answer': 'Yes, we use bank-level security with 256-bit encryption. Your funds are protected by FDIC insurance up to \$250,000 per account.',
      'category': 'Security',
      'isExpanded': false,
    },
    {
      'question': 'How do I update my personal information?',
      'answer': 'Go to Profile > Edit Profile. You can update your name, email, phone number, and address. Some changes may require verification.',
      'category': 'Account',
      'isExpanded': false,
    },
    {
      'question': 'What investment options are available?',
      'answer': 'We offer stocks, bonds, ETFs, mutual funds, and cryptocurrency. You can start with as little as \$10 and build a diversified portfolio.',
      'category': 'Investments',
      'isExpanded': false,
    },
    {
      'question': 'How do I enable two-factor authentication?',
      'answer': 'Go to Settings > Security > Two-Factor Authentication. Choose between SMS, authenticator app, or hardware key for enhanced security.',
      'category': 'Security',
      'isExpanded': false,
    },
    {
      'question': 'Why is my transaction pending?',
      'answer': 'Transactions may be pending due to bank processing times, security reviews, or insufficient funds. Check your transaction history for updates.',
      'category': 'Payments',
      'isExpanded': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_selectedCategory == 'All') {
      return _faqs;
    }
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          'Help & Support',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for help topics...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
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
                filled: true,
                fillColor: AppTheme.surfaceColor,
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          
          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.chat_bubble,
                    label: 'Live Chat',
                    color: AppTheme.primaryColor,
                    onTap: () => _showLiveChat(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.phone,
                    label: 'Call Us',
                    color: AppTheme.secondaryColor,
                    onTap: () => _showCallDialog(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.email,
                    label: 'Email',
                    color: AppTheme.accentColor,
                    onTap: () => _showEmailDialog(),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 24),
          
          // FAQs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredFaqs.length} questions',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),
          
          const SizedBox(height: 16),
          
          // FAQs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                return _buildFaqTile(_filteredFaqs[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
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
    );
  }

  Widget _buildFaqTile(Map<String, dynamic> faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          faq['category'],
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
        trailing: Icon(
          faq['isExpanded'] ? Icons.expand_less : Icons.expand_more,
          color: AppTheme.textSecondary,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            faq['isExpanded'] = expanded;
          });
        },
      ),
    ).animate().fadeIn(delay: (1000 + index * 100).ms).slideX(begin: 0.3, end: 0);
  }

  void _showLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Chat'),
        content: Text('Connecting you to a customer service representative...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Customer Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call us at:'),
            const SizedBox(height: 8),
            Text(
              '+256 787 787878',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Available 24/7 for urgent matters'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement phone call functionality
              Navigator.pop(context);
            },
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email us at:'),
            const SizedBox(height: 8),
            Text(
              'support@bien.com',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('We typically respond within 24 hours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement email functionality
              Navigator.pop(context);
            },
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }
}
