import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/design_tokens.dart';
import '../services/promo_service.dart';
import '../models/promo_code.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _promoCodeController = TextEditingController();
  
  List<PromoCode> availablePromoCodes = [];
  List<UserPromoCodeUsage> usedPromoCodes = [];
  bool isLoadingAvailable = true;
  bool isLoadingUsed = true;
  String? errorMessage;
  
  // Mock user ID - in a real app, this would come from authentication
  final String userId = 'user123';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPromoData();
  }
  
  Future<void> _loadPromoData() async {
    await Future.wait([
      _loadAvailablePromoCodes(),
      _loadUsedPromoCodes(),
    ]);
  }
  
  Future<void> _loadAvailablePromoCodes() async {
    try {
      setState(() {
        isLoadingAvailable = true;
        errorMessage = null;
      });
      
      final promoCodes = await PromoService.getAvailablePromoCodes();
      
      setState(() {
        availablePromoCodes = promoCodes;
        isLoadingAvailable = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load promo codes';
        isLoadingAvailable = false;
      });
    }
  }
  
  Future<void> _loadUsedPromoCodes() async {
    try {
      setState(() {
        isLoadingUsed = true;
      });
      
      final usedCodes = await PromoService.getUserPromoUsage(userId);
      
      setState(() {
        usedPromoCodes = usedCodes;
        isLoadingUsed = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUsed = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text(
          'Promo Codes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey900,
          ),
        ),
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: DesignTokens.neutralGrey900),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignTokens.primaryOrange,
          unselectedLabelColor: DesignTokens.neutralGrey600,
          indicatorColor: DesignTokens.primaryOrange,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Used'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Promo Code Input Section
          Container(
            margin: const EdgeInsets.all(DesignTokens.space16),
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.neutralWhite,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neutralGrey200.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have a promo code?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCodeController,
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                            borderSide: const BorderSide(color: DesignTokens.neutralGrey300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                            borderSide: const BorderSide(color: DesignTokens.primaryOrange),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space12,
                            vertical: DesignTokens.space12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    ElevatedButton(
                      onPressed: () => _applyPromoCode(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primaryOrange,
                        foregroundColor: DesignTokens.neutralWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space20,
                          vertical: DesignTokens.space12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailablePromoCodesTab(),
                _buildUsedPromoCodesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePromoCodesTab() {
    if (isLoadingAvailable) {
      return const Center(
        child: CircularProgressIndicator(
          color: DesignTokens.primaryOrange,
        ),
      );
    }
    
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignTokens.error,
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: DesignTokens.error,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            ElevatedButton(
              onPressed: _loadAvailablePromoCodes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (availablePromoCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              size: 64,
              color: DesignTokens.neutralGrey400,
            ),
            const SizedBox(height: DesignTokens.space16),
            const Text(
              'No promo codes available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: DesignTokens.neutralGrey600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
      itemCount: availablePromoCodes.length,
      itemBuilder: (context, index) {
        final promoCode = availablePromoCodes[index];
        return _buildAvailablePromoCodeCard(promoCode);
      },
    );
  }

  Widget _buildUsedPromoCodesTab() {
    if (isLoadingUsed) {
      return const Center(
        child: CircularProgressIndicator(
          color: DesignTokens.primaryOrange,
        ),
      );
    }
    
    if (usedPromoCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: DesignTokens.neutralGrey400,
            ),
            const SizedBox(height: DesignTokens.space16),
            const Text(
              'No promo codes used yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: DesignTokens.neutralGrey600,
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            const Text(
              'Start using promo codes to save on your orders!',
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
      itemCount: usedPromoCodes.length,
      itemBuilder: (context, index) {
        final promoCode = usedPromoCodes[index];
        return _buildUsedPromoCodeCard(promoCode);
      },
    );
  }

  Widget _buildAvailablePromoCodeCard(PromoCode promoCode) {
    final bool isActive = promoCode.isActive;
    
    // Map icon names to actual icons
    IconData getIcon(String iconName) {
      switch (iconName.toLowerCase()) {
        case 'celebration':
          return Icons.celebration;
        case 'local_offer':
          return Icons.local_offer;
        case 'money_off':
          return Icons.money_off;
        case 'weekend':
          return Icons.weekend;
        case 'discount':
          return Icons.discount;
        case 'card_giftcard':
          return Icons.card_giftcard;
        default:
          return Icons.local_offer;
      }
    }
    
    // Map color names to actual colors
    Color getColor(String colorName) {
      switch (colorName.toLowerCase()) {
        case 'success':
          return DesignTokens.success;
        case 'primaryorange':
          return DesignTokens.primaryOrange;
        case 'primaryblue':
          return DesignTokens.primaryBlue;
        case 'neutralgrey500':
          return DesignTokens.neutralGrey500;
        case 'error':
          return DesignTokens.error;
        default:
          return DesignTokens.primaryOrange;
      }
    }
    
    final iconData = getIcon(promoCode.iconName);
    final colorData = getColor(promoCode.color);
    
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: isActive ? colorData : DesignTokens.neutralGrey200,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralGrey200.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (!isActive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: DesignTokens.neutralGrey100.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.space8),
                      decoration: BoxDecoration(
                          color: colorData.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                      child: Icon(
                        iconData,
                        color: colorData,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promoCode.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActive ? DesignTokens.neutralGrey900 : DesignTokens.neutralGrey500,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.space8,
                              vertical: DesignTokens.space4,
                            ),
                            decoration: BoxDecoration(
                              color: colorData.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                            ),
                            child: Text(
                              promoCode.type == 'percentage' ? '${promoCode.value.toInt()}%' : 'A\$${promoCode.value.toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorData,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space8,
                          vertical: DesignTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.neutralGrey500,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: const Text(
                          'Expired',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.neutralWhite,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space12),
                Text(
                  promoCode.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? DesignTokens.neutralGrey600 : DesignTokens.neutralGrey400,
                  ),
                ),
                const SizedBox(height: DesignTokens.space12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Min Order: A\$${promoCode.minOrderAmount?.toInt() ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? DesignTokens.neutralGrey600 : DesignTokens.neutralGrey400,
                            ),
                          ),
                          Text(
                            'Valid until: ${promoCode.validUntil.day}/${promoCode.validUntil.month}/${promoCode.validUntil.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? DesignTokens.neutralGrey600 : DesignTokens.neutralGrey400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      ElevatedButton(
                        onPressed: () => _copyPromoCode(promoCode.code),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorData,
                          foregroundColor: DesignTokens.neutralWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space16,
                            vertical: DesignTokens.space8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                          ),
                        ),
                        child: const Text(
                          'Copy Code',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildUsedPromoCodeCard(UserPromoCodeUsage promoUsage) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: DesignTokens.neutralGrey200),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralGrey200.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space8),
                  decoration: BoxDecoration(
                    color: DesignTokens.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: DesignTokens.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promoUsage.promoCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        'Used Promo Code',
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    'Saved A\$${promoUsage.discountAmount.toInt()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Used on: ${promoUsage.usedAt.day}/${promoUsage.usedAt.month}/${promoUsage.usedAt.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey500,
                  ),
                ),
                Text(
                  'Order Value: A\$${promoUsage.orderAmount.toInt()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.copy,
              color: DesignTokens.neutralWhite,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.space8),
            Text(
              'Promo code "$code" copied to clipboard!',
              style: const TextStyle(color: DesignTokens.neutralWhite),
            ),
          ],
        ),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    final String enteredCode = _promoCodeController.text.trim().toUpperCase();
    
    if (enteredCode.isEmpty) {
      _showErrorSnackBar('Please enter a promo code');
      return;
    }

    try {
      // Validate promo code with a sample order amount of 1000
      final result = await PromoService.validatePromoCode(enteredCode, 1000.0);
      
      if (result['valid']) {
        _showSuccessSnackBar('Promo code "$enteredCode" is valid! Discount: A\$${result['discount'].toInt()}');
        _promoCodeController.clear();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Invalid promo code');
      }
    } catch (e) {
      _showErrorSnackBar('Error validating promo code');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: DesignTokens.neutralWhite,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.space8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: DesignTokens.neutralWhite),
              ),
            ),
          ],
        ),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: DesignTokens.neutralWhite,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.space8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: DesignTokens.neutralWhite),
              ),
            ),
          ],
        ),
        backgroundColor: DesignTokens.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
    );
  }
}