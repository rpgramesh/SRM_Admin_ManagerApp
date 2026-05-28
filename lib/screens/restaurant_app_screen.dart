import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../services/firestore_service.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../models/order.dart' as restaurant_app_models;
import 'kitchen_management_screen.dart';

class RestaurantAppScreen extends StatefulWidget {
  const RestaurantAppScreen({super.key});

  @override
  State<RestaurantAppScreen> createState() => _RestaurantAppScreenState();
}

class _RestaurantAppScreenState extends State<RestaurantAppScreen> {
  int _selectedIndex = 0;
  bool _isRestaurantOpen = true;
  late FirestoreService _firestoreService;
  late OrderService _orderService;
  late NotificationService _notificationService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
    _orderService = Provider.of<OrderService>(context);
    _notificationService = Provider.of<NotificationService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: DesignTokens.restaurantOrange,
        unselectedItemColor: DesignTokens.neutralGrey500,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Kitchen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const KitchenManagementScreen();
      case 2:
        return _buildMenuScreen();
      case 3:
        return _buildAnalyticsScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRestaurantStatus(),
          const SizedBox(height: DesignTokens.space24),
          _buildTodayStats(),
          const SizedBox(height: DesignTokens.space24),
          _buildRecentOrders(),
          const SizedBox(height: DesignTokens.space24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildRestaurantStatus() {
    return Card(
      elevation: DesignTokens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  decoration: BoxDecoration(
                    color: DesignTokens.restaurantOrange.withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 32,
                    color: DesignTokens.restaurantOrange,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delhi Nights Restaurant',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.neutralGrey800,
                        ),
                      ),
                      Text(
                        'Restaurant Management',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isRestaurantOpen,
                  onChanged: (value) => setState(() => _isRestaurantOpen = value),
                  activeThumbColor: DesignTokens.successGreen,
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.space12),
              decoration: BoxDecoration(
                color: _isRestaurantOpen 
                    ? DesignTokens.successGreen.withAlpha((0.1 * 255).round())
                    : DesignTokens.errorRed.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                border: Border.all(
                  color: _isRestaurantOpen 
                      ? DesignTokens.successGreen
                      : DesignTokens.errorRed,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isRestaurantOpen ? Icons.store : Icons.store_mall_directory_outlined,
                    color: _isRestaurantOpen 
                        ? DesignTokens.successGreen
                        : DesignTokens.errorRed,
                    size: 16,
                  ),
                  const SizedBox(width: DesignTokens.space8),
                  Text(
                    _isRestaurantOpen ? 'Restaurant is OPEN' : 'Restaurant is CLOSED',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isRestaurantOpen 
                          ? DesignTokens.successGreen
                          : DesignTokens.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey800,
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Orders',
                value: '45',
                icon: Icons.receipt_long,
                color: DesignTokens.restaurantOrange,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                title: 'Revenue',
                value: 'A\$12.5K',
                icon: Icons.currency_rupee,
                color: DesignTokens.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Avg Time',
                value: '28 min',
                icon: Icons.timer,
                color: DesignTokens.warningOrange,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                title: 'Rating',
                value: '4.8',
                icon: Icons.star,
                color: DesignTokens.warningOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey800,
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _OrderListItem(
              orderId: 'ORD-${2000 + index}',
              customerName: 'Customer ${index + 1}',
              items: '${index + 2} items',
              amount: 'A\$${450 + index * 120}',
              status: index == 0 ? 'Preparing' : index == 1 ? 'Ready' : 'Delivered',
              time: '${10 + index * 5} min ago',
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey800,
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: DesignTokens.space12,
          mainAxisSpacing: DesignTokens.space12,
          children: [
            _QuickActionCard(
              title: 'Add Menu Item',
              icon: Icons.add_circle,
              onTap: () => _addMenuItem(),
            ),
            _QuickActionCard(
              title: 'View Reports',
              icon: Icons.bar_chart,
              onTap: () => _viewReports(),
            ),
            _QuickActionCard(
              title: 'Staff Management',
              icon: Icons.people,
              onTap: () => _manageStaff(),
            ),
            _QuickActionCard(
              title: 'Inventory',
              icon: Icons.inventory,
              onTap: () => _manageInventory(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersScreen() {
    return StreamBuilder<List<restaurant_app_models.Order>>(
      stream: _firestoreService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        final orders = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.space16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: DesignTokens.space16),
              elevation: DesignTokens.elevationSmall,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.neutralGrey800,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Text('Customer: ${order.customerName}'),
                    Text('Address: ${order.customerAddress}'),
                    Text('Phone: ${order.customerPhone}'),
                    const SizedBox(height: DesignTokens.space8),
                    ...order.items.map((item) => Text('${item.quantity}x ${item.name} - \$${item.price.toStringAsFixed(2)}')),
                    const SizedBox(height: DesignTokens.space8),
                    Text(
                      'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${order.status.name.toUpperCase()}'),
                        DropdownButton<restaurant_app_models.OrderStatus>(
                          value: order.status,
                          onChanged: (restaurant_app_models.OrderStatus? newStatus) async {
                            if (newStatus != null) {
                              try {
                                await _orderService.updateOrderStatus(order.id, newStatus);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order status updated to ${newStatus.name}')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error updating order status: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          items: restaurant_app_models.OrderStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.name.toUpperCase()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuScreen() {
    return const Center(
      child: Text(
        'Menu Management\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: DesignTokens.neutralGrey600,
        ),
      ),
    );
  }

  Widget _buildAnalyticsScreen() {
    return const Center(
      child: Text(
        'Analytics Dashboard\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: DesignTokens.neutralGrey600,
        ),
      ),
    );
  }

  String _getOrderStatus(int index) {
    switch (index % 4) {
      case 0:
        return 'Preparing';
      case 1:
        return 'Ready';
      case 2:
        return 'Out for Delivery';
      default:
        return 'Delivered';
    }
  }

  void _addMenuItem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Menu Item functionality coming soon!'),
        backgroundColor: DesignTokens.restaurantOrange,
      ),
    );
  }

  void _viewReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening detailed reports...'),
        backgroundColor: DesignTokens.restaurantOrange,
      ),
    );
  }

  void _manageStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staff Management feature coming soon!'),
        backgroundColor: DesignTokens.restaurantOrange,
      ),
    );
  }

  void _manageInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory Management feature coming soon!'),
        backgroundColor: DesignTokens.restaurantOrange,
      ),
    );
  }

  void _changeOrderStatus(String orderId, String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order $orderId status changed to $status'),
        backgroundColor: DesignTokens.successGreen,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: DesignTokens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignTokens.neutralGrey800,
              ),
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: DesignTokens.neutralGrey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  const _OrderListItem({
    required this.orderId,
    required this.customerName,
    required this.items,
    required this.amount,
    required this.status,
    required this.time,
  });

  final String orderId;
  final String customerName;
  final String items;
  final String amount;
  final String status;
  final String time;

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.space8),
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        orderId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignTokens.neutralGrey600,
                    ),
                  ),
                  Text(
                    items,
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.neutralGrey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return DesignTokens.warningOrange;
      case 'ready':
        return DesignTokens.successGreen;
      case 'delivered':
        return DesignTokens.infoBlue;
      default:
        return DesignTokens.neutralGrey500;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: DesignTokens.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                decoration: BoxDecoration(
                  color: DesignTokens.restaurantOrange.withAlpha((0.1 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: DesignTokens.restaurantOrange,
                  size: 28,
                ),
              ),
              const SizedBox(height: DesignTokens.space12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DesignTokens.neutralGrey700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.isSelected,
  });

  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space12,
        vertical: DesignTokens.space8,
      ),
      decoration: BoxDecoration(
        color: isSelected 
            ? DesignTokens.restaurantOrange
            : DesignTokens.neutralGrey100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: isSelected 
              ? DesignTokens.restaurantOrange
              : DesignTokens.neutralGrey300,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected 
              ? DesignTokens.neutralWhite
              : DesignTokens.neutralGrey700,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.customerName,
    required this.items,
    required this.amount,
    required this.status,
    required this.orderTime,
    required this.onStatusChange,
  });

  final String orderId;
  final String customerName;
  final List<String> items;
  final String amount;
  final String status;
  final String orderTime;
  final Function(String) onStatusChange;

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(status);

    return Card(
      elevation: DesignTokens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              customerName,
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey600,
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            Wrap(
              spacing: DesignTokens.space8,
              runSpacing: DesignTokens.space4,
              children: items.map((item) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space8,
                  vertical: DesignTokens.space2,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.neutralGrey100,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey700,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: DesignTokens.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 16,
                      color: DesignTokens.neutralGrey600,
                    ),
                    Text(
                      amount.substring(2), // Remove A\$ symbol as we have the icon
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.neutralGrey800,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (status == 'Preparing')
                      ElevatedButton(
                        onPressed: () => onStatusChange('Ready'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.successGreen,
                          foregroundColor: DesignTokens.neutralWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space12,
                            vertical: DesignTokens.space8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                          ),
                        ),
                        child: const Text(
                          'Mark Ready',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    if (status == 'Ready')
                       ElevatedButton(
                         onPressed: () => onStatusChange('Out for Delivery'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: DesignTokens.infoBlue,
                           foregroundColor: DesignTokens.neutralWhite,
                           padding: const EdgeInsets.symmetric(
                             horizontal: DesignTokens.space12,
                             vertical: DesignTokens.space8,
                           ),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                           ),
                         ),
                         child: const Text(
                           'Out for Delivery',
                           style: TextStyle(fontSize: 12),
                         ),
                       ),
                   ],
                 ),
               ],
             ),
           ],
         ),
       ),
     );
   }

   Color _getStatusColor(String status) {
     switch (status.toLowerCase()) {
       case 'preparing':
         return DesignTokens.warningOrange;
       case 'ready':
         return DesignTokens.successGreen;
       case 'out for delivery':
         return DesignTokens.infoBlue;
       case 'delivered':
         return DesignTokens.dasherGreen;
       default:
         return DesignTokens.neutralGrey500;
     }
   }
 }