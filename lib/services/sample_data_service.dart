import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/models/menu_item.dart';
import 'package:restaurant_app/models/cart_item.dart';
import 'package:restaurant_app/models/order.dart' as restaurant_app;
import 'package:restaurant_app/models/delivery_route.dart';
import 'package:restaurant_app/services/firestore_service.dart';
import 'package:restaurant_app/services/notification_service.dart';
import 'package:restaurant_app/services/dasher_assignment_service.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SampleDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  final DasherAssignmentService _dasherAssignmentService =
      DasherAssignmentService();
  final Uuid _uuid = const Uuid();

  // Initialize sample data for the entire app
  Future<void> initializeSampleData() async {
    print('Initializing sample data...');
  
    try {
      // Initialize notification service
      await _notificationService.initialize();
    
      // Remove this line since we don't want sample dashers
      // await _dasherAssignmentService.initializeSampleDashers();
    
      await _initializeMenuItems();
      await _initializeTables();
      await _initializeSampleOrders();
      await _initializeSampleDeliveryRoutes();
    
      print('Sample data initialization completed!');
    } catch (e) {
      print('Error initializing sample data: $e');
      rethrow;
    }
  }

  // Initialize tables
  Future<void> _initializeTables() async {
    // Check if tables already exist
    final tablesSnapshot = await _db.collection('tables').limit(1).get();
    if (tablesSnapshot.docs.isNotEmpty) {
      print('Tables already exist, skipping initialization');
      return;
    }

    // Add sample tables (10 tables)
    final List<Map<String, dynamic>> tables = [];
    for (int i = 1; i <= 10; i++) {
      tables.add({
        'tableNumber': i,
        'capacity': i <= 5 ? 4 : 6, // Tables 1-5: 4 seats, Tables 6-10: 6 seats
        'isOccupied':
            false, // Using isOccupied instead of status for compatibility
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Add tables to Firestore
    for (final table in tables) {
      await _db.collection('tables').add(table);
    }
    print('Sample tables initialized');
  }

  // Initialize menu items
  Future<void> _initializeMenuItems() async {
    // Check if menu items already exist
    final menuSnapshot = await _db.collection('menuItems').limit(1).get();
    if (menuSnapshot.docs.isNotEmpty) {
      print('Menu items already exist, skipping initialization');
      return;
    }

    // Add sample menu items
    for (final item in MenuItem.dummyItems) {
      await _firestoreService.addMenuItem(item);
    }
    print('Sample menu items initialized');
  }

  // Initialize sample orders
  Future<void> _initializeSampleOrders() async {
    // Check if orders already exist
    final ordersSnapshot = await _db.collection('orders').limit(1).get();
    if (ordersSnapshot.docs.isNotEmpty) {
      print('Orders already exist, skipping initialization');
      return;
    }

    // Sample customer IDs
    final List<Map<String, String>> customers = [
      {
        'id': 'customer1',
        'name': 'John Smith',
        'address': '123 Main St, Melbourne',
        'phone': '0412345678'
      },
      {
        'id': 'customer2',
        'name': 'Sarah Johnson',
        'address': '456 Park Ave, Sydney',
        'phone': '0423456789'
      },
      {
        'id': 'customer3',
        'name': 'Michael Brown',
        'address': '789 Queen St, Brisbane',
        'phone': '0434567890'
      },
    ];

    // Get menu items to create sample orders
    final menuItemsSnapshot = await _db.collection('menuItems').get();
    final List<MenuItem> menuItems = menuItemsSnapshot.docs
        .map((doc) => MenuItem.fromJson(doc.data()))
        .toList();

    if (menuItems.isEmpty) {
      print('No menu items found, cannot create sample orders');
      return;
    }

    // Create sample orders with different statuses
    final List<restaurant_app.OrderStatus> statuses = [
      restaurant_app.OrderStatus.pending,
      restaurant_app.OrderStatus.preparing,
      restaurant_app.OrderStatus.readyForPickup,
      restaurant_app.OrderStatus.outForDelivery,
      restaurant_app.OrderStatus.delivered,
    ];

    for (int i = 0; i < 10; i++) {
      // Select random customer and status
      final customer = customers[i % customers.length];
      final status = statuses[i % statuses.length];

      // Create cart items from menu items
      final List<CartItem> cartItems = [];
      for (int j = 0; j < 2 + (i % 3); j++) {
        final menuItem = menuItems[(i + j) % menuItems.length];
        cartItems.add(CartItem(
          id: menuItem.id,
          name: menuItem.name,
          price: menuItem.price,
          quantity: 1 + (j % 3),
          imageUrl: menuItem.imageUrl,
        ));
      }

      // Calculate total amount
      double totalAmount = 0;
      for (final item in cartItems) {
        totalAmount += item.price * item.quantity;
      }

      // Create timestamps based on status
      final now = DateTime.now();
      final orderTime = now.subtract(Duration(hours: 2 + i));
      DateTime? readyTime;
      DateTime? pickupTime;
      DateTime? deliveryTime;

      if (status.index >= restaurant_app.OrderStatus.readyForPickup.index) {
        readyTime = orderTime.add(const Duration(minutes: 30));
      }

      if (status.index >= restaurant_app.OrderStatus.outForDelivery.index) {
        pickupTime = readyTime?.add(const Duration(minutes: 15));
      }

      if (status == restaurant_app.OrderStatus.delivered) {
        deliveryTime = pickupTime?.add(const Duration(minutes: 25));
      }

      // Create order
      final String orderId = _uuid.v4();
      final restaurant_app.Order order = restaurant_app.Order(
        id: orderId,
        customerId: customer['id']!,
        customerName: customer['name']!,
        customerAddress: customer['address']!,
        customerPhone: customer['phone']!,
        items: cartItems,
        totalAmount: totalAmount,
        status: status,
        orderTime: orderTime,
        readyTime: readyTime,
        pickupTime: pickupTime,
        deliveryTime: deliveryTime,
      );

      await _firestoreService.addOrder(order);

      // Create delivery route for orders that are ready for pickup or beyond
      if (status.index >= restaurant_app.OrderStatus.readyForPickup.index) {
        await _createSampleDeliveryRoute(order, status, i);
      }
    }

    print('Sample orders initialized');
  }

  // Create a sample delivery route for an order
  Future<void> _createSampleDeliveryRoute(restaurant_app.Order order,
      restaurant_app.OrderStatus orderStatus, int index) async {
    // Use real dasher IDs from the dasher assignment service
    final List<String> realDasherIds = [
      'dasher_001',
      'dasher_002',
      'dasher_003',
      'dasher_004',
      'dasher_005'
    ];
    final dasherId = realDasherIds[index % realDasherIds.length];

    // Create delivery status based on order status
    DeliveryStatus status;
    DateTime? pickedUpTime;
    DateTime? deliveredTime;

    if (orderStatus == restaurant_app.OrderStatus.readyForPickup) {
      status = DeliveryStatus.assigned;
    } else if (orderStatus == restaurant_app.OrderStatus.outForDelivery) {
      status = DeliveryStatus.pickedUp;
      pickedUpTime = order.pickupTime;
    } else if (orderStatus == restaurant_app.OrderStatus.delivered) {
      status = DeliveryStatus.delivered;
      pickedUpTime = order.pickupTime;
      deliveredTime = order.deliveryTime;
    } else {
      // Should not happen based on our logic, but just in case
      status = DeliveryStatus.assigned;
    }

    // Use varied delivery locations for better demo
    final List<LatLng> deliveryLocations = [
      const LatLng(-37.8136, 144.9631), // Melbourne CBD
      const LatLng(-37.8142, 144.9987), // Richmond
      const LatLng(-37.7979, 144.9789), // Fitzroy
      const LatLng(-37.7999, 144.9647), // Carlton
      const LatLng(-37.82200579563919, 145.1772987824447), // Default location
    ];

    final restaurantLocation =
        const LatLng(-37.71112804668473, 144.5917238006204);
    final deliveryLocation =
        deliveryLocations[index % deliveryLocations.length];

    final DeliveryRoute route = DeliveryRoute(
      id: _uuid.v4(),
      orderId: order.id,
      dasherId: dasherId,
      pickupLocation: restaurantLocation,
      deliveryLocation: deliveryLocation,
      status: status,
      assignedTime: order.readyTime ?? DateTime.now(),
      pickedUpTime: pickedUpTime,
      deliveredTime: deliveredTime,
    );

    await _firestoreService.addDeliveryRoute(route);

    // Mark dashers as unavailable if they have active deliveries
    if (status == DeliveryStatus.assigned ||
        status == DeliveryStatus.pickedUp) {
      await _dasherAssignmentService.updateDasherLocation(
        dasherId,
        status == DeliveryStatus.assigned
            ? restaurantLocation
            : deliveryLocation,
      );
    }
  }

  // Initialize sample delivery routes (this is called separately but also from _initializeSampleOrders)
  Future<void> _initializeSampleDeliveryRoutes() async {
    // Check if delivery routes already exist
    final routesSnapshot =
        await _db.collection('deliveryRoutes').limit(1).get();
    if (routesSnapshot.docs.isNotEmpty) {
      print('Delivery routes already exist, skipping initialization');
      return;
    }

    // Note: Most delivery routes are created in _initializeSampleOrders
    // This method is mainly a placeholder for any additional routes we might want to create
    print('Sample delivery routes initialized');
  }
}
