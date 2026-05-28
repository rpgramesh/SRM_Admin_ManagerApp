import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/design_tokens.dart';

class ReferFriendScreen extends StatefulWidget {
  const ReferFriendScreen({super.key});

  @override
  State<ReferFriendScreen> createState() => _ReferFriendScreenState();
}

class _ReferFriendScreenState extends State<ReferFriendScreen> {
  final String userReferralCode = 'JOHN2024';
  final int totalReferrals = 12;
  final int pendingRewards = 3;
  final double totalEarnings = 850.0;

  final List<Map<String, dynamic>> referralHistory = [
    {
      'friendName': 'Sarah Johnson',
      'status': 'completed',
      'reward': 100,
      'date': '15 Dec 2024',
      'orderValue': 750,
    },
    {
      'friendName': 'Mike Chen',
      'status': 'completed',
      'reward': 150,
      'date': '12 Dec 2024',
      'orderValue': 1200,
    },
    {
      'friendName': 'Emma Wilson',
      'status': 'pending',
      'reward': 100,
      'date': '10 Dec 2024',
      'orderValue': 0,
    },
    {
      'friendName': 'David Kumar',
      'status': 'completed',
      'reward': 125,
      'date': '8 Dec 2024',
      'orderValue': 950,
    },
    {
      'friendName': 'Lisa Park',
      'status': 'pending',
      'reward': 100,
      'date': '5 Dec 2024',
      'orderValue': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text(
          'Refer a Friend',
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
            // Referral Code Section
            _buildReferralCodeSection(),
            
            // How it Works Section
            _buildHowItWorksSection(),
            
            // Stats Section
            _buildStatsSection(),
            
            // Referral History Section
            _buildReferralHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeSection() {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.space16),
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.primaryOrange,
            DesignTokens.primaryRed,
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
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
          const Icon(
            Icons.card_giftcard,
            size: 48,
            color: DesignTokens.neutralWhite,
          ),
          const SizedBox(height: DesignTokens.space16),
          const Text(
            'Share & Earn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DesignTokens.neutralWhite,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          const Text(
            'Invite friends and earn A\$100 for each successful referral!',
            style: TextStyle(
              fontSize: 16,
              color: DesignTokens.neutralWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space20),
          
          // Referral Code Display
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.neutralWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              border: Border.all(
                color: DesignTokens.neutralWhite.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Your Referral Code',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.neutralWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userReferralCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.neutralWhite,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    GestureDetector(
                      onTap: () => _copyReferralCode(),
                      child: Container(
                        padding: const EdgeInsets.all(DesignTokens.space8),
                        decoration: BoxDecoration(
                          color: DesignTokens.neutralWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: const Icon(
                          Icons.copy,
                          color: DesignTokens.neutralWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignTokens.space20),
          
          // Share Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareReferralCode(),
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text(
                    'Share Code',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.neutralWhite,
                    foregroundColor: DesignTokens.primaryOrange,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _inviteContacts(),
                  icon: const Icon(Icons.contacts, size: 20),
                  label: const Text(
                    'Invite Friends',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.neutralWhite.withOpacity(0.2),
                    foregroundColor: DesignTokens.neutralWhite,
                    side: const BorderSide(
                      color: DesignTokens.neutralWhite,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
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
            'How it Works',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          _buildHowItWorksStep(
            step: '1',
            title: 'Share your code',
            description: 'Send your referral code to friends via WhatsApp, SMS, or social media.',
            icon: Icons.share,
            color: DesignTokens.primaryBlue,
          ),
          const SizedBox(height: DesignTokens.space12),
          _buildHowItWorksStep(
            step: '2',
            title: 'Friend signs up',
            description: 'Your friend downloads the app and uses your referral code during signup.',
            icon: Icons.person_add,
            color: DesignTokens.primaryOrange,
          ),
          const SizedBox(height: DesignTokens.space12),
          _buildHowItWorksStep(
            step: '3',
            title: 'Both earn rewards',
            description: 'You get A\$100 and your friend gets A\$50 off their first order!',
            icon: Icons.celebration,
            color: DesignTokens.success,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: DesignTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.neutralGrey900,
                ),
              ),
              const SizedBox(height: DesignTokens.space4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.space16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Referrals',
              value: totalReferrals.toString(),
              icon: Icons.people,
              color: DesignTokens.primaryBlue,
            ),
          ),
          const SizedBox(width: DesignTokens.space12),
          Expanded(
            child: _buildStatCard(
              title: 'Pending Rewards',
              value: pendingRewards.toString(),
              icon: Icons.hourglass_empty,
              color: DesignTokens.warning,
            ),
          ),
          const SizedBox(width: DesignTokens.space12),
          Expanded(
            child: _buildStatCard(
              title: 'Total Earned',
              value: 'A\$${totalEarnings.toInt()}',
              icon: Icons.account_balance_wallet,
              color: DesignTokens.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.neutralGrey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralHistorySection() {
    return Container(
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
            'Referral History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          ...referralHistory.map((referral) => _buildReferralHistoryItem(referral)),
        ],
      ),
    );
  }

  Widget _buildReferralHistoryItem(Map<String, dynamic> referral) {
    final bool isCompleted = referral['status'] == 'completed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      padding: const EdgeInsets.all(DesignTokens.space12),
      decoration: BoxDecoration(
        color: DesignTokens.neutralGrey50,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
          color: isCompleted ? DesignTokens.success : DesignTokens.warning,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? DesignTokens.success.withOpacity(0.1)
                  : DesignTokens.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.hourglass_empty,
              color: isCompleted ? DesignTokens.success : DesignTokens.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral['friendName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  isCompleted 
                      ? 'Completed • Order: A\$${referral['orderValue']}'
                      : 'Pending first order',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey600,
                  ),
                ),
                Text(
                  referral['date'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey500,
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
              color: isCompleted 
                  ? DesignTokens.success.withOpacity(0.1)
                  : DesignTokens.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: Text(
              isCompleted ? '+A\$${referral['reward']}' : 'A\$${referral['reward']}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCompleted ? DesignTokens.success : DesignTokens.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: userReferralCode));
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
              'Referral code "$userReferralCode" copied!',
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

  void _shareReferralCode() {
    final String shareText = 
        'Hey! Join me on TheFork and get A\$50 off your first order. Use my referral code: $userReferralCode\n\nDownload the app now and start saving on delicious meals!';
    
    // Copy to clipboard and show share options
    Clipboard.setData(ClipboardData(text: shareText));
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Referral Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey900,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            const Text(
              'Referral message copied to clipboard!\nChoose how to share:',
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'SMS',
                  color: DesignTokens.primaryBlue,
                  onTap: () => Navigator.pop(context),
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  color: DesignTokens.primaryOrange,
                  onTap: () => Navigator.pop(context),
                ),
                _buildShareOption(
                  icon: Icons.share,
                  label: 'More',
                  color: DesignTokens.success,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.neutralGrey600,
            ),
          ),
        ],
      ),
    );
  }

  void _inviteContacts() {
    // In a real app, this would open contacts picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info,
              color: DesignTokens.neutralWhite,
              size: 20,
            ),
            SizedBox(width: DesignTokens.space8),
            Text(
              'Contact picker would open here in a real app',
              style: TextStyle(color: DesignTokens.neutralWhite),
            ),
          ],
        ),
        backgroundColor: DesignTokens.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}