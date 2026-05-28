import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import 'package:restaurant_app/services/menu_management_service.dart';
import 'package:restaurant_app/services/manager_service.dart';
import 'package:restaurant_app/widgets/menu_management_widget.dart';
import 'manager_dashboard_screen.dart';
import 'order_dashboard_screen.dart';
import 'order_management_screen.dart';

class AdminAppScreen extends StatefulWidget {
  const AdminAppScreen({super.key});

  @override
  State<AdminAppScreen> createState() => _AdminAppScreenState();
}

class _AdminAppScreenState extends State<AdminAppScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // FirestoreService will be accessed through service classes when needed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Do Not change this order by Ramesh
          _buildDashboardScreen(),
          _buildOrderDashboardScreen(),
          _buildOrderManagementScreen(),
          _buildUsersScreen(),
          _buildSystemScreen(),
          _buildReportsScreen(),
          _buildMenuManagementScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.analytics), text: 'Order Analytics'),
            Tab(icon: Icon(Icons.list_alt), text: 'Orders'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.settings), text: 'System'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Reports'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
          ],
        ),
      ),
    );
}

  Widget _buildOrderDashboardScreen() {
    return const OrderDashboardScreen();
  }

  Widget _buildOrderManagementScreen() {
    return const OrderManagementScreen();
  }

  Widget _buildManagerDashboardScreen() {
    return Provider<ManagerService>.value(
      value: ManagerService(),
      child: const ManagerDashboardScreen(),
    );
  }

  Widget _buildDashboardScreen() {
    return StreamBuilder<List<MenuItem>>(
      stream: MenuManagementService().getMenuItems(),
      builder: (context, menuItemsSnapshot) {
        int menuItemsCount = menuItemsSnapshot.hasData ? menuItemsSnapshot.data!.length : 0;
        
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, ordersSnapshot) {
            int totalOrders = ordersSnapshot.hasData ? ordersSnapshot.data!.docs.length : 0;
            
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, usersSnapshot) {
                int totalUsers = usersSnapshot.hasData ? usersSnapshot.data!.docs.length : 0;
                
                double totalRevenue = 0.0;
                if (ordersSnapshot.hasData) {
                  for (var orderDoc in ordersSnapshot.data!.docs) {
                    // print(totalOrders);                  
                    Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
                    if (orderData.containsKey('totalAmount')) {
                      // print(orderData['totalAmount']);
                      totalRevenue += (orderData['totalAmount'] as num).toDouble();
                    }
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Icon(Icons.dashboard, size: 100, color: Colors.deepPurple),
                      const SizedBox(height: 20),
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Real-time data from Firebase',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      
                      if (!menuItemsSnapshot.hasData && !ordersSnapshot.hasData && !usersSnapshot.hasData)
                        const Center(child: CircularProgressIndicator()),
                      
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildStatCard('Total Orders', totalOrders.toString(), Icons.shopping_cart),
                          _buildStatCard('Total Users', totalUsers.toString(), Icons.person),
                          _buildStatCard('Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.attach_money),
                          _buildStatCard('Menu Items', menuItemsCount.toString(), Icons.restaurant_menu),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        final totalUsers = users.length;
        final customers = users.where((user) => user['role'] == 'customer').length;
        const admins = 1; // Assuming one admin from context

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard2('Total Users', totalUsers.toString(), Icons.people_outline),
                          _buildStatCard2('Customers', customers.toString(), Icons.person_outline),
                          _buildStatCard2('Admins', admins.toString(), Icons.admin_panel_settings_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'All Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(user['name']?.substring(0, 1).toUpperCase() ?? '?'),
                      ),
                      title: Text(user['name'] ?? 'No Name'),
                      subtitle: Text(user['email'] ?? 'No Email'),
                      trailing: Chip(
                        label: Text(user['role'] ?? 'customer'),
                        backgroundColor: user['role'] == 'admin' ? Colors.red : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard2(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.deepPurple),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSystemScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('system_status').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final systemData = snapshot.data?.docs.isNotEmpty == true
            ? snapshot.data!.docs.first.data() as Map<String, dynamic>
            : {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'System Status',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('config').snapshots(),
                builder: (context, configSnapshot) {
                  final config = configSnapshot.hasData && configSnapshot.data!.docs.isNotEmpty
                      ? configSnapshot.data!.docs.first.data() as Map<String, dynamic>
                      : {};
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildSystemCard(
                        'Database',
                        systemData['database_status'] ?? 'Connected',
                        Icons.storage,
                        (systemData['database_status'] ?? 'Connected') == 'Connected'
                            ? Colors.green
                            : Colors.red,
                      ),
                      _buildSystemCard(
                        'API Status',
                        systemData['api_status'] ?? 'Operational',
                        Icons.cloud,
                        (systemData['api_status'] ?? 'Operational') == 'Operational'
                            ? Colors.green
                            : Colors.red,
                      ),
                      _buildSystemCard(
                        'Revenue Cycle',
                        '${config['revenue_cycle_days'] ?? '7'} days',
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                      _buildSystemCard(
                        'Backup Interval',
                        '${config['backup_interval_hours'] ?? '24'} hours',
                        Icons.backup,
                        Colors.orange,
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Configuration',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildConfigItem('Flutter Version', '3.32.7'),
                      _buildConfigItem('Dart SDK', '3.8.1'),
                      _buildConfigItem('Firebase App', 'Loaded'),
                      _buildConfigItem('Platform', kIsWeb ? 'Web' : 'Mobile'),
                      _buildConfigItem('Environment', 'Production'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('logs')
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, logsSnapshot) {
                  if (!logsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final logs = logsSnapshot.data!.docs;
                  
                  return Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent System Logs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index].data() as Map<String, dynamic>;
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(log['message'] ?? 'Log entry'),
                                          Text(
                                            log['timestamp']?.toDate().toString() ?? '',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, ordersSnapshot) {
        if (ordersSnapshot.hasError) {
          return Center(child: Text('Error: ${ordersSnapshot.error}'));
        }

        if (ordersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = ordersSnapshot.data!.docs;
        final totalRevenue = orders.fold(0.0, (sum, order) {
          final total = (order.data() as Map<String, dynamic>)['totalAmount'] ?? 0.0;
          return sum + (total as num).toDouble();
        });
        final completedOrders = orders.where((order) => 
            (order.data() as Map<String, dynamic>)['status'] == 'completed').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reports & Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildReportCard(
                        'Total Revenue',
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildReportCard(
                        'Total Orders',
                        orders.length.toString(),
                        Icons.shopping_cart,
                        Colors.blue,
                      ),
                      _buildReportCard(
                        'Completed',
                        completedOrders.toString(),
                        Icons.check_circle_outline,
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Order Status Chart
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final orders = snapshot.data!.docs;
                  final statusCounts = {
                    'pending': orders.where((o) => (o.data() as Map<String, dynamic>)['status'] == 'pending').length,
                    'processing': orders.where((o) => (o.data() as Map<String, dynamic>)['status'] == 'processing').length,
                    'completed': orders.where((o) => (o.data() as Map<String, dynamic>)['status'] == 'completed').length,
                    'cancelled': orders.where((o) => (o.data() as Map<String, dynamic>)['status'] == 'cancelled').length,
                  };
                  
                  return Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Status Distribution',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          
                          Column(
                            children: statusCounts.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(entry.key),
                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${entry.key.toUpperCase()}: ${entry.value} orders'),
                                    const Spacer(),
                                    Text('${(entry.value / orders.length * 100).toStringAsFixed(1)}%'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Top Items by Sales
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
                builder: (context, menuSnapshot) {
                  if (!menuSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final menuItems = menuSnapshot.data!.docs;
                  
                  return Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menu Item Performance',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: menuItems.take(5).length,
                            itemBuilder: (context, index) {
                              final item = menuItems[index].data() as Map<String, dynamic>;
                              final views = item['views'] ?? 0;
                              const sales = 50; // Sample sales count
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                  child: Text(item['name']?.substring(0, 1) ?? '?'),
                                ),
                                title: Text(item['name'] ?? 'Unknown Item'),
                                subtitle: Text('Views: $views • Sales: $sales'),
                                trailing: Text(
                                  '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Revenue by Date
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders')
                    .where('createdAt', 
                           isGreaterThan: DateTime.now()
                               .subtract(const Duration(days: 7)))
                    .snapshots(),
                builder: (context, recentOrders) {
                  if (!recentOrders.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final orders = recentOrders.data!.docs;
                  final recentRevenue = orders.fold(0.0, (sum, order) => 
                    sum + ((order.data() as Map<String, dynamic>)['totalAmount'] as num).toDouble());
                  
                  return Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last 7 Days Revenue',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '\$${recentRevenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuManagementScreen() {
    return const MenuManagementWidget();
  }
}