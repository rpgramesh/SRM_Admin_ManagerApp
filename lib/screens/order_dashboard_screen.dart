import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// First run in terminal:
// flutter pub add intl
import 'package:intl/intl.dart';
import '../models/order.dart' as restaurant_app;
import '../services/order_service.dart';

class OrderDashboardScreen extends StatefulWidget {
  const OrderDashboardScreen({super.key});

  @override
  State<OrderDashboardScreen> createState() => _OrderDashboardScreenState();
}

class _OrderDashboardScreenState extends State<OrderDashboardScreen> {
  final OrderService _orderService = OrderService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late Stream<List<restaurant_app.Order>> _ordersStream;
  
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Today';
  
  @override
  void initState() {
    super.initState();
    _ordersStream = _orderService.getCustomerOrders('real-time');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<restaurant_app.Order>>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];
        final filteredOrders = _filterOrdersByDate(orders);
        final stats = _calculateStats(filteredOrders);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Dashboard'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 20),
                _buildStatsCards(stats, orders),
                const SizedBox(height: 24),
                _buildWeeklyChart(filteredOrders),
                const SizedBox(height: 24),
                _buildStatusDistribution(filteredOrders),
                const SizedBox(height: 24),
                _buildRecentOrders(filteredOrders),
                const SizedBox(height: 24),
                _buildRevenueTrend(orders),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Today', 'Yesterday', 'This Week', 'This Month', 'Custom'].map((period) {
                return ChoiceChip(
                  label: Text(period),
                  selected: _selectedPeriod == period,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = period;
                        if (period == 'Custom') {
                          _showDatePicker();
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            if (_selectedPeriod == 'Custom')
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
                      'Selected: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
          style: const TextStyle(color: Colors.blue),
        ),
      ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats, List<restaurant_app.Order> allOrders) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Total Orders',
          value: stats['totalOrders'].toString(),
          icon: Icons.shopping_cart,
          color: Colors.blue,
          trend: _calculateTrend(allOrders, 'total'),
        ),
        _buildStatCard(
          title: 'Revenue',
          value: '\$${stats['totalRevenue'].toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
          trend: _calculateTrend(allOrders, 'revenue'),
        ),
        _buildStatCard(
          title: 'Pending',
          value: stats['pendingOrders'].toString(),
          icon: Icons.pending,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Avg Order Value',
          value: '\$${stats['avgOrderValue'].toStringAsFixed(2)}',
          icon: Icons.calculate,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (trend != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: trend == 'up' ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend == 'up' ? 'up' : 'down',
                    style: TextStyle(
                      fontSize: 12,
                      color: trend == 'up' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<restaurant_app.Order> orders) {
    final weeklyData = _getWeeklyData(orders);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders This Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final dayName = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                  final dayData = weeklyData.where((order) => 
                    order.orderTime.weekday == index + 1
                  );
                  final count = dayData.length;
                  final maxCount = weeklyData.isEmpty ? 1 : weeklyData.length / 7;
                  final height = count / (maxCount > 0 ? maxCount : 1) * 150;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: height.clamp(0, 150),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          count.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(dayName, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution(List<restaurant_app.Order> orders) {
    final statusCounts = _getStatusCounts(orders);
    final total = orders.length;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) 
              => _buildStatusProgressBar(entry.key, entry.value, total)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusProgressBar(String status, int count, int total) {
    final percentage = (count / total * 100).toStringAsFixed(1);
    final color = _getStatusColorFromString(status);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(fontSize: 14)),
              Text('$count orders', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: count / total,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          Text('$percentage%', style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(List<restaurant_app.Order> orders) {
    final recentOrders = orders.take(5).toList();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recentOrders.map((order) 
              => _buildRecentOrderItem(order)
            ),
            if (orders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No orders found'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderItem(restaurant_app.Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(DateFormat('HH:mm', 'en_US').format(order.orderTime)),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.status.name,
              style: TextStyle(
                color: _getStatusColor(order.status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrend(List<restaurant_app.Order> orders) {
    final revenueData = _getRevenueByDate(orders, 7);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: revenueData.length,
                itemBuilder: (context, index) {
                  final entry = revenueData.entries.elementAt(index);
                  final maxRevenue = revenueData.isEmpty ? 1 : 
                    revenueData.values.reduce((a, b) => a > b ? a : b);
                  final height = (entry.value / maxRevenue) * 80;
                  final day = DateFormat('E').format(entry.key);
                  
                  return Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(day, style: const TextStyle(fontSize: 10)),
                        Text(
                          entry.value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<restaurant_app.Order> _filterOrdersByDate(List<restaurant_app.Order> orders) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Yesterday':
        startDate = DateTime(now.year, now.month, now.day - 1);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Custom':
        startDate = _selectedDate;
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }
    
    return orders.where((order) => 
      order.orderTime.isAfter(startDate)
    ).toList();
  }

  Map<String, dynamic> _calculateStats(List<restaurant_app.Order> orders) {
    final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final pendingOrders = orders.where((order) => order.status == restaurant_app.OrderStatus.pending).length;
    final avgOrderValue = orders.isEmpty ? 0.0 : totalRevenue / orders.length;
    
    return {
      'totalOrders': orders.length,
      'totalRevenue': totalRevenue,
      'pendingOrders': pendingOrders,
      'avgOrderValue': avgOrderValue,
    };
  }

  List<restaurant_app.Order> _getWeeklyData(List<restaurant_app.Order> orders) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return orders.where((order) => 
      order.orderTime.isAfter(startOfWeek) && order.orderTime.isBefore(now)
    ).toList();
  }

  Map<String, int> _getStatusCounts(List<restaurant_app.Order> orders) {
    final counts = <String, int>{};
    
    for (final order in orders) {
      final statusName = order.status.name;
      counts[statusName] = (counts[statusName] ?? 0) + 1;
    }
    
    return counts;
  }

  Map<DateTime, double> _getRevenueByDate(List<restaurant_app.Order> orders, int days) {
    final revenueData = <DateTime, double>{};
    final now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayOrders = orders.where((order) => 
        order.orderTime.year == date.year &&
        order.orderTime.month == date.month &&
        order.orderTime.day == date.day
      );
      final dayRevenue = dayOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
      revenueData[date] = dayRevenue;
    }
    
    return revenueData;
  }

  String? _calculateTrend(List<restaurant_app.Order> orders, String type) {
    if (orders.isEmpty) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayOrders = orders.where((order) => 
      order.orderTime.isAfter(today)
    );
    final yesterdayOrders = orders.where((order) => 
      order.orderTime.isAfter(yesterday) && order.orderTime.isBefore(today)
    );
    
    switch (type) {
      case 'total':
        final todayCount = todayOrders.length;
        final yesterdayCount = yesterdayOrders.length;
        return todayCount > yesterdayCount ? 'up' : 'down';
      case 'revenue':
        final todayRevenue = todayOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
        final yesterdayRevenue = yesterdayOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
        return todayRevenue > yesterdayRevenue ? 'up' : 'down';
      default:
        return null;
    }
  }

  Color _getStatusColorFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'readyforpickup':
        return Colors.purple;
      case 'outfordelivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(restaurant_app.OrderStatus status) {
    switch (status) {
      case restaurant_app.OrderStatus.pending:
        return Colors.orange;
      case restaurant_app.OrderStatus.preparing:
        return Colors.blue;
      case restaurant_app.OrderStatus.readyForPickup:
        return Colors.purple;
      case restaurant_app.OrderStatus.outForDelivery:
        return Colors.indigo;
      case restaurant_app.OrderStatus.delivered:
        return Colors.green;
      case restaurant_app.OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}