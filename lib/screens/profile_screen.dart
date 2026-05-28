import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/design_tokens.dart';
import 'loyalty_points_screen.dart';
import 'promo_codes_screen.dart';
import 'refer_friend_screen.dart';
import 'reviews_screen.dart';
import 'payment_methods_screen.dart';
import 'gift_cards_screen.dart';
import 'personal_details_screen.dart';
import 'settings_screen.dart';
import 'help_center_screen.dart';

// Extension for DesignTokens to add missing properties
extension DesignTokensExtension on DesignTokens {
  static Color get textPrimary => Colors.black;
  static Color get textSecondary => Colors.grey[600]!;
  static double get spacingMedium => 16.0;
  static double get spacingLarge => 24.0;
  static Color get primaryColor => Color(0xFF2E7D32);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: DesignTokens.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, user),
              _buildContent(context, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokensExtension.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokensExtension.spacingMedium,
              vertical: DesignTokensExtension.spacingMedium,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokensExtension.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon, {
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokensExtension.spacingMedium,
        vertical: 2,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: DesignTokensExtension.textSecondary,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: DesignTokensExtension.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokensExtension.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: DesignTokensExtension.textSecondary,
              size: 20,
            ),
          ],
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokensExtension.spacingMedium,
          vertical: 4,
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    if (user == null) {
      return Container(
        padding: EdgeInsets.all(DesignTokensExtension.spacingLarge),
        child: Column(
          children: [
            Text(
              'Your profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: DesignTokensExtension.textPrimary,
              ),
            ),
            SizedBox(height: DesignTokensExtension.spacingMedium),
            Text(
              'Find your rewards and manage your profile by accessing your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DesignTokensExtension.textSecondary,
              ),
            ),
            SizedBox(height: DesignTokensExtension.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokensExtension.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Log in or sign up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(DesignTokensExtension.spacingLarge),
      child: Column(
        children: [
          Text(
            'Your profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: DesignTokensExtension.textPrimary,
            ),
          ),
          SizedBox(height: DesignTokensExtension.spacingMedium),
          CircleAvatar(
            radius: 40,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                : null,
          ),
          SizedBox(height: DesignTokensExtension.spacingMedium),
          Text(
            user.displayName ?? 'User',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: DesignTokensExtension.textPrimary,
            ),
          ),
          Text(
            user.email ?? 'No email',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokensExtension.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignTokensExtension.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            'Rewards',
            [
              _buildMenuItem(
                context,
                'Loyalty points',
                Icons.stars_outlined,
                trailing: user != null ? '0 Yums' : null,
                onTap: () => _navigateToScreen(context, const LoyaltyPointsScreen()),
              ),
              _buildMenuItem(
                context,
                'Promo codes',
                Icons.local_offer_outlined,
                onTap: () => _navigateToScreen(context, const PromoCodesScreen()),
              ),
              _buildMenuItem(
                context,
                'Refer a friend',
                Icons.person_add_outlined,
                onTap: () => _navigateToScreen(context, const ReferFriendScreen()),
              ),
            ],
          ),
          _buildSection(
            context,
            'Your activity',
            [
              _buildMenuItem(
                context,
                'Reviews',
                Icons.star_outline,
                onTap: () => _navigateToScreen(context, const ReviewsScreen()),
              ),
            ],
          ),
          _buildSection(
            context,
            'TheFork Pay',
            [
              _buildMenuItem(
                context,
                'Payment',
                Icons.credit_card_outlined,
                onTap: () => _navigateToScreen(context, const PaymentMethodsScreen()),
              ),
              _buildMenuItem(
                context,
                'Gift Cards',
                Icons.card_giftcard_outlined,
                onTap: () => _navigateToScreen(context, const GiftCardsScreen()),
              ),
            ],
          ),
          _buildSection(
            context,
            'About you',
            [
              _buildMenuItem(
                context,
                'Personal details',
                Icons.person_outline,
                onTap: () => _navigateToScreen(context, const PersonalDetailsScreen()),
              ),
              if (user != null) ...[
                _buildMenuItem(
                  context,
                  'Manage followers',
                  Icons.people_outline,
                  onTap: () => _showComingSoon(context),
                ),
                _buildMenuItem(
                  context,
                  'Settings',
                  Icons.settings_outlined,
                  onTap: () => _navigateToScreen(context, const SettingsScreen()),
                ),
              ],
            ],
          ),
          _buildSection(
            context,
            'Help center',
            [
              _buildMenuItem(
                context,
                'Get support',
                Icons.help_outline,
                onTap: () => _navigateToScreen(context, const HelpCenterScreen()),
              ),
            ],
          ),
          if (user != null) ...[
            SizedBox(height: DesignTokensExtension.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: DesignTokensExtension.spacingLarge),
          Center(
            child: Text(
              '25.12.1',
              style: TextStyle(
                fontSize: 12,
                color: DesignTokensExtension.textSecondary,
              ),
            ),
          ),
          SizedBox(height: DesignTokensExtension.spacingLarge),
        ],
      ),
    );
  }

}