import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/order.dart' as restaurant_app;
import 'package:restaurant_app/providers/auth_provider.dart';
import 'package:restaurant_app/providers/cart_provider.dart';
import 'package:restaurant_app/services/firestore_service.dart';
import 'package:restaurant_app/theme/design_tokens.dart';
import 'package:restaurant_app/screens/order_tracking_screen.dart';
import 'package:restaurant_app/screens/enhanced_cart_screen.dart';
import 'package:restaurant_app/models/menu_item.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late FirestoreService _firestoreService;
  late AuthProvider _authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
    _authProvider = Provider.of<AuthProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final customerId = _authProvider.user?.uid ?? 'customer1'; // Use 'customer1' for demo if not logged in

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: DesignTokens.primaryOrange,
      ),
      body: StreamBuilder<List<restaurant_app.Order>>(
        stream: _firestoreService.getOrdersByCustomerId(customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: DesignTokens.neutralGrey400,
                  ),
                  SizedBox(height: DesignTokens.space16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: DesignTokens.neutralGrey600,
                    ),
                  ),
                  SizedBox(height: DesignTokens.space8),
                  Text(
                    'Your order history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignTokens.neutralGrey500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort orders by order time (newest first)
          orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));

          return ListView.builder(
            padding: const EdgeInsets.all(DesignTokens.space16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(restaurant_app.Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.space16),
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.neutralGrey800,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: DesignTokens.space8),
              Text(
                'Ordered on ${_formatDate(order.orderTime)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
              const SizedBox(height: DesignTokens.space12),
              const Divider(),
              const SizedBox(height: DesignTokens.space8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.space4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.name}'),
                        Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
              const SizedBox(height: DesignTokens.space8),
              const Divider(),
              const SizedBox(height: DesignTokens.space8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: DesignTokens.primaryOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_canEditOrder(order.status))
                    TextButton.icon(
                      onPressed: () => _editOrderAsCart(context, order),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Cart'),
                      style: TextButton.styleFrom(
                        foregroundColor: DesignTokens.primaryOrange,
                      ),
                    ),
                  if (_canEditOrder(order.status))
                    const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingScreen(orderId: order.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Track Order'),
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(restaurant_app.OrderStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case restaurant_app.OrderStatus.confirmed:
        chipColor = DesignTokens.infoBlue;
        statusText = 'Confirmed';
        break;
      case restaurant_app.OrderStatus.pending:
        chipColor = DesignTokens.neutralGrey400;
        statusText = 'Pending';
        break;
      case restaurant_app.OrderStatus.preparing:
        chipColor = DesignTokens.warningOrange;
        statusText = 'Preparing';
        break;
      case restaurant_app.OrderStatus.readyForPickup:
        chipColor = DesignTokens.infoBlue;
        statusText = 'Ready for Pickup';
        break;
      case restaurant_app.OrderStatus.outForDelivery:
        chipColor = DesignTokens.primaryOrange;
        statusText = 'Out for Delivery';
        break;
      case restaurant_app.OrderStatus.delivered:
        chipColor = DesignTokens.successGreen;
        statusText = 'Delivered';
        break;
      case restaurant_app.OrderStatus.cancelled:
        chipColor = DesignTokens.errorRed;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _canEditOrder(restaurant_app.OrderStatus status) {
    return status == restaurant_app.OrderStatus.pending ||
           status == restaurant_app.OrderStatus.confirmed;
  }

  void _editOrderAsCart(BuildContext context, restaurant_app.Order order) {
     final cartProvider = Provider.of<CartProvider>(context, listen: false);
     
     // Clear current cart
     cartProvider.clear();
     
     // Add order items to cart
     for (final orderItem in order.items) {
       final menuItem = MenuItem(
         id: orderItem.id,
         name: orderItem.name,
         description: '', // Order items don't store description
         price: orderItem.price,
         category: '', // Order items don't store category
         imageUrl: orderItem.imageUrl,
         inStock: true,
       );
       
       // Add item multiple times for the quantity
       for (int i = 0; i < orderItem.quantity; i++) {
         cartProvider.addItem(menuItem);
       }
     }
     
     // Show success message
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Order items added to cart for editing'),
         backgroundColor: Colors.green,
       ),
     );
     
     // Navigate to cart screen
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => const EnhancedCartScreen(),
       ),
     );
   }
}