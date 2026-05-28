import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart' as restaurant_app;

class TestOrdersScreen extends StatefulWidget {
  const TestOrdersScreen({super.key});

  @override
  State<TestOrdersScreen> createState() => _TestOrdersScreenState();
}

class _TestOrdersScreenState extends State<TestOrdersScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _orderIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Order Workflow'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Test Order Status Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Mark Order Ready for Pickup',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _orderIdController,
                      decoration: const InputDecoration(
                        labelText: 'Order ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final orderId = _orderIdController.text.trim();
                        if (orderId.isNotEmpty) {
                          try {
                            await _orderService.markOrderReadyForPickup(orderId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Order marked ready')),
                            );
                            _orderIdController.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      child: const Text('Ready for Pickup'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Check All Orders
            Expanded(
              child: Card(
                child: StreamBuilder<List<restaurant_app.Order>>(
                  stream: _orderService.getAllOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final orders = snapshot.data!;

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return ListTile(
                          title: Text('Order #${order.id}'),
                          subtitle: Text(order.status.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _orderIdController.text = order.id;
                                },
                              ),
                              Text(
                                order.status == 
                                        restaurant_app.OrderStatus.readyForPickup 
                                    ? '✅ Ready' 
                                    : '⏳ Pending',
                                style: TextStyle(
                                  color: order.status == 
                                          restaurant_app.OrderStatus.readyForPickup
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}