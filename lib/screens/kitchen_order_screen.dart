import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart' as restaurant_app;
import '../services/order_service.dart';

class KitchenOrderScreen extends StatefulWidget {
  const KitchenOrderScreen({super.key});

  @override
  State<KitchenOrderScreen> createState() => _KitchenOrderScreenState();
}

class _KitchenOrderScreenState extends State<KitchenOrderScreen> {
  late OrderService _orderService;
  late StreamSubscription<List<restaurant_app.Order>> _ordersSubscription;
  List<restaurant_app.Order> _activeOrders = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _orderService = Provider.of<OrderService>(context, listen: false);
    _loadKitchenOrders();
  }

  void _loadKitchenOrders() {
    // Listen to real-time orders for kitchen
    _ordersSubscription = _orderService.getKitchenOrders().listen(
      (List<restaurant_app.Order> orders) {
        setState(() {
          _activeOrders = orders.where((order) => 
            order.status == restaurant_app.OrderStatus.preparing ||
            order.status == restaurant_app.OrderStatus.readyForPickup
          ).toList();
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load orders: $error');
      }
    );
  }

  Future<void> _markOrderReady(restaurant_app.Order order) async {
    try {
      await _orderService.updateOrderStatus(
        order.id,
        restaurant_app.OrderStatus.readyForPickup,
        kitchen: true, // Flag to trigger cloud function
      );
    } catch (e) {
      _showError('Failed to mark order ready: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _ordersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4E5), // Warm kitchen color
      appBar: AppBar(
        title: const Text('Kitchen Orders'),
        backgroundColor: const Color(0xFF8D2E2E), // Delhi Nights red
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeOrders.isEmpty
              ? const Center(
                  child: Text(
                    "No active orders",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = _activeOrders[index];
                    return _KitchenOrderCard(
                      order: order,
                      onMarkReady: () => _markOrderReady(order),
                    );
                  },
                ),
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final restaurant_app.Order order;
  final VoidCallback onMarkReady;

  const _KitchenOrderCard({
    required this.order,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0,8)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.status == restaurant_app.OrderStatus.readyForPickup
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.status == restaurant_app.OrderStatus.readyForPickup 
                        ? "Ready" 
                        : "Preparing",
                    style: TextStyle(
                      color: order.status == restaurant_app.OrderStatus.readyForPickup
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Customer: ${order.customerName}', style: const TextStyle(fontSize: 14)),
            Text('Items: ${order.items.length}', style: const TextStyle(fontSize: 14)),
            Text('Total: \$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            ...order.items.take(3).map((item) => Text(
              "• ${item.name} x ${item.quantity}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )),
            if (order.items.length > 3) ...[
              Text('... +${order.items.length - 3} more items',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            const SizedBox(height: 12),
            if (order.status == restaurant_app.OrderStatus.preparing) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onMarkReady,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Ready for Pickup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D2E2E),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    Text('Dasher notified!'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Quick navigation helper
class KitchenRoute {
  static void navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KitchenOrderScreen()),
    );
  }
}