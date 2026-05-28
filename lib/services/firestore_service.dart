import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/models/order.dart' as restaurant_app;
import 'package:restaurant_app/models/menu_item.dart';
import 'package:restaurant_app/models/delivery_route.dart';
import 'package:restaurant_app/models/dasher.dart';
import 'package:restaurant_app/models/notification.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Menu Item Operations
  Stream<List<MenuItem>> getMenuItems() {
    return _db.collection('menuItems').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  Future<List<MenuItem>> getMenuItemsOnce() async {
    final snapshot = await _db.collection('menuItems').get();
    return snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList();
  }

  Future<void> addMenuItem(MenuItem item) async {
    DocumentReference docRef;
    
    // If item.id is empty or null, generate a new document ID
    if (item.id.isEmpty) {
      docRef = _db.collection('menuItems').doc();
    } else {
      docRef = _db.collection('menuItems').doc(item.id);
    }
    
    // Create a new MenuItem with the correct ID
    final menuItemWithId = MenuItem(
      id: docRef.id,
      name: item.name,
      description: item.description,
      price: item.price,
      imageUrl: item.imageUrl,
      category: item.category,
      isSpicy: item.isSpicy,
      isVegetarian: item.isVegetarian,
      inStock: item.inStock,
      isRecommended: item.isRecommended,
      hasOffer: item.hasOffer,
    );
    
    await docRef.set(menuItemWithId.toJson());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _db.collection('menuItems').doc(item.id).set(
      item.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteMenuItem(String id) async {
    await _db.collection('menuItems').doc(id).delete();
  }

  // Order Operations
  Stream<List<restaurant_app.Order>> getOrders() {
    return _db.collection('orders').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => restaurant_app.Order.fromFirestore(doc))
        .toList());
  }

  Stream<List<restaurant_app.Order>> getOrdersByCustomerId(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => restaurant_app.Order.fromFirestore(doc))
            .toList());
  }

  Stream<restaurant_app.Order?> getOrderStream(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((snapshot) =>
        snapshot.exists ? restaurant_app.Order.fromFirestore(snapshot) : null);
  }

  Future<restaurant_app.Order?> getOrderById(String orderId) async {
    final snapshot = await _db.collection('orders').doc(orderId).get();
    return snapshot.exists
        ? restaurant_app.Order.fromFirestore(snapshot)
        : null;
  }

  Future<void> addOrder(restaurant_app.Order order) async {
    await _db.collection('orders').add(order.toFirestore());
  }

  Future<void> updateOrder(restaurant_app.Order order) async {
    await _db.collection('orders').doc(order.id).update(order.toFirestore());
  }

  // Delivery Route Operations
  Stream<List<DeliveryRoute>> getDeliveryRoutesStream() {
    return _db.collection('deliveryRoutes').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DeliveryRoute.fromFirestore(doc)).toList());
  }

  Stream<DeliveryRoute?> getDeliveryRouteStream(String routeId) {
    return _db.collection('deliveryRoutes').doc(routeId).snapshots().map(
        (snapshot) =>
            snapshot.exists ? DeliveryRoute.fromFirestore(snapshot) : null);
  }

  Future<void> addDeliveryRoute(DeliveryRoute route) async {
    await _db.collection('deliveryRoutes').add(route.toFirestore());
  }

  Future<void> updateDeliveryRoute(DeliveryRoute route) async {
    await _db
        .collection('deliveryRoutes')
        .doc(route.id)
        .update(route.toFirestore());
  }

  Stream<List<DeliveryRoute>> getDeliveryRoutesByDasherId(String dasherId) {
    return _db
        .collection('deliveryRoutes')
        .where('dasherId', isEqualTo: dasherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryRoute.fromFirestore(doc))
            .toList());
  }

  // Notification Operations
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
      'readAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> markAllNotificationsAsRead(String recipientId) async {
    final notifications = await _db
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in notifications.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  Stream<List<AppNotification>> getNotificationsByRecipient(
      String recipientId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data()))
            .toList());
  }

  Future<void> addAppNotification(AppNotification notification) async {
    await _db.collection('notifications').add(notification.toJson());
  }

  // Dasher Operations
  Stream<List<Dasher>> getDashers() {
    return _db.collection('dashers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Dasher.fromJson(doc.data())).toList());
  }

  Stream<List<Dasher>> getDashersByStatus(String status) {
    return _db
        .collection('dashers')
        .where('status', isEqualTo: status.toString().split('.').last)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Dasher.fromJson(doc.data())).toList());
  }

  Stream<Dasher?> getDasherById(String dasherId) {
    return _db.collection('dashers').doc(dasherId).snapshots().map((snapshot) =>
        snapshot.exists && snapshot.data() != null
            ? Dasher.fromJson(snapshot.data()!)
            : null);
  }

  Future<void> updateDasherStatus(String dasherId, String status) async {
    await _db.collection('dashers').doc(dasherId).update({
      'status': status.toString().split('.').last,
    });
  }

  // Waiter management
  Future<void> createWaiter(Map<String, dynamic> waiterData) async {
    await _db.collection('waiters').doc(waiterData['waiterId']).set(waiterData);
  }

  Future<Map<String, dynamic>?> getWaiterById(String waiterId) async {
    final doc = await _db.collection('waiters').doc(waiterId).get();
    return doc.data();
  }

  Future<void> updateWaiterPin(String waiterId, String newPin) async {
    await _db.collection('waiters').doc(waiterId).update({
      'pin': newPin,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllWaiters() async {
    final snapshot = await _db.collection('waiters').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> deleteWaiter(String waiterId) async {
    await _db.collection('waiters').doc(waiterId).delete();
  }

  // Table Operations
  Stream<QuerySnapshot> getTables() {
    return _db.collection('tables').snapshots();
  }

  Future<void> updateTableStatus(int tableNumber, bool isOccupied) async {
    final querySnapshot = await _db
        .collection('tables')
        .where('tableNumber', isEqualTo: tableNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'isOccupied': isOccupied,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Category Operations
  Stream<QuerySnapshot> getCategories() {
    return _db.collection('categories').snapshots();
  }

  Stream<QuerySnapshot> getMenuItemsByCategory(String category) {
    return _db
        .collection('menuItems')
        .where('category', isEqualTo: category)
        .snapshots();
  }

  Stream<List<MenuItem>> getMenuItemsByCategoryAsList(String category) {
    return _db
        .collection('menuItems')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  // Order Operations for Waiters
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    final docRef = await _db.collection('orders').add(orderData);
    return docRef.id;
  }

  Future<void> updateWaiterOrder(
      String orderId, Map<String, dynamic> updates) async {
    await _db.collection('orders').doc(orderId).update(updates);
  }

  Stream<List<restaurant_app.Order>> getOrdersByStatus(
      restaurant_app.OrderStatus status) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: status.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => restaurant_app.Order.fromFirestore(doc))
            .toList());
  }

  Stream<List<AppNotification>> getNotificationStream(String orderId) {
    return _db
        .collection('notifications')
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data()))
            .toList());
  }

  Stream<List<DeliveryRoute>> getDeliveryRoutes(String orderId) {
    return _db
        .collection('deliveryRoutes')
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryRoute.fromFirestore(doc))
            .toList());
  }
}
