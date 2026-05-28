import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dasher_service.dart';

class DasherHomeScreen extends StatefulWidget {
  final String dasherId;

  const DasherHomeScreen({super.key, required this.dasherId});

  @override
  State<DasherHomeScreen> createState() => _DasherHomeScreenState();
}

class _DasherHomeScreenState extends State<DasherHomeScreen> {
  late DasherService _dasherService;
  int _currentIndex = 0;
  StreamSubscription? _availableOrdersSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dasherService = DasherService();
    _initNotifications();
    _listenForAvailableOrders();
  }

  Future<void> _initNotifications() async {
    await _dasherService.initializeNotifications(widget.dasherId);
  }

  void _listenForAvailableOrders() {
    _availableOrdersSubscription =
        _dasherService.listenAvailableOrders().listen(
      (notifications) {
        // Handle real-time updates
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  @override
  void dispose() {
    _availableOrdersSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dasher Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildAvailableOrdersTab(),
            _buildActiveOrdersTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Available',
          ),
          NavigationDestination(
            icon: Icon(Icons.delivery_dining),
            label: 'Active',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersTab() {
    return StreamBuilder<List<OrderPickupNotification>>(
      stream: _dasherService.listenAvailableOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;

        if (orders.isEmpty) {
          return const Center(
            child: Text('No available orders'),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Order #${order.orderId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Customer: ${order.customerName}'),
                    Text('Address: ${order.customerAddress}'),
                    Text('Total: \$${order.orderTotal.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _dasherService.acceptPickup(order.orderId),
                  child: const Text('Accept'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveOrdersTab() {
    return StreamBuilder<List<OrderPickupNotification>>(
      stream: _dasherService.listenActiveOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeOrders = snapshot.data!;

        if (activeOrders.isEmpty) {
          return const Center(child: Text('No active orders'));
        }

        return ListView.builder(
          itemCount: activeOrders.length,
          itemBuilder: (context, index) {
            final order = activeOrders[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Active Order #${order.orderId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Status: ${order.status}'),
                    Text('Customer: ${order.customerName}'),
                    Text('Address: ${order.customerAddress}'),
                    Text('Total: \$${order.orderTotal.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () =>
                      _dasherService.completeDelivery(order.orderId),
                  child: const Text('Complete'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profile Tab - No content yet'),
    );
  }
}
