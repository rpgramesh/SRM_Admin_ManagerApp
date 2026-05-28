import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/design_tokens.dart';

class GiftCardsScreen extends StatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  State<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends State<GiftCardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for gift cards
  final List<Map<String, dynamic>> _myGiftCards = [
    {
      'id': 'GC001',
      'balance': 50.00,
      'originalAmount': 50.00,
      'expiryDate': DateTime(2024, 12, 31),
      'isActive': true,
      'code': 'GIFT50ABC123',
    },
    {
      'id': 'GC002',
      'balance': 25.75,
      'originalAmount': 100.00,
      'expiryDate': DateTime(2024, 6, 15),
      'isActive': true,
      'code': 'GIFT100XYZ456',
    },
    {
      'id': 'GC003',
      'balance': 0.00,
      'originalAmount': 25.00,
      'expiryDate': DateTime(2023, 12, 1),
      'isActive': false,
      'code': 'GIFT25DEF789',
    },
  ];
  
  final List<double> _giftCardAmounts = [25.0, 50.0, 100.0, 200.0];
  double _selectedAmount = 50.0;
  final _customAmountController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _customAmountController.dispose();
    _recipientEmailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralWhite,
      appBar: AppBar(
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: DesignTokens.neutralGrey900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gift Cards',
          style: TextStyle(
            color: DesignTokens.neutralGrey900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignTokens.primaryGreen,
          unselectedLabelColor: DesignTokens.neutralGrey600,
          indicatorColor: DesignTokens.primaryGreen,
          tabs: const [
            Tab(text: 'My Gift Cards'),
            Tab(text: 'Buy Gift Card'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGiftCardsTab(),
          _buildBuyGiftCardTab(),
        ],
      ),
    );
  }
  
  Widget _buildMyGiftCardsTab() {
    final activeCards = _myGiftCards.where((card) => card['isActive']).toList();
    final expiredCards = _myGiftCards.where((card) => !card['isActive']).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.space24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primaryGreen, Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Gift Card Balance',
                  style: TextStyle(
                    color: DesignTokens.neutralWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  'A\$${activeCards.fold(0.0, (sum, card) => sum + card['balance']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: DesignTokens.neutralWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  '${activeCards.length} active gift cards',
                  style: TextStyle(
                    color: DesignTokens.neutralWhite.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          
          // Active Gift Cards
          if (activeCards.isNotEmpty) ...[
            const Text(
              'Active Gift Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey900,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            ...activeCards.map((card) => _buildGiftCardItem(card, true)),
            const SizedBox(height: DesignTokens.space24),
          ],
          
          // Expired/Used Gift Cards
          if (expiredCards.isNotEmpty) ...[
            const Text(
              'Expired/Used Gift Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey900,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            ...expiredCards.map((card) => _buildGiftCardItem(card, false)),
          ],
          
          if (_myGiftCards.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: DesignTokens.space48),
                  Icon(
                    Icons.card_giftcard,
                    size: 64,
                    color: DesignTokens.neutralGrey400,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  const Text(
                    'No Gift Cards Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.neutralGrey600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space8),
                  const Text(
                    'Purchase your first gift card to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignTokens.neutralGrey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space24),
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryGreen,
                      foregroundColor: DesignTokens.neutralWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space24,
                        vertical: DesignTokens.space12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                    ),
                    child: const Text('Buy Gift Card'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildGiftCardItem(Map<String, dynamic> card, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: isActive ? DesignTokens.neutralWhite : DesignTokens.neutralGrey50,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(
          color: isActive ? DesignTokens.primaryGreen.withOpacity(0.3) : DesignTokens.neutralGrey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gift Card ${card['id']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? DesignTokens.neutralGrey900 : DesignTokens.neutralGrey600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space8,
                  vertical: DesignTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? DesignTokens.success.withOpacity(0.1) : DesignTokens.neutralGrey200,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Text(
                  isActive ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? DesignTokens.success : DesignTokens.neutralGrey600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? DesignTokens.neutralGrey600 : DesignTokens.neutralGrey500,
                    ),
                  ),
                  Text(
                    'A\$${card['balance'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isActive ? DesignTokens.primaryGreen : DesignTokens.neutralGrey600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Expires',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? DesignTokens.neutralGrey600 : DesignTokens.neutralGrey500,
                    ),
                  ),
                  Text(
                    '${card['expiryDate'].month}/${card['expiryDate'].day}/${card['expiryDate'].year}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isActive ? DesignTokens.neutralGrey900 : DesignTokens.neutralGrey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space12,
                    vertical: DesignTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.neutralGrey100,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: Text(
                    card['code'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: DesignTokens.neutralGrey700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              IconButton(
                onPressed: () => _copyGiftCardCode(card['code']),
                icon: const Icon(
                  Icons.copy,
                  size: 20,
                  color: DesignTokens.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBuyGiftCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gift Card Preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primaryGreen, Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: DesignTokens.space24,
                  left: DesignTokens.space24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TheFork Gift Card',
                        style: TextStyle(
                          color: DesignTokens.neutralWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Text(
                        'A\$${_selectedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: DesignTokens.neutralWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  bottom: DesignTokens.space24,
                  right: DesignTokens.space24,
                  child: Icon(
                    Icons.card_giftcard,
                    color: DesignTokens.neutralWhite,
                    size: 48,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space32),
          
          // Amount Selection
          const Text(
            'Select Amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          
          // Preset Amounts
          Wrap(
            spacing: DesignTokens.space12,
            runSpacing: DesignTokens.space12,
            children: _giftCardAmounts.map((amount) => _buildAmountChip(amount)).toList(),
          ),
          const SizedBox(height: DesignTokens.space16),
          
          // Custom Amount
          TextField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Custom Amount',
              prefixText: 'A\$',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                borderSide: const BorderSide(color: DesignTokens.primaryGreen, width: 2),
              ),
            ),
            onChanged: (value) {
              final customAmount = double.tryParse(value);
              if (customAmount != null && customAmount > 0) {
                setState(() {
                  _selectedAmount = customAmount;
                });
              }
            },
          ),
          const SizedBox(height: DesignTokens.space32),
          
          // Recipient Information
          const Text(
            'Send to Someone (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          
          TextField(
            controller: _recipientEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Recipient Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                borderSide: const BorderSide(color: DesignTokens.primaryGreen, width: 2),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Personal Message',
              prefixIcon: const Icon(Icons.message_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                borderSide: const BorderSide(color: DesignTokens.primaryGreen, width: 2),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space32),
          
          // Purchase Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _purchaseGiftCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryGreen,
                foregroundColor: DesignTokens.neutralWhite,
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.space16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                ),
              ),
              child: Text(
                'Purchase Gift Card - A\$${_selectedAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          
          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.neutralGrey50,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gift Card Terms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                const Text(
                  '• Gift cards are valid for 12 months from purchase date\n'
                  '• Can be used for any food orders on TheFork\n'
                  '• Non-refundable and cannot be exchanged for cash\n'
                  '• Can be combined with other payment methods\n'
                  '• Lost or stolen gift cards cannot be replaced',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.neutralGrey600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmountChip(double amount) {
    final isSelected = _selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _customAmountController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.primaryGreen : DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(
            color: isSelected ? DesignTokens.primaryGreen : DesignTokens.neutralGrey300,
          ),
        ),
        child: Text(
          'A\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? DesignTokens.neutralWhite : DesignTokens.neutralGrey900,
          ),
        ),
      ),
    );
  }
  
  void _copyGiftCardCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gift card code copied to clipboard'),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _purchaseGiftCard() {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid amount'),
          backgroundColor: DesignTokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Show purchase confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: A\$${_selectedAmount.toStringAsFixed(2)}'),
            if (_recipientEmailController.text.isNotEmpty)
              Text('Recipient: ${_recipientEmailController.text}'),
            const SizedBox(height: DesignTokens.space8),
            const Text(
              'Are you sure you want to purchase this gift card?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryGreen,
              foregroundColor: DesignTokens.neutralWhite,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
  
  void _processPurchase() {
    // Simulate purchase process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DesignTokens.primaryGreen),
            SizedBox(height: DesignTokens.space16),
            Text('Processing your purchase...'),
          ],
        ),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      
      // Add new gift card to the list
      setState(() {
        _myGiftCards.insert(0, {
          'id': 'GC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          'balance': _selectedAmount,
          'originalAmount': _selectedAmount,
          'expiryDate': DateTime.now().add(const Duration(days: 365)),
          'isActive': true,
          'code': 'GIFT${_selectedAmount.toInt()}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        });
        
        // Reset form
        _selectedAmount = 50.0;
        _customAmountController.clear();
        _recipientEmailController.clear();
        _messageController.clear();
      });
      
      // Switch to My Gift Cards tab
      _tabController.animateTo(0);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gift card purchased successfully!'),
          backgroundColor: DesignTokens.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}