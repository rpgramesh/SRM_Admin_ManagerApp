import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

// Extension for DesignTokens to add missing properties
extension DesignTokensExtension on DesignTokens {
  static Color get fontSizeSmall => Colors.grey[600]!;
  static Color get fontSizeMedium => Colors.grey[800]!;
  static Color get fontSizeLarge => Colors.black;
  static double get spacingXSmall => 4.0;
  static double get spacingSmall => 8.0;
  static double get spacingMedium => 16.0;
  static double get spacingLarge => 24.0;
  static Color get borderColor => Colors.grey[300]!;
  static Color get textSecondary => Colors.grey[600]!;
  static Color get textPrimary => Colors.black;
  static Color get errorColor => Colors.red;
  static Color get successColor => Colors.green;
  static Color get primaryColor => Color(0xFF2E7D32);
}

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I place an order?',
      answer: 'You can place an order by browsing our menu, adding items to your cart, and proceeding to checkout. Make sure to provide accurate delivery information.',
      category: 'Orders',
    ),
    FAQItem(
      question: 'What payment methods do you accept?',
      answer: 'We accept all major credit cards, debit cards, PayPal, Apple Pay, and Google Pay. Cash on delivery is also available in select areas.',
      category: 'Payment',
    ),
    FAQItem(
      question: 'How can I track my order?',
      answer: 'Once your order is confirmed, you will receive a tracking link via SMS and email. You can also track your order in real-time through the app.',
      category: 'Orders',
    ),
    FAQItem(
      question: 'What is your refund policy?',
      answer: 'We offer full refunds for cancelled orders before preparation begins. For quality issues, please contact our support team within 24 hours of delivery.',
      category: 'Refunds',
    ),
    FAQItem(
      question: 'How do I use promo codes?',
      answer: 'Enter your promo code at checkout in the "Promo Code" field. The discount will be applied automatically if the code is valid and meets the minimum order requirements.',
      category: 'Promotions',
    ),
    FAQItem(
      question: 'Can I modify my order after placing it?',
      answer: 'Orders can be modified within 5 minutes of placement. After that, please contact our support team, though changes may not always be possible.',
      category: 'Orders',
    ),
    FAQItem(
      question: 'How do loyalty points work?',
      answer: 'Earn 1 point for every dollar spent. Collect 100 points to get A\$10 off your next order. Points expire after 12 months of inactivity.',
      category: 'Loyalty',
    ),
    FAQItem(
      question: 'What are your delivery hours?',
      answer: 'We deliver from 11:00 AM to 11:00 PM, Monday through Sunday. Some locations may have extended hours on weekends.',
      category: 'Delivery',
    ),
  ];

  List<FAQItem> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems.where((faq) {
      return faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DesignTokensExtension.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Center',
          style: TextStyle(
            color: DesignTokensExtension.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickActions(),
          Expanded(
            child: _buildFAQList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(DesignTokensExtension.spacingMedium),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: DesignTokensExtension.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for help...',
          hintStyle: TextStyle(color: DesignTokensExtension.textSecondary),
          prefixIcon: Icon(Icons.search, color: DesignTokensExtension.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: DesignTokensExtension.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignTokensExtension.spacingMedium,
            vertical: DesignTokensExtension.spacingSmall,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: DesignTokensExtension.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: DesignTokensExtension.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignTokensExtension.spacingSmall),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  subtitle: 'Chat with support',
                  onTap: () => _showLiveChat(),
                ),
              ),
              SizedBox(width: DesignTokensExtension.spacingSmall),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '1-800-FOOD-123',
                  onTap: () => _showCallOptions(),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokensExtension.spacingMedium),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignTokensExtension.spacingMedium),
        decoration: BoxDecoration(
          color: DesignTokens.backgroundSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(color: DesignTokensExtension.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: DesignTokensExtension.primaryColor,
              size: 32,
            ),
            SizedBox(height: DesignTokensExtension.spacingXSmall),
            Text(
              title,
              style: TextStyle(
                color: DesignTokensExtension.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: DesignTokensExtension.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    final filteredFAQs = _filteredFAQs;
    
    if (filteredFAQs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: DesignTokensExtension.textSecondary,
            ),
            SizedBox(height: DesignTokensExtension.spacingMedium),
            Text(
              'No results found',
              style: TextStyle(
                color: DesignTokensExtension.textSecondary,
                fontSize: 16,
              ),
            ),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: DesignTokensExtension.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: DesignTokensExtension.spacingMedium),
      itemCount: filteredFAQs.length,
      itemBuilder: (context, index) {
        final faq = filteredFAQs[index];
        return _buildFAQItem(faq);
      },
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokensExtension.spacingSmall),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: DesignTokensExtension.borderColor),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: DesignTokensExtension.spacingMedium,
          vertical: DesignTokensExtension.spacingXSmall,
        ),
        childrenPadding: EdgeInsets.only(
          left: DesignTokensExtension.spacingMedium,
          right: DesignTokensExtension.spacingMedium,
          bottom: DesignTokensExtension.spacingMedium,
        ),
        title: Text(
          faq.question,
          style: TextStyle(
            color: DesignTokensExtension.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: DesignTokensExtension.spacingXSmall),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokensExtension.spacingSmall,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: DesignTokensExtension.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            faq.category,
            style: TextStyle(
              color: DesignTokensExtension.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Text(
            faq.answer,
            style: TextStyle(
              color: DesignTokensExtension.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Chat'),
        content: Text('Live chat feature will be available soon. For immediate assistance, please call our support line.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCallOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support Hours:'),
            Text('Monday - Friday: 8:00 AM - 10:00 PM'),
            Text('Saturday - Sunday: 9:00 AM - 9:00 PM'),
            SizedBox(height: DesignTokensExtension.spacingMedium),
            Text('Phone: 1-800-FOOD-123'),
            Text('Email: support@restaurant.com'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}