import 'package:flutter/material.dart';
import 'package:restaurant_app/services/manager_service.dart';

class RevenueDetailsScreen extends StatefulWidget {
  const RevenueDetailsScreen({super.key});

  @override
  State<RevenueDetailsScreen> createState() => _RevenueDetailsScreenState();
}

class _RevenueDetailsScreenState extends State<RevenueDetailsScreen> {
  final ManagerService _managerService = ManagerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _managerService.getRealTimeDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? {};
          final totalRevenue = (data['totalRevenue'] ?? 0.0).toDouble();
          final totalOrders = data['totalOrders'] ?? 0;
          final todayRevenue = (data['todayRevenue'] ?? 0.0).toDouble();
          final todayOrders = data['todayOrders'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Performance
                _buildSectionHeader('Today\'s Performance'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard(
                        'Today\'s Revenue',
                        '\$${todayRevenue.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRevenueCard(
                        'Today\'s Orders',
                        todayOrders.toString(),
                        Colors.blue,
                        Icons.shopping_bag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Total Performance
                _buildSectionHeader('Total Performance'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard(
                        'Total Revenue',
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        Colors.purple,
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRevenueCard(
                        'Total Orders',
                        totalOrders.toString(),
                        Colors.orange,
                        Icons.receipt_long,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Key Metrics
                _buildSectionHeader('Key Metrics'),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Average Order Value',
                  totalOrders > 0 ? 'A\$${(totalRevenue / totalOrders).toStringAsFixed(2)}' : 'A\$0.00',
                  Icons.trending_up,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Today\'s Average Order',
                  todayOrders > 0 ? 'A\$${(todayRevenue / todayOrders).toStringAsFixed(2)}' : 'A\$0.00',
                  Icons.today,
                ),
                const SizedBox(height: 24),

                // Revenue Breakdown
                _buildSectionHeader('Revenue Breakdown'),
                const SizedBox(height: 12),
                _buildBreakdownCard('Delivery Orders', '${(totalRevenue * 0.7).toStringAsFixed(2)}', '70%'),
                const SizedBox(height: 8),
                _buildBreakdownCard('Pickup Orders', '${(totalRevenue * 0.25).toStringAsFixed(2)}', '25%'),
                const SizedBox(height: 8),
                _buildBreakdownCard('Dine-in Orders', '${(totalRevenue * 0.05).toStringAsFixed(2)}', '5%'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRevenueCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(String source, String amount, String percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              source,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$$amount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}