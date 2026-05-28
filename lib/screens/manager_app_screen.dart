import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Removed for web compatibility
// import 'package:restaurant_app/services/stripe_service.dart'; // Removed for web compatibility
import 'package:restaurant_app/services/manager_service.dart';

// Screen imports
// import 'package:restaurant_app/screens_/more_screen.dart';
// import 'package:restaurant_app/screens/menu_screen.dart';
// import 'package:restaurant_app/screens/offer_screen.dart';

// Staff management imports
import 'package:restaurant_app/screens/add_restaurant_screen.dart';
import 'package:restaurant_app/screens/edit_restaurant_screen.dart';
import 'package:restaurant_app/screens/add_dasher_screen.dart';
import 'package:restaurant_app/screens/edit_dasher_screen.dart';
import 'package:restaurant_app/screens/staff_management/roster_screen.dart';
import 'package:restaurant_app/screens/staff_management/add_shift_screen.dart';

class ManagerAppScreen extends StatefulWidget {
  const ManagerAppScreen({super.key});

  @override
  State<ManagerAppScreen> createState() => _ManagerAppScreenState();
}

class _ManagerAppScreenState extends State<ManagerAppScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const _RestaurantsScreen(),
    const _DashersScreen(),
    const _AnalyticsScreen(),
    const RosterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: EcosystemThemes.getManagerAppTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manager Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: DesignTokens.managerBlue,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        floatingActionButton: _buildFloatingActionButton(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: DesignTokens.managerBlue,
          unselectedItemColor: DesignTokens.neutralGrey600,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'Restaurants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              label: 'Dashers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Roster',
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 1:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddRestaurantScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Restaurant'),
          backgroundColor: DesignTokens.managerBlue,
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddDasherScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Dasher'),
          backgroundColor: DesignTokens.managerBlue,
        );
      case 4:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddShiftScreen(initialDate: DateTime.now()),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Shift'),
          backgroundColor: DesignTokens.managerBlue,
        );
      default:
        return null;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.managerBlue
              : DesignTokens.neutralGrey100,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? DesignTokens.neutralWhite
                : DesignTokens.neutralGrey700,
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
  final bool? isPositive;

  // const _MetricCard({
  //   required this.title,
  //   required this.value,
  //   required this.icon,
  //   required this.color,
  //   this.change,
  //   this.isPositive,
  // });

  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
    this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color:
                  DesignTokens.neutralGrey900.withAlpha((0.08 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space8),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.1 * 255).round()),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: DesignTokens.successGreen,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: DesignTokens.neutralGrey900,
              ),
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DesignTokens.neutralGrey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen();

  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  final ManagerService _managerService = ManagerService();

  void _addRestaurant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRestaurantScreen(),
      ),
    );
  }

  void _navigateToActiveRestaurants() {
    Navigator.pushNamed(context, '/active_restaurants');
  }

  void _navigateToActiveDashers() {
    Navigator.pushNamed(context, '/active_dashers');
  }

  void _navigateToTodayOrders() {
    Navigator.pushNamed(context, '/today_orders');
  }

  void _navigateToRevenueDetails() {
    Navigator.pushNamed(context, '/revenue_details');
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, '/view_reports');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _managerService.getRealTimeDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final activeRestaurants = data['activeRestaurants'] ?? 0;
          final activeDashers = data['activeDashers'] ?? 0;
          final todayOrders = data['todayOrders'] ?? 0;
          final totalRevenue = (data['totalRevenue'] ?? 0.0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      title: 'Active Restaurants',
                      value: activeRestaurants.toString(),
                      trend: '+2',
                      trendPositive: true,
                      icon: Icons.restaurant,
                      color: DesignTokens.restaurantRed,
                      onTap: _navigateToActiveRestaurants,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: _OverviewCard(
                      title: 'Active Dashers',
                      value: activeDashers.toString(),
                      trend: '+8',
                      trendPositive: true,
                      icon: Icons.delivery_dining,
                      color: DesignTokens.dasherGreen,
                      onTap: _navigateToActiveDashers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space12),
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      title: 'Today\'s Orders',
                      value: todayOrders.toString(),
                      trend: '+12%',
                      trendPositive: true,
                      icon: Icons.shopping_bag,
                      color: DesignTokens.brandPrimary,
                      onTap: _navigateToTodayOrders,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: _OverviewCard(
                      title: 'Revenue',
                      value: 'A\$${totalRevenue.toStringAsFixed(0)}',
                      trend: '-3%',
                      trendPositive: false,
                      icon: Icons.attach_money,
                      color: DesignTokens.warningOrange,
                      onTap: _navigateToRevenueDetails,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.neutralGrey900,
                    ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Add Restaurant',
                      icon: Icons.add_business,
                      color: DesignTokens.restaurantRed,
                      onTap: () => _addRestaurant(context),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'View Reports',
                      icon: Icons.analytics,
                      color: DesignTokens.brandPrimary,
                      onTap: _navigateToReports,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'Online':
      case 'Open':
        return DesignTokens.successGreen;
      case 'Busy':
      case 'Delivering':
        return DesignTokens.warningOrange;
      case 'Offline':
      case 'Closed':
        return DesignTokens.dangerRed;
      default:
        return DesignTokens.neutralGrey500;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: DesignTokens.space4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralGrey900.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: DesignTokens.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.space8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: isPositive
                    ? DesignTokens.successGreen
                    : DesignTokens.dangerRed,
              ),
              const SizedBox(width: DesignTokens.space4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isPositive
                      ? DesignTokens.successGreen
                      : DesignTokens.dangerRed,
                ),
              ),
              const Text(
                ' vs last month',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.neutralGrey500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestaurantsScreen extends StatelessWidget {
  const _RestaurantsScreen();

  @override
  Widget build(BuildContext context) {
    final ManagerService managerService = ManagerService();

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(DesignTokens.space16),
          color: DesignTokens.neutralWhite,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMedium),
                      borderSide:
                          BorderSide(color: DesignTokens.neutralGrey300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Restaurant List with Real-time Data
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: managerService.getRestaurants(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading restaurants: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final restaurants = snapshot.data ?? [];

              if (restaurants.isEmpty) {
                return const Center(
                  child: Text(
                    'No restaurants found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.space16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return _RestaurantCard(
                    name: restaurant['name'] ?? 'Unknown Restaurant',
                    cuisine: restaurant['cuisine_type'] ?? 'Unknown Cuisine',
                    rating: (restaurant['rating'] as num?)?.toDouble() ?? 0.0,
                    orders: restaurant['total_reviews'] ?? 0,
                    revenue:
                        (restaurant['delivery_fee'] as num?)?.toDouble() ?? 0.0,
                    status: restaurant['isActive'] == true ? 'Open' : 'Closed',
                    restaurant: restaurant,
                    onTap: () => _editRestaurant(context, restaurant),
                    onStatusToggle: (isActive) => _toggleRestaurantStatus(
                      context,
                      restaurant['id'] as String,
                      isActive,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  static void _editRestaurant(
      BuildContext context, Map<String, dynamic> restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRestaurantScreen(restaurant: restaurant),
      ),
    );
  }

  static void _toggleRestaurantStatus(
      BuildContext context, String restaurantId, bool isActive) async {
    try {
      final managerService = ManagerService();
      await managerService.updateRestaurantStatus(restaurantId, isActive);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Restaurant status updated to ${isActive ? "Open" : "Closed"}'),
          backgroundColor:
              isActive ? DesignTokens.successGreen : DesignTokens.dangerRed,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: DesignTokens.dangerRed,
        ),
      );
    }
  }
}

class _DashersScreen extends StatefulWidget {
  const _DashersScreen();

  @override
  State<_DashersScreen> createState() => _DashersScreenState();
}

class _DashersScreenState extends State<_DashersScreen> {
  String _selectedFilter = 'All';
  final ManagerService managerService = ManagerService();
  final List<bool> _selectedFilters = [
    true,
    false,
    false,
    false
  ]; // All, Online, Available, Offline

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Filter Toggle Buttons
        Container(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: ToggleButtons(
            isSelected: _selectedFilters,
            onPressed: (int index) {
              setState(() {
                // Reset all selections
                for (int i = 0; i < _selectedFilters.length; i++) {
                  _selectedFilters[i] = i == index;
                }

                // Update selected filter
                switch (index) {
                  case 0:
                    _selectedFilter = 'All';
                    break;
                  case 1:
                    _selectedFilter = 'Online';
                    break;
                  case 2:
                    _selectedFilter = 'Available';
                    break;
                  case 3:
                    _selectedFilter = 'Offline';
                    break;
                }
              });
            },
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            selectedBorderColor: DesignTokens.managerBlue,
            selectedColor: DesignTokens.neutralWhite,
            fillColor: DesignTokens.managerBlue,
            color: DesignTokens.neutralGrey700,
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignTokens.space12),
                child: Text('All'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignTokens.space12),
                child: Text('Online'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignTokens.space12),
                child: Text('Available'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignTokens.space12),
                child: Text('Offline'),
              ),
            ],
          ),
        ),

        // Dashers List with Real-time Data
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: managerService.getDashers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading dashers: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final allDashers = snapshot.data ?? [];
              final filteredDashers = _filterDashers(allDashers);

              if (filteredDashers.isEmpty) {
                return Center(
                  child: Text(
                    _selectedFilter == 'All'
                        ? 'No dashers found'
                        : 'No $_selectedFilter dashers found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space16),
                itemCount: filteredDashers.length,
                itemBuilder: (context, index) {
                  final dasher = filteredDashers[index];
                  return _DasherCard(
                    name: dasher['name'] ?? 'Unknown Dasher',
                    rating: (dasher['rating'] as num?)?.toDouble() ?? 0.0,
                    deliveries: dasher['totalDeliveries'] ?? 0,
                    earnings:
                        (dasher['totalEarnings'] as num?)?.toDouble() ?? 0.0,
                    status: _getDasherStatus(dasher),
                    onTap: () => _viewDasherDetails(context, dasher),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filterDashers(
      List<Map<String, dynamic>> dashers) {
    switch (_selectedFilter) {
      case 'Online':
        return dashers
            .where((dasher) =>
                dasher['isOnline'] == true && dasher['isAvailable'] == true)
            .toList();
      case 'Available':
        return dashers
            .where((dasher) => dasher['isAvailable'] == true)
            .toList();
      case 'Offline':
        return dashers.where((dasher) => dasher['isOnline'] != true).toList();
      case 'All':
      default:
        return dashers;
    }
  }

  static String _getDasherStatus(Map<String, dynamic> dasher) {
    if (dasher['isOnline'] == true) {
      return dasher['isAvailable'] == true ? 'Online' : 'Delivering';
    }
    return 'Offline';
  }

  static void _viewDasherDetails(
      BuildContext context, Map<String, dynamic> dasher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDasherScreen(dasher: dasher),
      ),
    );
  }
}

class _AnalyticsScreen extends StatelessWidget {
  const _AnalyticsScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.neutralGrey900,
                ),
          ),
          const SizedBox(height: DesignTokens.space24),

          // Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: DesignTokens.neutralWhite,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neutralGrey900.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: DesignTokens.neutralGrey400,
                  ),
                  SizedBox(height: DesignTokens.space8),
                  Text(
                    'Revenue Chart',
                    style: TextStyle(
                      color: DesignTokens.neutralGrey600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space24),

          // Metrics Grid
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Average Order Value',
                  value: 'A\$24.50',
                  icon: Icons.attach_money,
                  color: DesignTokens.successGreen,
                  change: '+5.2%',
                  isPositive: true,
                ),
              ),
              SizedBox(width: DesignTokens.space12),
              Expanded(
                child: _MetricCard(
                  title: 'Delivery Time',
                  value: '28 min',
                  icon: Icons.delivery_dining,
                  color: DesignTokens.brandPrimary,
                  change: '-2.1 min',
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Customer Satisfaction',
                  value: '4.7/5',
                  icon: Icons.star,
                  color: DesignTokens.warningOrange,
                  change: '+0.1',
                  isPositive: true,
                ),
              ),
              SizedBox(width: DesignTokens.space12),
              Expanded(
                child: _MetricCard(
                  title: 'Order Completion Rate',
                  value: '94.5%',
                  icon: Icons.check_circle,
                  color: DesignTokens.successGreen,
                  change: '-1.2%',
                  isPositive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper Widgets

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool trendPositive;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.trendPositive,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.neutralGrey900.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: trendPositive
                        ? DesignTokens.successGreen.withOpacity(0.1)
                        : DesignTokens.dangerRed.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trendPositive
                          ? DesignTokens.successGreen
                          : DesignTokens.dangerRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: DesignTokens.neutralGrey900,
              ),
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DesignTokens.neutralGrey900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralGrey900.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ActivityItem(
            title: 'New restaurant "Pizza Palace" joined',
            time: '2 hours ago',
            icon: Icons.restaurant,
            color: DesignTokens.restaurantRed,
          ),
          _ActivityItem(
            title: 'Dasher "John D." completed 100 deliveries',
            time: '4 hours ago',
            icon: Icons.delivery_dining,
            color: DesignTokens.dasherGreen,
          ),
          _ActivityItem(
            title: 'Revenue milestone reached: A\$50K',
            time: '1 day ago',
            icon: Icons.celebration,
            color: DesignTokens.brandPrimary,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.neutralGrey900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final String name;
  final String cuisine;
  final double rating;
  final int orders;
  final double revenue;
  final String status;
  final VoidCallback onTap;
  final Map<String, dynamic> restaurant;
  final Function(bool) onStatusToggle;

  const _RestaurantCard({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.orders,
    required this.revenue,
    required this.status,
    required this.onTap,
    required this.restaurant,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = status == 'Open';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.space12),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.neutralGrey900.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: DesignTokens.restaurantRed.withOpacity(0.1),
                  child: const Icon(
                    Icons.restaurant,
                    color: DesignTokens.restaurantRed,
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        cuisine,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: isOpen,
                      onChanged: (value) {
                        onStatusToggle(value);
                      },
                      activeThumbColor: DesignTokens.successGreen,
                      inactiveThumbColor: DesignTokens.dangerRed,
                      inactiveTrackColor:
                          DesignTokens.dangerRed.withOpacity(0.3),
                    ),
                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOpen
                            ? DesignTokens.successGreen
                            : DesignTokens.dangerRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.star,
                  label: rating.toString(),
                  color: DesignTokens.warningOrange,
                ),
                const SizedBox(width: DesignTokens.space8),
                _InfoChip(
                  icon: Icons.shopping_bag,
                  label: '$orders orders',
                  color: DesignTokens.brandPrimary,
                ),
                const SizedBox(width: DesignTokens.space8),
                _InfoChip(
                  icon: Icons.attach_money,
                  label: 'A\$${revenue.toInt()}',
                  color: DesignTokens.successGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DasherCard extends StatelessWidget {
  final String name;
  final double rating;
  final int deliveries;
  final double earnings;
  final String status;
  final VoidCallback onTap;
  //final Color Function(String) getStatusColor;

  const _DasherCard({
    required this.name,
    required this.rating,
    required this.deliveries,
    required this.earnings,
    required this.status,
    required this.onTap,
    //required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.space12),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.neutralGrey900.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: DesignTokens.dasherGreen.withOpacity(0.1),
                  child: const Icon(
                    Icons.delivery_dining,
                    color: DesignTokens.dasherGreen,
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: DesignTokens.warningOrange,
                          ),
                          const SizedBox(width: DesignTokens.space4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: DesignTokens.neutralGrey700,
                            ),
                          ),
                        ],
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
                    //color: getStatusColor(status).withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      //color: getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.delivery_dining,
                  label: '$deliveries trips',
                  color: DesignTokens.dasherGreen,
                ),
                const SizedBox(width: DesignTokens.space8),
                _InfoChip(
                  icon: Icons.attach_money,
                  label: 'A\$${earnings.toInt()}',
                  color: DesignTokens.successGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
