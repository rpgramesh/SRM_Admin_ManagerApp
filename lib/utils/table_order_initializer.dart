import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_order.dart';

class TableOrderInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize table order system
  Future<void> initializeTableOrderSystem() async {
    try {
      print('Initializing table order system...');

      // Create sample menu items
      await _createSampleMenuItems();
      
      // Create sample table sessions
      await _createSampleTableSessions();
      
      // Create sample individual orders
      await _createSampleIndividualOrders();

      print('Table order system initialized successfully!');
    } catch (e) {
      print('Error initializing table order system: $e');
    }
  }

  Future<void> _createSampleMenuItems() async {
    final menuItems = [
      {
        'name': 'Veg Samosa',
        'description': 'Crispy pastry filled with spiced potatoes and peas',
        'price': 8.99,
        'imageUrl': 'assets/images/samosa.svg',
        'category': 'Starters',
        'isSpicy': false,
        'isVegetarian': true,
      },
      {
        'name': 'Veg Manchurian',
        'description': 'Indo-Chinese style vegetable dumplings in a spicy sauce',
        'price': 14.99,
        'imageUrl': 'assets/images/manchurian.svg',
        'category': 'Starters',
        'isSpicy': true,
        'isVegetarian': true,
      },
      {
        'name': 'Butter Chicken',
        'description': 'Tender chicken pieces in a rich, creamy tomato sauce',
        'price': 18.99,
        'imageUrl': 'assets/images/butter_chicken.svg',
        'category': 'Main Course',
        'isSpicy': false,
        'isVegetarian': false,
      },
      {
        'name': 'Chicken Saag',
        'description': 'Chicken cooked with fresh spinach and aromatic spices',
        'price': 18.99,
        'imageUrl': 'assets/images/chicken_saag.svg',
        'category': 'Main Course',
        'isSpicy': false,
        'isVegetarian': false,
      },
      {
        'name': 'Lamb Madras',
        'description': 'Spicy lamb curry cooked with coconut and South Indian spices',
        'price': 19.99,
        'imageUrl': 'assets/images/lamb_madras.svg',
        'category': 'Main Course',
        'isSpicy': true,
        'isVegetarian': false,
      },
      {
        'name': 'Palak Paneer',
        'description': 'Fresh cottage cheese cubes in a creamy spinach sauce',
        'price': 17.99,
        'imageUrl': 'assets/images/palak_paneer.svg',
        'category': 'Main Course',
        'isSpicy': false,
        'isVegetarian': true,
      },
      {
        'name': 'Steam Rice',
        'description': 'Steamed basmati rice',
        'price': 6.99,
        'imageUrl': 'assets/images/steam_rice.svg',
        'category': 'Rice',
        'isSpicy': false,
        'isVegetarian': true,
      },
      {
        'name': 'Veg Biryani',
        'description': 'Fragrant basmati rice cooked with mixed vegetables and spices',
        'price': 14.99,
        'imageUrl': 'assets/images/veg_biryani.svg',
        'category': 'Rice',
        'isSpicy': true,
        'isVegetarian': true,
      },
      {
        'name': 'Plain Naan',
        'description': 'Traditional Indian leavened bread baked in tandoor',
        'price': 3.99,
        'imageUrl': 'assets/images/plain_naan.svg',
        'category': 'Breads',
        'isSpicy': false,
        'isVegetarian': true,
      },
      {
        'name': 'Butter Naan',
        'description': 'Naan bread brushed with butter',
        'price': 4.49,
        'imageUrl': 'assets/images/butter_naan.svg',
        'category': 'Breads',
        'isSpicy': false,
        'isVegetarian': true,
      },
    ];

    // Clear existing menu items first
    final existingItems = await _firestore.collection('menuItems').get();
    for (final doc in existingItems.docs) {
      await doc.reference.delete();
    }

    // Add new menu items
    for (final item in menuItems) {
      await _firestore.collection('menuItems').add(item);
    }
  }

  Future<void> _createSampleTableSessions() async {
    final sessions = [
      TableSession(
        id: '',
        tableNumber: '1',
        totalSeats: 4,
        seatAssignments: {
          1: 'John Doe',
          2: 'Jane Smith',
          3: 'Bob Johnson',
          4: 'Alice Brown',
        },
        sessionStartTime: DateTime.now().subtract(const Duration(hours: 1)),
        waiterName: 'Sarah',
      ),
      TableSession(
        id: '',
        tableNumber: '2',
        totalSeats: 4,
        seatAssignments: {
          1: 'Mike Wilson',
          2: 'Lisa Davis',
        },
        sessionStartTime: DateTime.now().subtract(const Duration(minutes: 30)),
        waiterName: 'David',
      ),
    ];

    for (final session in sessions) {
      await _firestore.collection('tableSessions').add(session.toFirestore());
    }
  }

  Future<void> _createSampleIndividualOrders() async {
    final orders = [
      // Table 1 orders
      {
        'tableNumber': '1',
        'seatNumber': 1,
        'customerName': 'John Doe',
        'items': [
          {
            'id': 'burger',
            'name': 'Classic Burger',
            'price': 12.99,
            'quantity': 1,
            'category': 'Main Course',
          },
          {
            'id': 'fries',
            'name': 'French Fries',
            'price': 3.99,
            'quantity': 1,
            'category': 'Sides',
          },
        ],
        'totalAmount': 16.98,
        'status': 'placed',
        'isShared': false,
        'sharedWithSeats': [],
      },
      {
        'tableNumber': '1',
        'seatNumber': 2,
        'customerName': 'Jane Smith',
        'items': [
          {
            'id': 'salad',
            'name': 'Caesar Salad',
            'price': 9.99,
            'quantity': 1,
            'category': 'Main Course',
          },
        ],
        'totalAmount': 9.99,
        'status': 'preparing',
        'isShared': false,
        'sharedWithSeats': [],
      },
      {
        'tableNumber': '1',
        'seatNumber': 3,
        'customerName': 'Bob Johnson',
        'items': [
          {
            'id': 'pizza',
            'name': 'Pepperoni Pizza',
            'price': 18.99,
            'quantity': 1,
            'category': 'Main Course',
          },
        ],
        'totalAmount': 18.99,
        'status': 'ordering',
        'isShared': true,
        'sharedWithSeats': [4],
      },
      // Table 2 orders
      {
        'tableNumber': '2',
        'seatNumber': 1,
        'customerName': 'Mike Wilson',
        'items': [
          {
            'id': 'steak',
            'name': 'Ribeye Steak',
            'price': 24.99,
            'quantity': 1,
            'category': 'Main Course',
          },
        ],
        'totalAmount': 24.99,
        'status': 'placed',
        'isShared': false,
        'sharedWithSeats': [],
      },
    ];

    for (final orderData in orders) {
      await _firestore.collection('individualOrders').add({
        'tableNumber': orderData['tableNumber'],
        'seatNumber': orderData['seatNumber'],
        'customerName': orderData['customerName'],
        'items': orderData['items'],
        'totalAmount': orderData['totalAmount'],
        'status': orderData['status'],
        'isShared': orderData['isShared'],
        'sharedWithSeats': orderData['sharedWithSeats'],
        'orderTime': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  // Clear all table order data
  Future<void> clearTableOrderData() async {
    try {
      print('Clearing table order data...');
      
      final sessions = await _firestore.collection('tableSessions').get();
      for (final doc in sessions.docs) {
        await doc.reference.delete();
      }

      final orders = await _firestore.collection('individualOrders').get();
      for (final doc in orders.docs) {
        await doc.reference.delete();
      }

      final menuItems = await _firestore.collection('menuItems').get();
      for (final doc in menuItems.docs) {
        await doc.reference.delete();
      }

      print('Table order data cleared successfully!');
    } catch (e) {
      print('Error clearing table order data: $e');
    }
  }

  // Check table order system status
  Future<Map<String, dynamic>> checkSystemStatus() async {
    try {
      final sessionsCount = await _firestore.collection('tableSessions').count().get();
      final ordersCount = await _firestore.collection('individualOrders').count().get();

      return {
        'tableSessions': sessionsCount.count,
        'individualOrders': ordersCount.count,
        'status': 'System is ready for table-based ordering',
      };
    } catch (e) {
      return {
        'error': 'System check failed: $e',
      };
    }
  }
}