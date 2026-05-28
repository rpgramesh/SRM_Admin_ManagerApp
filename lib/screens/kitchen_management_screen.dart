import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../services/firestore_service.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../models/order.dart';

class KitchenManagementScreen extends StatefulWidget {
  const KitchenManagementScreen({super.key});

  @override
  State<KitchenManagementScreen> createState() => _KitchenManagementScreenState();
}

class _KitchenManagementScreenState extends State<KitchenManagementScreen> {
  late FirestoreService _firestoreService;
  late OrderService _orderService;
  late NotificationService _notificationService;
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'pending', 'preparing', 'ready'];

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
      appBar: AppBar(
        title: const Text('Kitchen Management'),
        backgroundColor: DesignTokens.restaurantOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      backgroundColor: DesignTokens.neutralGrey50,
      
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                selectedColor: DesignTokens.restaurantOrange.withAlpha((0.2 * 255).round()),
                checkmarkColor: DesignTokens.restaurantOrange,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<List<Order>>(
      stream: _firestoreService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No orders found'),
          );
        }

        List<Order> orders = snapshot.data!;
        
        // Filter orders based on selected filter
        if (_selectedFilter != 'all') {
          OrderStatus targetStatus;
          switch (_selectedFilter) {
            case 'pending':
              targetStatus = OrderStatus.pending;
              break;
            case 'preparing':
              targetStatus = OrderStatus.preparing;
              break;
            case 'ready':
              targetStatus = OrderStatus.readyForPickup;
              break;
            default:
              targetStatus = OrderStatus.pending;
          }
          orders = orders.where((order) => order.status == targetStatus).toList();
        }

        // Sort orders by priority (pending first, then by timestamp)
        orders.sort((a, b) {
          if (b.status == OrderStatus.readyForPickup && a.status != OrderStatus.readyForPickup) {
            return -1;
          }
          if (b.status == OrderStatus.pending && a.status != OrderStatus.pending) {
            return 1;
          }
          return b.orderTime.compareTo(a.orderTime);
        });

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Display 2 items per row
            childAspectRatio: 0.85, // Adjust height ratio
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.zero, // Remove margin since GridView handles spacing
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding for grid layout
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 6)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.customerName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'A\$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
            ),
            Text(
              _formatTime(order.orderTime),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            ),
            const SizedBox(height: 2),
            ...order.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 1),
              child: Text(
                '${item.quantity}x ${item.name}',
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            )),
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '+${order.items.length - 2} more',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: (
                order.status == OrderStatus.pending
                  ? ElevatedButton(
                      onPressed: () => _updateOrderStatus(order, OrderStatus.preparing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.restaurantOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: const Text('Start Preparing'),
                    )
                  : order.status == OrderStatus.preparing
                    ? ElevatedButton(
                        onPressed: () => _updateOrderStatus(order, OrderStatus.readyForPickup),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        child: const Text('Mark Ready'),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((0.1 * 255).round()),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Ready for Pickup',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      )
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All Orders';
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      default:
        return filter;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.lightBlue;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.readyForPickup:
        return Colors.green;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      await _orderService.updateOrderStatus(order.id, newStatus);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}