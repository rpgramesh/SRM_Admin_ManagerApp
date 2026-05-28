import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/design_tokens.dart';
import '../services/firestore_service.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../services/dasher_assignment_service.dart';
import '../models/order.dart';
import '../models/order.dart' as restaurant_app;
import 'dasher_delivery_tracking_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    as google_maps_flutter;

class DasherAppScreen extends StatefulWidget {
  const DasherAppScreen({super.key});

  @override
  State<DasherAppScreen> createState() => _DasherAppScreenState();
}

class _DasherAppScreenState extends State<DasherAppScreen> {
  bool _isOnline = false;
  int _selectedIndex = 0;
  late FirestoreService _firestoreService;
  late OrderService _orderService;
  late NotificationService _notificationService;
  late DasherAssignmentService _dasherAssignmentService;

  Stream<DocumentSnapshot>? _dasherAnalyticsStream;
  Stream<QuerySnapshot>? _todayDeliveriesStream;
  String? _currentDasherId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
    _orderService = Provider.of<OrderService>(context);
    _notificationService = Provider.of<NotificationService>(context);
    _dasherAssignmentService = Provider.of<DasherAssignmentService>(context);
  
    // Initialize real-time data streams
    final dasherId = FirebaseAuth.instance.currentUser?.uid;
    
    if (dasherId != null) {
      _currentDasherId = dasherId;
      _dasherAnalyticsStream = FirebaseFirestore.instance
          .collection('analytics')
          .doc('dashers')
          .collection(dasherId)
          .doc('performance')
          .snapshots();
  
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
    _todayDeliveriesStream = FirebaseFirestore.instance
        .collection('orders')
        .where('assignedDasherId', isEqualTo: dasherId)
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: startOfDay)
        .where('deliveredAt', isLessThanOrEqualTo: endOfDay)
        .snapshots();
  } // ADD THIS CLOSING BRACE
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _selectedIndex == 0 ? _buildDashboard() : _buildOrdersList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: DesignTokens.dasherBlue,
        unselectedItemColor: DesignTokens.neutralGrey500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: DesignTokens.space24),
          _buildStatsCards(),
          const SizedBox(height: DesignTokens.space24),
          _buildEarningsSection(),
          const SizedBox(height: DesignTokens.space24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      DesignTokens.dasherBlue.withAlpha((0.1 * 255).round()),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: DesignTokens.dasherBlue,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back, DelhiDasher!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey800,
                        ),
                      ),
                      Text(
                        'Ready to earn today?',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                  activeThumbColor: DesignTokens.successGreen,
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.space12),
              decoration: BoxDecoration(
                color: _isOnline
                    ? DesignTokens.successGreen.withAlpha((0.1 * 255).round())
                    : DesignTokens.errorRed.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                border: Border.all(
                  color: _isOnline
                      ? DesignTokens.successGreen
                      : DesignTokens.errorRed,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnline
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _isOnline
                        ? DesignTokens.successGreen
                        : DesignTokens.errorRed,
                    size: 16,
                  ),
                  const SizedBox(width: DesignTokens.space8),
                  Text(
                    _isOnline ? 'You are ONLINE' : 'You are OFFLINE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isOnline
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

  Widget _buildStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _todayDeliveriesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading stats'));
        }

        final todayDeliveries = snapshot.data?.docs.length ?? 0;
        double todayEarnings = 0.0;

        if (snapshot.hasData) {
          for (var orderDoc in snapshot.data!.docs) {
            todayEarnings +=
                (orderDoc.data() as Map<String, dynamic>)['deliveryFee'] ?? 0.0;
          }
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Today\'s Deliveries',
                value: todayDeliveries.toString(),
                icon: Icons.delivery_dining,
                color: DesignTokens.dasherBlue,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                title: 'Today\'s Earnings',
                value: 'A\$${todayEarnings.toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
                color: DesignTokens.successGreen,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEarningsSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _dasherAnalyticsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading earnings data');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final weeklyEarnings = (data['weeklyEarnings'] ?? 5250.0) as double;

        return Card(
          elevation: DesignTokens.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Earnings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey800,
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesignTokens.dasherBlue.withAlpha((0.1 * 255).round()),
                        DesignTokens.dasherBlue.withAlpha((0.05 * 255).round()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      'A\$${weeklyEarnings.toStringAsFixed(0)}\nThis Week',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.dasherBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Vehicle Status',
                icon: Icons.motorcycle,
                onTap: () => _showVehicleStatus(),
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _QuickActionCard(
                title: 'Earnings Report',
                icon: Icons.bar_chart,
                onTap: () => _showEarningsReport(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    // Using proper order streams from dasher service
    const String dummyDasherId = 'dasher_001';
    print(dummyDasherId);

    return StreamBuilder<List<restaurant_app.Order>>(
      stream: _firestoreService.getOrders().map((orders) => orders),
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
        final orders = snapshot.data!
            .where((order) => order.status == OrderStatus.readyForPickup)
            .toList();
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
                      'Order ID: ${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.neutralGrey800,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Text('Customer: ${order.customerName}'),
                    const SizedBox(height: DesignTokens.space8),
                    Text('Address: ${order.customerAddress}'),
                    const SizedBox(height: DesignTokens.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${order.status.name.toUpperCase()}'),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _navigateToDeliveryTracking(order.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignTokens.dasherBlue,
                                foregroundColor: DesignTokens.neutralWhite,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.space12,
                                  vertical: DesignTokens.space8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusSmall),
                                ),
                              ),
                              child: const Text('Track',
                                  style: TextStyle(fontSize: 8)),
                            ),
                            const SizedBox(width: DesignTokens.space8),
                            // Expanded(
                            //   // below code disabled by RAM
                            //   child: DropdownButton<OrderStatus>(
                            //     value: order.status,
                            //     style: const TextStyle(
                            //       fontSize: 8,
                            //       fontWeight: FontWeight.bold,
                            //       color: DesignTokens.neutralGrey800,
                            //     ),
                            //     onChanged: (OrderStatus? newStatus) async {
                            //       if (newStatus != null) {
                            //         try {
                            //           await _orderService.updateOrderStatus(
                            //               order.id, newStatus);
                            //           if (!mounted) return;
                            //           ScaffoldMessenger.of(context)
                            //               .showSnackBar(SnackBar(
                            //                   content: Text(
                            //                       'Order status updated to ${newStatus.name}')));
                            //         } catch (e) {
                            //           if (!mounted) return;
                            //           ScaffoldMessenger.of(context)
                            //               .showSnackBar(SnackBar(
                            //                   content: Text(
                            //                       'Error updating order status: $e')));
                            //         }
                            //       }
                            //     },
                            //     items: OrderStatus.values
                            //         .where((status) =>
                            //             status != OrderStatus.cancelled)
                            //         .map((status) {
                            //       return DropdownMenuItem(
                            //         value: status,
                            //         child: Text(status.name.toUpperCase()),
                            //       );
                            //     }).toList(),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    SizedBox(
                      height: 200,
                      child: google_maps_flutter.GoogleMap(
                        initialCameraPosition:
                            const google_maps_flutter.CameraPosition(
                          target: google_maps_flutter.LatLng(0.0,
                              0.0), // Placeholder as we don't have location data
                          zoom: 12,
                        ),
                        markers: {
                          google_maps_flutter.Marker(
                            markerId:
                                const google_maps_flutter.MarkerId('pickup'),
                            position: const google_maps_flutter.LatLng(0.0,
                                0.0), // Placeholder as we don't have location data
                            infoWindow: const google_maps_flutter.InfoWindow(
                                title: 'Pickup Location'),
                            icon: google_maps_flutter.BitmapDescriptor
                                .defaultMarkerWithHue(google_maps_flutter
                                    .BitmapDescriptor.hueGreen),
                          ),
                          google_maps_flutter.Marker(
                            markerId:
                                const google_maps_flutter.MarkerId('delivery'),
                            position: const google_maps_flutter.LatLng(0.0,
                                0.0), // Placeholder as we don't have location data
                            infoWindow: const google_maps_flutter.InfoWindow(
                                title: 'Delivery Location'),
                            icon: google_maps_flutter.BitmapDescriptor
                                .defaultMarkerWithHue(google_maps_flutter
                                    .BitmapDescriptor.hueBlue),
                          ),
                        },
                      ),
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

  void _showVehicleStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vehicle status: All systems operational'),
        backgroundColor: DesignTokens.successGreen,
      ),
    );
  }

  void _showEarningsReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening earnings report...'),
        backgroundColor: DesignTokens.dasherBlue,
      ),
    );
  }

  void _acceptOrder(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order $orderId accepted!'),
        backgroundColor: DesignTokens.successGreen,
      ),
    );
  }

  void _navigateToDeliveryTracking(String orderId) async {
    try {
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final routes = await firestoreService.getDeliveryRoutes(orderId).first;

      if (routes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery route not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final deliveryRouteId = routes.first.id;
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DasherDeliveryTrackingScreen(
            deliveryRouteId: deliveryRouteId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading delivery route: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
        elevation: DesignTokens.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: DesignTokens.dasherBlue,
              ),
              const SizedBox(height: DesignTokens.space8),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.restaurant,
    required this.distance,
    required this.earnings,
    required this.estimatedTime,
    required this.onAccept,
  });

  final String orderId;
  final String restaurant;
  final String distance;
  final String earnings;
  final String estimatedTime;
  final VoidCallback onAccept;

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
                    color: DesignTokens.successGreen
                        .withAlpha((0.1 * 255).round()),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    earnings,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.successGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              restaurant,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DesignTokens.neutralGrey700,
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: DesignTokens.neutralGrey500,
                ),
                const SizedBox(width: DesignTokens.space4),
                Text(
                  distance,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey600,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Icon(
                  Icons.timer,
                  size: 16,
                  color: DesignTokens.neutralGrey500,
                ),
                const SizedBox(width: DesignTokens.space4),
                Text(
                  estimatedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.dasherBlue,
                  foregroundColor: DesignTokens.neutralWhite,
                  padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                ),
                child: const Text(
                  'Accept Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
