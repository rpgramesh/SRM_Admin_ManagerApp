import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../services/menu_management_service.dart';
import '../services/firestore_service.dart';
import '../services/order_service.dart';
import 'manager_app_screen.dart';
import 'admin_app_screen.dart';

//import 'mapsample.dart';
//import 'login_page.dart';
/// App selector screen to choose between different ecosystem apps
class AppSelectorScreen extends StatelessWidget {
  const AppSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 33, 33),
      appBar: AppBar(
        title: Text("MyAppBar"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: Icon(Icons.menu),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: Column(
            children: [
              // // Login Page
              // const SizedBox(height: 50),
              // const Icon(Icons.lock,
              // size:100,),
              // const SizedBox(height: 20),
              // const Text('Login to your account',
              // style: TextStyle(
              //   fontSize: 20,
              //   fontWeight: FontWeight.bold,
              // ),),
              // const SizedBox(height: 20),
              // const Text('Enter your email and password',
              // style: TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.normal,
              // ),),
              // const SizedBox(height: 20),
              // const TextField(
              //   decoration: InputDecoration(
              //     hintText: 'Email',
              //   ),
              // ),
              // const SizedBox(height: 20),
              // const TextField(
              //   decoration: InputDecoration(
              //     hintText: 'Password',
              //   ),
              // ),
              // const SizedBox(height: 20),
              // const Text('Forgot Password?',
              // style: TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.normal,
              // ),),
              // const SizedBox(height: 20),
              // const Text('Login',
              // style: TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.normal,
              // ),),
              // const SizedBox(height: 20),
              // const Text('Don\'t have an account?',
              // style: TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.normal,
              // ),),
              // const SizedBox(height: 20),
              // const Text('Sign Up',
              // style: TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.normal,
              // ),),
              // Logo and Welcome
              // Expanded(
              //   flex: 3,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Container(
              //         width: 120,
              //         height: 120,
              //         decoration: BoxDecoration(
              //           color: DesignTokens.neutralWhite,
              //           borderRadius: BorderRadius.circular(DesignTokens.radiusXXLarge),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withAlpha((0.1 * 255).round()),
              //               blurRadius: 20,
              //               offset: const Offset(0, 10),
              //             ),
              //           ],
              //         ),
              //         child: ClipRRect(
              //           borderRadius: BorderRadius.circular(DesignTokens.radiusXXLarge),
              //           child: Image.asset(
              //             'assets/images/delhinightslogo.png',
              //             fit: BoxFit.contain,
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: DesignTokens.space24),
              //       // Text(
              //       //   'Delhi Nights',
              //       //   style: TextStyle(
              //       //     fontSize: 32,
              //       //     fontWeight: FontWeight.bold,
              //       //     color: DesignTokens.neutralWhite,
              //       //   ),
              //       // ),
              //       // const SizedBox(height: DesignTokens.space8),
              //       // Text(
              //       //   'Food Ecosystem',
              //       //   style: TextStyle(
              //       //     fontSize: 16,
              //       //     color: DesignTokens.neutralGrey300,
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              // App Selection Cards
              Expanded(
                flex: 4,
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: DesignTokens.space16,
                  mainAxisSpacing: DesignTokens.space16,
                  children: [
                    _AppCard(
                      title: 'Manager',
                      subtitle: 'Operations',
                      icon: Icons.manage_accounts,
                      color: DesignTokens.managerApp,
                      onTap: () =>
                          _navigateToApp(context, const ManagerAppScreen()),
                    ),
                    _AppCard(
                      title: 'Admin',
                      subtitle: 'System Control',
                      icon: Icons.admin_panel_settings,
                      color: DesignTokens.adminApp,
                      onTap: () =>
                          _navigateToApp(context, const AdminAppScreen()),
                    ),
                  ],
                ),
              ),
              // Footer
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Choose your portal to continue',
                    style: TextStyle(
                      color: DesignTokens.neutralGrey400,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToApp(BuildContext context, Widget appScreen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => appScreen),
    );
  }

  void _navigateToWaiterApp(BuildContext context) {
    // Get the required services from the root provider
    final menuManagementService =
        Provider.of<MenuManagementService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);

    // Navigate to WaiterAppScreen with the required providers
  }
}

class _AppCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AppCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AppCard> createState() => __AppCardState();
}

class __AppCardState extends State<_AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color,
                    widget.color.withAlpha((0.8 * 255).round()),
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 38,
                        color: DesignTokens.neutralWhite,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.neutralWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.neutralWhite.withAlpha(204),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
