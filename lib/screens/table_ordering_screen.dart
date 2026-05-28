import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table_order.dart';
import '../services/table_order_service.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

class TableOrderingScreen extends StatefulWidget {
  final String tableNumber;

  const TableOrderingScreen({super.key, required this.tableNumber});

  @override
  State<TableOrderingScreen> createState() => _TableOrderingScreenState();
}

class _TableOrderingScreenState extends State<TableOrderingScreen> {
  final TableOrderService _tableOrderService = TableOrderService();
  final TextEditingController _customerNameController = TextEditingController();
  late String? _sessionId;
  int? _selectedSeat;
  Map<int, String> _seatAssignments = {};

  @override
  void initState() {
    super.initState();
    _initializeTableSession();
  }

  Future<void> _initializeTableSession() async {
    final session = await _tableOrderService.getActiveTableSession(widget.tableNumber).first;
    if (session == null) {
      _sessionId = await _tableOrderService.createTableSession(
        tableNumber: widget.tableNumber,
        totalSeats: 4, // Default to 4 seats, can be dynamic
        waiterName: 'Waiter', // Get from user context
      );
    } else {
      _sessionId = session.id;
      _seatAssignments = session.seatAssignments;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber} - Individual Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: _showTableSummary,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSeatSelection(),
          _buildOrderInterface(),
          _buildCurrentOrders(),
        ],
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seat Assignment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final seatNumber = index + 1;
                return GestureDetector(
                  onTap: () => _selectSeat(seatNumber),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _selectedSeat == seatNumber
                          ? Colors.blue
                          : _seatAssignments.containsKey(seatNumber)
                              ? Colors.green
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Seat $seatNumber',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (_seatAssignments.containsKey(seatNumber))
                          Text(
                            _seatAssignments[seatNumber]!.split(' ')[0],
                            style: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            if (_selectedSeat != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                      ),
                      controller: _customerNameController,
                      onSubmitted: (name) => _assignCustomerToSeat(name),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_customerNameController.text.isNotEmpty) {
                        _assignCustomerToSeat(_customerNameController.text);
                      }
                    },
                    child: const Text('Assign'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInterface() {
    if (_selectedSeat == null || !_seatAssignments.containsKey(_selectedSeat)) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Select a seat and assign customer to start ordering'),
              SizedBox(height: 16),
              Text('Tap on a seat number above, then enter the customer name.'),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Ordering for ${_seatAssignments[_selectedSeat]} (Seat $_selectedSeat)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: Provider.of<FirestoreService>(context, listen: false).getMenuItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final menuItems = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Card(
                      child: InkWell(
                        onTap: () => _addItemToOrder(item),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('A\$${item.price.toStringAsFixed(2)}'),
                              Text(item.category, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrders() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: StreamBuilder<List<IndividualOrder>>(
        stream: _tableOrderService.getTableOrders(widget.tableNumber),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Seat ${order.seatNumber} - ${order.customerName}'),
                subtitle: Text('Items: ${order.items.length} - A\$${order.totalAmount.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(order.status.toString().split('.').last),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editOrder(order),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _selectSeat(int seatNumber) {
    setState(() {
      _selectedSeat = seatNumber;
    });
  }

  void _assignCustomerToSeat(String name) {
    if (_selectedSeat != null && name.isNotEmpty) {
      setState(() {
        _seatAssignments[_selectedSeat!] = name;
        _customerNameController.clear();
        _selectedSeat = null; // Clear selection after assignment
      });
      if (_sessionId != null) {
        _tableOrderService.assignSeats(
          sessionId: _sessionId!,
          seatAssignments: _seatAssignments,
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer "$name" assigned to seat ${_seatAssignments.entries.last.key}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _addItemToOrder(MenuItem menuItem) async {
    if (_selectedSeat == null || !_seatAssignments.containsKey(_selectedSeat)) return;

    final cartItem = CartItem(
      id: menuItem.id,
      name: menuItem.name,
      price: menuItem.price,
      quantity: 1,
      imageUrl: menuItem.imageUrl,
    );

    await _tableOrderService.addIndividualOrder(
      tableNumber: widget.tableNumber,
      seatNumber: _selectedSeat!,
      customerName: _seatAssignments[_selectedSeat!]!,
      items: [cartItem],
    );
  }

  void _editOrder(IndividualOrder order) {
    // TODO: Implement order editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order editing coming soon')),
    );
  }

  void _showTableSummary() async {
    try {
      final summary = await _tableOrderService.getTableSummary(widget.tableNumber);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Table ${widget.tableNumber} Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Orders: ${summary['totalOrders']}'),
              Text('Grand Total: A\$${summary['grandTotal'].toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Per Seat:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...summary['seatTotals'].entries.map((entry) =>
                Text('Seat ${entry.key}: A\$${entry.value.toStringAsFixed(2)}')
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () => _closeTableSession(),
              child: const Text('Close Table Session'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _closeTableSession() async {
    if (_sessionId != null) {
      await _tableOrderService.closeTableSession(_sessionId!);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}