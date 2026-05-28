import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/design_tokens.dart';
import '../services/loyalty_service.dart';
import '../models/loyalty_point.dart';

class LoyaltyPointsScreen extends StatefulWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  State<LoyaltyPointsScreen> createState() => _LoyaltyPointsScreenState();
}

class _LoyaltyPointsScreenState extends State<LoyaltyPointsScreen> {
  final LoyaltyService _loyaltyService = LoyaltyService();
  UserLoyaltyData? _userLoyaltyData;
  List<LoyaltyReward> _rewards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        final loyaltyData = await _loyaltyService.getUserLoyaltyData(user.uid);
        final rewards = await _loyaltyService.getAvailableRewards();
        
        setState(() {
          _userLoyaltyData = loyaltyData;
          _rewards = rewards;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'User not authenticated. Please sign in to view loyalty points.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: DesignTokens.neutralGrey50,
        appBar: AppBar(
          title: const Text(
            'Loyalty Points',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          backgroundColor: DesignTokens.neutralWhite,
          elevation: 0,
          iconTheme: const IconThemeData(color: DesignTokens.neutralGrey900),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: DesignTokens.primaryOrange,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: DesignTokens.neutralGrey50,
        appBar: AppBar(
          title: const Text(
            'Loyalty Points',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          backgroundColor: DesignTokens.neutralWhite,
          elevation: 0,
          iconTheme: const IconThemeData(color: DesignTokens.neutralGrey900),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: DesignTokens.error,
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                'Error loading loyalty data',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.neutralGrey900,
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              ElevatedButton(
                onPressed: _loadLoyaltyData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryOrange,
                  foregroundColor: DesignTokens.neutralWhite,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final userPoints = _userLoyaltyData?.availablePoints ?? 0;

    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text(
          'Loyalty Points',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey900,
          ),
        ),
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: DesignTokens.neutralGrey900),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Points Balance Card
            Container(
              margin: const EdgeInsets.all(DesignTokens.space16),
              padding: const EdgeInsets.all(DesignTokens.space24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primaryOrange, Color(0xFFFF8A50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primaryOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space12),
                        decoration: BoxDecoration(
                          color: DesignTokens.neutralWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                        ),
                        child: const Icon(
                          Icons.stars,
                          color: DesignTokens.neutralWhite,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Points Balance',
                              style: TextStyle(
                                color: DesignTokens.neutralWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.space4),
                            Text(
                              '$userPoints Yums',
                              style: const TextStyle(
                                color: DesignTokens.neutralWhite,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space20),
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: DesignTokens.neutralWhite.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: DesignTokens.neutralWhite,
                          size: 20,
                        ),
                        const SizedBox(width: DesignTokens.space8),
                        const Expanded(
                          child: Text(
                            'Earn 1 Yum for every A\$10 spent. Redeem for exciting rewards!',
                            style: TextStyle(
                              color: DesignTokens.neutralWhite,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Available Rewards Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.neutralGrey900,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Rewards List
                  ..._rewards.map((reward) => _buildRewardCard(reward)),
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(LoyaltyReward reward) {
    final userPoints = _userLoyaltyData?.availablePoints ?? 0;
    final bool canRedeem = userPoints >= reward.pointsCost;
    
    // Map icon names to actual icons
    IconData getIconFromName(String iconName) {
      switch (iconName.toLowerCase()) {
        case 'restaurant':
          return Icons.restaurant;
        case 'percent':
          return Icons.percent;
        case 'cake':
          return Icons.cake;
        case 'dinner_dining':
          return Icons.dinner_dining;
        case 'local_offer':
          return Icons.local_offer;
        default:
          return Icons.card_giftcard;
      }
    }
    
    // Map color names to actual colors
    Color getColorFromName(String colorName) {
      switch (colorName.toLowerCase()) {
        case 'orange':
          return DesignTokens.primaryOrange;
        case 'success':
        case 'green':
          return DesignTokens.success;
        case 'warning':
        case 'yellow':
          return DesignTokens.warning;
        case 'error':
        case 'red':
          return DesignTokens.error;
        default:
          return DesignTokens.primaryOrange;
      }
    }
    
    final rewardIcon = getIconFromName(reward.iconName);
    final rewardColor = getColorFromName(reward.color);
    
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: canRedeem ? rewardColor : DesignTokens.neutralGrey200,
          width: canRedeem ? 2 : 1,
        ),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.space12),
              decoration: BoxDecoration(
                color: rewardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Icon(
                rewardIcon,
                color: rewardColor,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.neutralGrey900,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    reward.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DesignTokens.neutralGrey600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space8),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: rewardColor,
                      ),
                      const SizedBox(width: DesignTokens.space4),
                      Text(
                        '${reward.pointsCost} Yums',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: rewardColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: canRedeem ? () => _redeemReward(reward) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRedeem ? rewardColor : DesignTokens.neutralGrey300,
                foregroundColor: DesignTokens.neutralWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
              ),
              child: Text(
                canRedeem ? 'Redeem' : 'Locked',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _redeemReward(LoyaltyReward reward) {
    final userPoints = _userLoyaltyData?.availablePoints ?? 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          title: Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: DesignTokens.primaryOrange,
                size: 24,
              ),
              const SizedBox(width: DesignTokens.space8),
              const Text('Redeem Reward'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to redeem "${reward.title}" for ${reward.pointsCost} Yums?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: DesignTokens.space16),
              Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                decoration: BoxDecoration(
                  color: DesignTokens.neutralGrey100,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: DesignTokens.neutralGrey600,
                      size: 20,
                    ),
                    const SizedBox(width: DesignTokens.space8),
                    Expanded(
                      child: Text(
                        'Your remaining balance will be ${userPoints - reward.pointsCost} Yums',
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.user;
                  
                  if (user != null) {
                     await _loyaltyService.redeemReward(
                       userId: user.uid,
                       rewardId: reward.id,
                       pointsCost: reward.pointsCost,
                     );
                     await _loadLoyaltyData(); // Refresh data
                   }
                  
                  Navigator.of(context).pop();
                  _showRedemptionSuccess(reward);
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error redeeming reward: $e'),
                      backgroundColor: DesignTokens.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryOrange,
                foregroundColor: DesignTokens.neutralWhite,
              ),
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }

  void _showRedemptionSuccess(LoyaltyReward reward) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: DesignTokens.neutralWhite,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.space8),
            Expanded(
              child: Text(
                'Successfully redeemed ${reward.title}! Check your rewards in the app.',
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
}