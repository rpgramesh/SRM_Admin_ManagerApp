import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manager_service.dart';
import 'add_restaurant_screen.dart';
import 'view_reports_screen.dart';
import 'add_dasher_screen.dart'; // ADD THIS IMPORT

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: Colors.blue[900],
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Show profile/settings
              _showManagerProfile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout functionality
              _handleLogout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.store), text: 'Restaurants'),
            Tab(icon: Icon(Icons.motorcycle), text: 'Dashers'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.manage_accounts), text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildRestaurantsTab(),
          _buildDashersTab(),
          _buildAnalyticsTab(),
          _buildSystemTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomBarItem(
              icon: Icons.restaurant,
              label: 'Restaurants',
              stream: Provider.of<ManagerService>(context)
                  .getActiveRestaurantsCount(),
              onTap: () => _tabController.animateTo(1),
            ),
            _buildBottomBarItem(
              icon: Icons.motorcycle,
              label: 'Dashers',
              stream:
                  Provider.of<ManagerService>(context).getActiveDashersCount(),
              onTap: () => _tabController.animateTo(2),
            ),
            _buildBottomBarItem(
              icon: Icons.analytics,
              label: 'Analytics',
              stream:
                  Provider.of<ManagerService>(context).getTotalOrdersCount(),
              onTap: () => _tabController.animateTo(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required Stream<int> stream,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(icon, size: 24, color: Colors.deepPurple),
                StreamBuilder<int>(
                  stream: stream,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    if (count == 0) return const SizedBox();

                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final managerService = context.watch<ManagerService>();

    return StreamBuilder<Map<String, dynamic>>(
      stream: managerService.getTodayDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh handled by stream
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'Active Restaurants',
                    value: data['activeRestaurants']?.toString() ?? '0',
                    icon: Icons.restaurant,
                    color: Colors.orange,
                    trend: '+2',
                    trendColor: Colors.green,
                    onTap: () => _tabController.animateTo(1),
                  ),
                  _buildStatCard(
                    title: 'Active Dashers',
                    value: data['activeDashers']?.toString() ?? '0',
                    icon: Icons.motorcycle,
                    color: Colors.blue,
                    trend: '+8',
                    trendColor: Colors.green,
                    onTap: () => _tabController.animateTo(2),
                  ),
                  _buildStatCard(
                    title: 'Today\'s Orders',
                    value: data['todayOrders']?.toString() ?? '0',
                    icon: Icons.shopping_bag,
                    color: Colors.purple,
                    trend: '+12%',
                    trendColor: Colors.green,
                    onTap: () => _navigateToTodayOrders(),
                  ),
                  _buildStatCard(
                    title: 'Revenue',
                    value:
                        '\$${data['todayRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    trend: '-3%',
                    trendColor: Colors.red,
                    onTap: () => _navigateToRevenue(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantsTab() {
    final managerService = context.watch<ManagerService>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: managerService.getRestaurants(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final restaurants = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Restaurant'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddRestaurantScreen()),
                      );
                    },
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () async {
                      await managerService.addRestaurant({
                        'name': 'Sample Restaurant',
                        'address': '123 Main St',
                        'phone': '555-0123',
                        'email': 'test@restaurant.com',
                        'cuisine_type': 'Fast Food',
                        'isActive': true,
                        'geoLocation': {
                          'latitude': 37.7749,
                          'longitude': -122.4194
                        },
                        'delivery_radius': 10,
                        'minimum_order': 15.0,
                        'delivery_fee': 2.99,
                        'tax_rate': 0.0875,
                        'payment_methods': ['credit_card', 'cash'],
                        'rating': 4.5,
                        'total_reviews': 100,
                      });
                    },
                    child: const Text('Create Sample Data'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return _buildRestaurantCard(restaurant);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashersTab() {
    final managerService = context.watch<ManagerService>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: managerService.getDashers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashers = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register New Dasher'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddDasherScreen(),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  // REMOVE THIS ENTIRE BUTTON
                  /*
                  OutlinedButton(
                    onPressed: () async {
                      await managerService.addDasher({
                        'name': 'Sample Dasher',
                        'email': 'dasher@test.com',
                        'phone': '555-0124',
                        'license_number': 'DL123456789',
                        'vehicle_type': 'bike',
                        'isOnline': true,
                        'isAvailable': true,
                        'total_orders': 50,
                        'completion_rate': 98.5,
                        'rating': 4.8,
                        'earnings': 2500.0,
                        'vehicle_details': {
                          'make': 'Honda',
                          'model': 'Activa',
                          'year': 2023,
                          'color': 'Red',
                          'license_plate': 'BIKE123'
                        },
                        'background_check_complete': true,
                      });
                    },
                    child: const Text('Create Sample Dasher'),
                  ),
                  */
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dashers.length,
                itemBuilder: (context, index) {
                  final dasher = dashers[index];
                  return _buildDasherCard(dasher);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    final managerService = context.watch<ManagerService>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: managerService.getOrders(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAnalyticsOverview(orders),
            const SizedBox(height: 20),
            _buildSalesChart(orders),
            const SizedBox(height: 20),
            _buildTopItemsReport(orders),
            const SizedBox(height: 20),
            _buildOrderStatusReport(orders),
          ],
        );
      },
    );
  }

  Widget _buildSystemTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'System Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure system-wide settings here.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Dashboard'),
            onPressed: () {
              setState(() {});
            },
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
    required String trend,
    required Color trendColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          width: 160,
          height: 120,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: trendColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToTodayOrders() {
    // Navigate to Today's Orders screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ViewReportsScreen(),
      ),
    );
  }

  void _navigateToRevenue() {
    // Navigate to Revenue screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ViewReportsScreen(),
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(restaurant['name']?[0] ?? 'R'),
        ),
        title: Text(restaurant['name'] ?? 'Unknown Restaurant'),
        subtitle: Text(restaurant['address'] ?? 'No address provided'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: restaurant['isActive'] ?? true,
              onChanged: (value) => context
                  .read<ManagerService>()
                  .updateRestaurantStatus(restaurant['id'], value),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditRestaurantDialog(restaurant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDasherCard(Map<String, dynamic> dasher) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(dasher['name']?[0] ?? 'D'),
        ),
        title: Text(dasher['name'] ?? 'Unknown Dasher'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dasher['email'] ?? 'No email'),
            Text('${dasher['vehicle_type'] ?? 'Unknown vehicle'}'),
            Text('Rating: ${dasher['rating'] ?? 0}/5.0'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: dasher['isAvailable'] ?? true,
              onChanged: (value) => context
                  .read<ManagerService>()
                  .updateDasherAvailability(dasher['id'], value),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDasherDialog(dasher),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder methods for dialogs and actions
  void _showManagerProfile() {}
  void _handleLogout() {}
  void _showAddRestaurantDialog() {}
  void _showRegisterDasherDialog() {}
  void _showEditRestaurantDialog(Map<String, dynamic> restaurant) {}
  void _showEditDasherDialog(Map<String, dynamic> dasher) {}
  Widget _buildQuickActions() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.restaurant,
                  label: 'Add Restaurant',
                  color: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddRestaurantScreen()),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.bar_chart,
                  label: 'View Reports',
                  color: Colors.deepPurple,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ViewReportsScreen()),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.person_add,
                  label: 'Register Dasher',
                  color: Colors.blue,
                  onPressed: () {
                    // TODO: Implement Register Dasher screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Register Dasher feature coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentActivity() => Container();
  Widget _buildAnalyticsOverview(List<Map<String, dynamic>> orders) =>
      Container();
  Widget _buildSalesChart(List<Map<String, dynamic>> orders) => Container();
  Widget _buildTopItemsReport(List<Map<String, dynamic>> orders) => Container();
  Widget _buildOrderStatusReport(List<Map<String, dynamic>> orders) =>
      Container();
}
