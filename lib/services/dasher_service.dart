import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/order.dart' as restaurant_app;

class DasherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _dasherId;
  
  Future<void> initializeNotifications(String dasherId) async {
    _dasherId = dasherId;

    // Push notifications are supported on mobile platforms only.
    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      // No-op on desktop/web; you can integrate a desktop notification solution separately.
      return;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    if (token != null && dasherId.isNotEmpty) {
      await _firestore.collection('dashers').doc(dasherId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey('orderReady')) {
        _handleOrderReadyNotification(message.data);
      }
    });
  }

  void _handleOrderReadyNotification(Map<String, dynamic> data) {
    final pickupNotification = OrderPickupNotification.fromFirestoreMap(data);
    
    _addToPickupQueue(pickupNotification);
    _createDeliveryRoute(pickupNotification);
  }

  Future<void> _addToPickupQueue(OrderPickupNotification notification) async {
    if (_dasherId == null) return;

    await _firestore
        .collection('dashers')
        .doc(_dasherId)
        .collection('available_orders')
        .doc(notification.orderId)
        .set(notification.toMap());
  }

  Future<void> _createDeliveryRoute(OrderPickupNotification notification) async {
    final routeData = {
      'orderId': notification.orderId,
      'dasherId': _dasherId,
      'status': 'available',
      'pickupLocation': notification.pickupLocation,
      'deliveryLocation': notification.customerAddress,
      'customerName': notification.customerName,
      'customerPhone': notification.customerPhone,
      'estimatedPickupTime': notification.estimatedFoodReadyTime,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': null,
    };

    await _firestore.collection('delivery_routes').add(routeData);
  }

  Future<String?> acceptOrderPickup(String orderId) async {
    if (_dasherId == null) return null;

    try {
      final query = await _firestore
          .collection('delivery_routes')
          .where('orderId', isEqualTo: orderId)
          .where('status', isEqualTo: 'available')
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw Exception('Route not found');

      final routeId = query.docs.first.id;
      await _firestore.collection('delivery_routes').doc(routeId).update({
        'dasherId': _dasherId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('dashers')
          .doc(_dasherId)
          .collection('available_orders')
          .doc(orderId)
          .delete();

      await _firestore.collection('orders').doc(orderId).update({
        'dasherId': _dasherId,
        'status': 'outForDelivery',
      });

      return routeId;
    } catch (e) {
      print('Error accepting pickup: $e');
      return null;
    }
  }

  Future<String?> acceptPickup(String orderId) async {
    if (_dasherId == null) return null;

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'dasherId': _dasherId,
        'status': 'pickedUp',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return orderId;
    } catch (e) {
      print('Error accepting pickup: $e');
      return null;
    }
  }

  Future<bool> completeDelivery(String orderId) async {
    if (_dasherId == null) return false;

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error completing delivery: $e');
      return false;
    }
  }

  Future<bool> updateDeliveryRouteStatus(String routeId, String newStatus) async {
    try {
      await _firestore.collection('delivery_routes').doc(routeId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error updating delivery route status: $e");
      return false;
    }
  }

  Stream<List<OrderPickupNotification>> listenAvailableOrders() {
    if (_dasherId == null) return const Stream.empty();

    try {
      return _firestore
          .collection('orders')
          .where('status', isEqualTo: 'readyForPickup')
          .where('dasherId', isNull: true)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => 
                OrderPickupNotification.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error in listenAvailableOrders: $e');
      return const Stream.empty();
    }
  }

  Stream<List<OrderPickupNotification>> listenActiveOrders() {
    if (_dasherId == null) return const Stream.empty();

    try {
      return _firestore
          .collection('orders')
          .where('dasherId', isEqualTo: _dasherId)
          .where('status', whereIn: ['pickedUp', 'outForDelivery'])
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => 
                OrderPickupNotification.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error in listenActiveOrders: $e');
      return const Stream.empty();
    }
  }

  Stream<List<restaurant_app.Order>> getCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => restaurant_app.Order.fromFirestore(doc)).toList());
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
  
  if (message.data.containsKey('orderId')) {
    // Handle background notification
  }
}

class OrderPickupNotification {
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String pickupLocation;
  final String estimatedFoodReadyTime;
  final double orderTotal;

  OrderPickupNotification({
    required this.orderId,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.pickupLocation,
    required this.estimatedFoodReadyTime,
    required this.orderTotal,
  });

  factory OrderPickupNotification.fromFirestoreMap(Map<String, dynamic> map) {
    final geoPoint = map['pickupLocation'];
    String lat = '0.0';
    String lng = '0.0';
    
    if (geoPoint is GeoPoint) {
      lat = geoPoint.latitude.toString();
      lng = geoPoint.longitude.toString();
    } else if (geoPoint is Map<String, dynamic>) {
      lat = (geoPoint['latitude']?.toString()) ?? '0.0';
      lng = (geoPoint['longitude']?.toString()) ?? '0.0';
    } else if (geoPoint != null) {
      final parts = geoPoint.toString().split(',');
      if (parts.length >= 2) {
        lat = parts[0].trim();
        lng = parts[1].trim();
      }
    }
    
    return OrderPickupNotification(
      orderId: map['orderId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      customerAddress: map['customerAddress']?.toString() ?? '',
      customerPhone: map['customerPhone']?.toString() ?? '',
      pickupLocation: '$lat,$lng',
      estimatedFoodReadyTime: map['estimatedFoodReadyTime']?.toString() ?? '',
      orderTotal: double.tryParse(map['orderTotal']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  factory OrderPickupNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderPickupNotification.fromFirestoreMap(data);
  }

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'customerName': customerName,
    'customerAddress': customerAddress,
    'customerPhone': customerPhone,
    'pickupLocation': pickupLocation,
    'estimatedFoodReadyTime': estimatedFoodReadyTime,
    'orderTotal': orderTotal,
  };

  String get status => 'ready';
}
