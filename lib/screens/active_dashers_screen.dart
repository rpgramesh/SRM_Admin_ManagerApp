import 'package:flutter/material.dart';
import 'package:restaurant_app/services/manager_service.dart';

class ActiveDashersScreen extends StatefulWidget {
  const ActiveDashersScreen({super.key});

  @override
  State<ActiveDashersScreen> createState() => _ActiveDashersScreenState();
}

class _ActiveDashersScreenState extends State<ActiveDashersScreen> {
  final ManagerService _managerService = ManagerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Dashers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _managerService.getActiveDashers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final dashers = snapshot.data ?? [];
          final availableDashers = dashers.where((d) => d['isAvailable'] == true).length;

          return Column(
            children: [
              // Header with stats
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Active',
                        dashers.length.toString(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Available',
                        availableDashers.toString(),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              // Dashers list
              Expanded(
                child: dashers.isEmpty
                    ? const Center(
                        child: Text(
                          'No active dashers found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dashers.length,
                        itemBuilder: (context, index) {
                          final dasher = dashers[index];
                          return _buildDasherCard(dasher);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildDasherCard(Map<String, dynamic> dasher) {
    final isAvailable = dasher['isAvailable'] ?? false;
    final name = dasher['name'] ?? 'Unknown Dasher';
    final vehicleType = dasher['vehicleType'] ?? 'Unknown';
    final phone = dasher['phone'] ?? 'No phone';
    final rating = (dasher['rating'] ?? 0.0).toDouble();
    final totalDeliveries = dasher['totalDeliveries'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_car, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            vehicleType,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Busy',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.delivery_dining, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$totalDeliveries deliveries',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}