import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manager_service.dart';
import 'package:intl/intl.dart';

class ViewReportsScreen extends StatefulWidget {
  const ViewReportsScreen({super.key});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReport = 'overview';

  @override
  Widget build(BuildContext context) {
    final managerService = Provider.of<ManagerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _buildReportFilters(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: managerService.getOrders(
                startDate: _startDate,
                endDate: _endDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data ?? [];

                return _buildReportContent(orders);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedReport,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'overview', child: Text('Overview')),
                      DropdownMenuItem(value: 'sales', child: Text('Sales Report')),
                      DropdownMenuItem(value: 'restaurants', child: Text('Restaurant Performance')),
                      DropdownMenuItem(value: 'dashers', child: Text('Dasher Performance')),
                      DropdownMenuItem(value: 'orders', child: Text('Order Analytics')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReport = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Start Date',
                    date: _startDate,
                    onDateChanged: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePicker(
                    label: 'End Date',
                    date: _endDate,
                    onDateChanged: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateChanged,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: DateFormat('MMM dd, yyyy').format(date),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
    );
  }

  Widget _buildReportContent(List<Map<String, dynamic>> orders) {
    switch (_selectedReport) {
      case 'overview':
        return _buildOverviewReport(orders);
      case 'sales':
        return _buildSalesReport(orders);
      case 'restaurants':
        return _buildRestaurantReport();
      case 'dashers':
        return _buildDasherReport();
      case 'orders':
        return _buildOrderAnalytics(orders);
      default:
        return _buildOverviewReport(orders);
    }
  }

  Widget _buildOverviewReport(List<Map<String, dynamic>> orders) {
    final totalRevenue = orders.fold(0.0, (sum, order) {
      return sum + ((order['totalAmount'] as num?)?.toDouble() ?? 0.0);
    });

    final deliveredOrders = orders.where((order) => order['status'] == 'delivered').length;
    final pendingOrders = orders.where((order) => order['status'] == 'pending').length;
    const avgOrderValue = 25.50; // Placeholder

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
        _buildSummaryCard('Total Orders', orders.length.toString(), Icons.shopping_cart, Colors.blue),
        _buildSummaryCard('Delivered Orders', deliveredOrders.toString(), Icons.check_circle, Colors.green),
        _buildSummaryCard('Pending Orders', pendingOrders.toString(), Icons.pending, Colors.orange),
        _buildSummaryCard('Average Order Value', '\$${avgOrderValue.toStringAsFixed(2)}', Icons.analytics, Colors.purple),
      ],
    );
  }

  Widget _buildSalesReport(List<Map<String, dynamic>> orders) {
    final dailySales = _groupOrdersByDate(orders);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Daily Sales Report',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...dailySales.entries.map((entry) => _buildDailySalesCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildRestaurantReport() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Provider.of<ManagerService>(context).getRestaurants(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final restaurants = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Restaurant Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...restaurants.map((restaurant) => _buildRestaurantPerformanceCard(restaurant)),
          ],
        );
      },
    );
  }

  Widget _buildDasherReport() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Provider.of<ManagerService>(context).getDashers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashers = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Dasher Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...dashers.map((dasher) => _buildDasherPerformanceCard(dasher)),
          ],
        );
      },
    );
  }

  Widget _buildOrderAnalytics(List<Map<String, dynamic>> orders) {
    final statusCounts = _getOrderStatusCounts(orders);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Order Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatusChart(statusCounts),
        const SizedBox(height: 16),
        ...orders.take(10).map((order) => _buildOrderCard(order)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySalesCard(String date, List<Map<String, dynamic>> orders) {
    final revenue = orders.fold(0.0, (sum, order) {
      return sum + ((order['totalAmount'] as num?)?.toDouble() ?? 0.0);
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(date))),
        subtitle: Text('${orders.length} orders'),
        trailing: Text(
          '\$${revenue.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildRestaurantPerformanceCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(restaurant['name'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuisine: ${restaurant['cuisine_type'] ?? 'Unknown'}'),
            Text('Status: ${restaurant['isActive'] == true ? 'Active' : 'Inactive'}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildDasherPerformanceCard(Map<String, dynamic> dasher) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(dasher['name'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${dasher['vehicle_type'] ?? 'Unknown'}'),
            Text('Rating: ${dasher['rating'] ?? 0}/5.0'),
            Text('Status: ${dasher['isOnline'] == true ? 'Online' : 'Offline'}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildStatusChart(Map<String, int> statusCounts) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...statusCounts.entries.map((entry) => Row(
              children: [
                Expanded(child: Text(entry.key.toUpperCase())),
                Text(entry.value.toString()),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 20,
                  color: _getStatusColor(entry.key),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('Order #${order['id']?.substring(0, 8) ?? 'N/A'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order['status']?.toUpperCase() ?? 'UNKNOWN'}'),
            Text('Amount: \$${(order['totalAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            Text('Date: ${DateFormat('MMM dd, yyyy HH:mm').format(order['createdAt']?.toDate() ?? DateTime.now())}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(order['status'] ?? 'unknown'),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order['status']?.toUpperCase() ?? 'UNKNOWN',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupOrdersByDate(List<Map<String, dynamic>> orders) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var order in orders) {
      final date = order['createdAt']?.toDate() ?? DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(order);
    }
    
    return grouped;
  }

  Map<String, int> _getOrderStatusCounts(List<Map<String, dynamic>> orders) {
    final counts = <String, int>{};
    
    for (var order in orders) {
      final status = order['status'] ?? 'unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}