import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart' as app;
import '../services/order_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final OrderService _orderService = OrderService();
  final Set<String> _selectedOrders = {};
  bool _isLoading = true;
  String _error = '';
  app.OrderStatus? _selectedFilter;
  final List<app.Order> _orders = [];
  List<app.Order> _filteredOrders = [];
  StreamSubscription<List<app.Order>>? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      
      // Cancel any existing subscription
      _ordersSubscription?.cancel();
      
      // Listen to the stream and collect all orders
      _ordersSubscription = _orderService.getAllOrders().listen(
        (orders) {
          if (mounted) {
            setState(() {
              _orders.clear();
              _orders.addAll(orders);
              _filterOrders();
              _isLoading = false;
              _error = '';
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Error loading orders: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading orders: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterOrders() {
    if (_selectedFilter == null) {
      setState(() {
        _filteredOrders = _orders;
      });
    } else {
      setState(() {
        _filteredOrders =
            _orders.where((order) => order.status == _selectedFilter).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          if (_selectedOrders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.update),
              tooltip: 'Bulk Update',
              onPressed: _handleBulkStatusUpdate,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No orders found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilterChips(),
        const SizedBox(height: 8),
        Expanded(
          child: _buildOrderList(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedFilter == null,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? null : null;
                _filterOrders();
              });
            },
          ),
          const SizedBox(width: 8),
          ...app.OrderStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status.name.toUpperCase()),
                selected: _selectedFilter == status,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? status : null;
                    _filterOrders();
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          final isSelected = _selectedOrders.contains(order.id);
          final statusColor = _getStatusColor(order.status);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedOrders.remove(order.id);
                } else {
                  _selectedOrders.add(order.id);
                }
              });
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? const BorderSide(color: Colors.deepPurple, width: 2)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy - HH:mm')
                                  .format(order.orderTime),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            order.status.name.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Customer: ${order.customerName}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('Phone: ${order.customerPhone}'),
                    Text('Address: ${order.customerAddress}'),
                    const SizedBox(height: 8),
                    Text(
                      'Items (${order.items.length}):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...order.items.take(3).map((item) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            '• ${item.name} x${item.quantity}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )),
                    if (order.items.length > 3)
                      Text('... and ${order.items.length - 3} more items'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => _showOrderDetailsDialog(order),
                          tooltip: 'View Details',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(app.OrderStatus status) {
    switch (status) {
      case app.OrderStatus.pending:
        return Colors.orange;
      case app.OrderStatus.preparing:
        return Colors.blue;
      case app.OrderStatus.readyForPickup:
        return Colors.purple;
      case app.OrderStatus.outForDelivery:
        return Colors.indigo;
      case app.OrderStatus.delivered:
        return Colors.green;
      case app.OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetailsDialog(app.Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OrderDetailsDialog(order: order),
    );
  }

  void _handleBulkStatusUpdate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bulk Status Update'),
          content: const Text('Select new status for selected orders'),
          actions: [
            ...app.OrderStatus.values.map((status) => TextButton(
                  onPressed: () => _updateSelectedOrders(status),
                  child: Text(status.name.toUpperCase()),
                )),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateSelectedOrders(app.OrderStatus newStatus) async {
    final futures = _selectedOrders
        .map((orderId) => _orderService.updateOrderStatus(orderId, newStatus))
        .toList();

    try {
      await Future.wait(futures);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Updated ${_selectedOrders.length} orders to ${newStatus.name}')),
      );
      setState(() {
        _selectedOrders.clear();
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating orders: $e')),
      );
    }
  }
}

class OrderDetailsDialog extends StatefulWidget {
  final app.Order order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  final OrderService _orderService = OrderService();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
          ),
          const SizedBox(width: 8),
          Text('Order #${order.id.substring(0, 8)}'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', order.status.name.toUpperCase(),
                color: _getStatusColor(order.status)),
            _buildDetailRow('Order Time',
                DateFormat('MMM dd, yyyy HH:mm').format(order.orderTime)),
            if (order.readyTime != null)
              _buildDetailRow('Ready Time',
                  DateFormat('MMM dd, yyyy HH:mm').format(order.readyTime!)),
            if (order.pickupTime != null)
              _buildDetailRow('Pickup Time',
                  DateFormat('MMM dd, yyyy HH:mm').format(order.pickupTime!)),
            if (order.deliveryTime != null)
              _buildDetailRow('Delivered Time',
                  DateFormat('MMM dd, yyyy HH:mm').format(order.deliveryTime!)),
            const SizedBox(height: 16),
            Text('Customer Information',
                style: Theme.of(context).textTheme.titleMedium),
            _buildDetailRow('Name', order.customerName),
            _buildDetailRow('Phone', order.customerPhone),
            _buildDetailRow('Address', order.customerAddress),
            const SizedBox(height: 16),
            Text('Order Items', style: Theme.of(context).textTheme.titleMedium),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.name} x${item.quantity}'),
                      ),
                      Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            const Divider(height: 20),
            _buildDetailRow('Subtotal',
                '\$${order.items.fold(0.0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(2)}'),
            _buildDetailRow(
                'Total', '\$${order.totalAmount.toStringAsFixed(2)}',
                isBold: true, largerFontSize: 18),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ...app.OrderStatus.values
            .where((status) => status != order.status)
            .map((status) => _buildStatusButton(status))
            ,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? color, bool isBold = false, double? largerFontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: largerFontSize ?? 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(app.OrderStatus status) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getStatusColor(status),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      onPressed: _isUpdating ? null : () => _updateOrderStatus(status),
      child: _isUpdating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text('Mark as ${status.name.toUpperCase()}'),
    );
  }

  Future<void> _updateOrderStatus(app.OrderStatus newStatus) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _orderService.updateOrderStatus(widget.order.id, newStatus);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to ${newStatus.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  IconData _getStatusIcon(app.OrderStatus status) {
    switch (status) {
      case app.OrderStatus.pending:
        return Icons.access_time;
      case app.OrderStatus.preparing:
        return Icons.kitchen;
      case app.OrderStatus.readyForPickup:
        return Icons.check_circle;
      case app.OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case app.OrderStatus.delivered:
        return Icons.done_all;
      case app.OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

Color _getStatusColor(app.OrderStatus status) {
  switch (status) {
    case app.OrderStatus.pending:
      return Colors.orange;
    case app.OrderStatus.preparing:
      return Colors.blue;
    case app.OrderStatus.readyForPickup:
      return Colors.purple;
    case app.OrderStatus.outForDelivery:
      return Colors.indigo;
    case app.OrderStatus.delivered:
      return Colors.green;
    case app.OrderStatus.cancelled:
      return Colors.red;
    default:
      return Colors.grey;
  }
}
