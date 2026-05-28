import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

// Extension to add missing design token properties
extension DesignTokensExtension on DesignTokens {
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 18.0;
  static const double spacingXSmall = DesignTokens.space4;
  static const double spacingSmall = DesignTokens.space8;
  static const double spacingMedium = DesignTokens.space16;
  static const double spacingLarge = DesignTokens.space24;
  static const Color primaryColor = DesignTokens.primaryGreen;
  static const Color errorColor = DesignTokens.error;
  static const Color borderColor = DesignTokens.borderLight;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _orderUpdates = true;
  bool _promotionalOffers = false;
  bool _locationServices = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'AUD';
  bool _darkMode = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Italian'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: DesignTokens.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: DesignTokens.textPrimary,
            fontSize: DesignTokensExtension.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokensExtension.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            SizedBox(height: DesignTokensExtension.spacingSmall),
            _buildNotificationCard(),
            SizedBox(height: DesignTokensExtension.spacingLarge),

            // App Preferences Section
            _buildSectionHeader('App Preferences'),
            SizedBox(height: DesignTokensExtension.spacingSmall),
            _buildPreferencesCard(),
            SizedBox(height: DesignTokensExtension.spacingLarge),

            // Privacy & Security Section
            _buildSectionHeader('Privacy & Security'),
            SizedBox(height: DesignTokensExtension.spacingSmall),
            _buildPrivacyCard(),
            SizedBox(height: DesignTokensExtension.spacingLarge),

            // Account Section
            _buildSectionHeader('Account'),
            SizedBox(height: DesignTokensExtension.spacingSmall),
            _buildAccountCard(),
            SizedBox(height: DesignTokensExtension.spacingLarge),

            // About Section
            _buildSectionHeader('About'),
            SizedBox(height: DesignTokensExtension.spacingSmall),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: DesignTokens.textPrimary,
        fontSize: DesignTokensExtension.fontSizeMedium,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokensExtension.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            'Push Notifications',
            'Receive notifications on your device',
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            'Email Notifications',
            'Receive updates via email',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive text message updates',
            _smsNotifications,
            (value) => setState(() => _smsNotifications = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            'Order Updates',
            'Get notified about order status',
            _orderUpdates,
            (value) => setState(() => _orderUpdates = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            'Promotional Offers',
            'Receive special deals and offers',
            _promotionalOffers,
            (value) => setState(() => _promotionalOffers = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokensExtension.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme',
            _darkMode,
            (value) => setState(() => _darkMode = value),
          ),
          _buildDivider(),
          _buildDropdownTile(
            'Language',
            'App display language',
            _selectedLanguage,
            _languages,
            (value) => setState(() => _selectedLanguage = value!),
          ),
          _buildDivider(),
          _buildDropdownTile(
            'Currency',
            'Preferred currency',
            _selectedCurrency,
            _currencies,
            (value) => setState(() => _selectedCurrency = value!),
          ),
          _buildDivider(),
          _buildSwitchTile(
            'Location Services',
            'Allow location access for delivery',
            _locationServices,
            (value) => setState(() => _locationServices = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokensExtension.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Terms of Service',
            'View terms and conditions',
            Icons.description_outlined,
            () => _showTermsOfService(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Data & Storage',
            'Manage your data preferences',
            Icons.storage_outlined,
            () => _showDataSettings(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Clear Cache',
            'Free up storage space',
            Icons.cleaning_services_outlined,
            () => _clearCache(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokensExtension.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            'Change Password',
            'Update your account password',
            Icons.lock_outline,
            () => _changePassword(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Two-Factor Authentication',
            'Add extra security to your account',
            Icons.security_outlined,
            () => _setupTwoFactor(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Linked Accounts',
            'Manage connected social accounts',
            Icons.link_outlined,
            () => _manageLinkedAccounts(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_outline,
            () => _deleteAccount(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokensExtension.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            'App Version',
            'v1.2.3 (Build 456)',
            Icons.info_outline,
            () => _showAppInfo(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Rate App',
            'Rate us on the App Store',
            Icons.star_outline,
            () => _rateApp(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'Contact Support',
            'Get help with your account',
            Icons.support_agent_outlined,
            () => _contactSupport(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            'What\'s New',
            'See latest app updates',
            Icons.new_releases_outlined,
            () => _showWhatsNew(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.all(DesignTokensExtension.spacingMedium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: DesignTokens.textPrimary,
                    fontSize: DesignTokensExtension.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: DesignTokensExtension.spacingXSmall),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: DesignTokens.textSecondary,
                    fontSize: DesignTokensExtension.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DesignTokensExtension.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.all(DesignTokensExtension.spacingMedium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: DesignTokens.textPrimary,
                    fontSize: DesignTokensExtension.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: DesignTokensExtension.spacingXSmall),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: DesignTokens.textSecondary,
                    fontSize: DesignTokensExtension.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(
                    color: DesignTokens.textPrimary,
                    fontSize: DesignTokensExtension.fontSizeSmall,
                  ),
                ),
              );
            }).toList(),
            underline: Container(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(DesignTokensExtension.spacingMedium),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? DesignTokensExtension.errorColor : DesignTokens.textSecondary,
              size: 24,
            ),
            SizedBox(width: DesignTokensExtension.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? DesignTokensExtension.errorColor : DesignTokens.textPrimary,
                      fontSize: DesignTokensExtension.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: DesignTokensExtension.spacingXSmall),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: DesignTokens.textSecondary,
                      fontSize: DesignTokensExtension.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: DesignTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: DesignTokensExtension.borderColor,
      indent: DesignTokensExtension.spacingMedium,
      endIndent: DesignTokensExtension.spacingMedium,
    );
  }

  // Action methods
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy content would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of service content would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data settings opened')),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password screen opened')),
    );
  }

  void _setupTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication setup opened')),
    );
  }

  void _manageLinkedAccounts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Linked accounts management opened')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion initiated')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: DesignTokensExtension.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: const Text(
          'Restaurant App\nVersion 1.2.3 (Build 456)\n\nDeveloped with Flutter\n© 2024 Restaurant App Inc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecting to App Store...')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support contact opened')),
    );
  }

  void _showWhatsNew() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What\'s New'),
        content: const Text(
          'Version 1.2.3:\n• Improved performance\n• Bug fixes\n• New features\n• Enhanced UI',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}