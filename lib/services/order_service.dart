import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import '../models/order.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

class OrderService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<app.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => app.Order.fromFirestore(doc)).toList());
  }

  /// Update delivery route status for GPS tracking
  /// Used by dasher screens to update delivery route progress
  Future<bool> updateDeliveryRouteStatus(
      String routeId, String newStatus) async {
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

  /// Get customer orders for the order dashboard
  /// Returns orders filtered for customer display with real-time updates
  Stream<List<app.Order>> getCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => app.Order.fromFirestore(doc)).toList());
  }

  /// Update order status with kitchen/dasher integration
  /// [kitchen] flag triggers cloud function for Dasher notifications
  /// [dasherId] links order to specific dasher when picked up
  Future<bool> updateOrderStatus(String orderId, app.OrderStatus newStatus,
      {bool kitchen = false, String? dasherId}) async {
    try {
      // Create order status event for cloud function trigger
      await _firestore.collection('order_status_events').add({
        'orderId': orderId,
        'previousStatus': null, // Cloud function will fetch
        'newStatus': newStatus.name,
        'changedBy': _getCurrentUserId(),
        'isKitchenStatus': kitchen,
        'dasherId': dasherId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update main order status
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
        if (dasherId != null) 'dasherId': dasherId,
      });

      // Special handling for readyForPickup status
      if (newStatus == app.OrderStatus.readyForPickup && kitchen) {
        await _triggerDasherNotification(orderId);
      }

      return true;
    } catch (e) {
      print("Error updating order status: $e");
      return false;
    }
  }

  /// Kitchen-specific: Mark orders ready for pickup
  Future<bool> markOrderReadyForPickup(String orderId) async {
    return await updateOrderStatus(orderId, app.OrderStatus.readyForPickup,
        kitchen: true);
  }

  /// Trigger Dasher notification when order is ready
  Future<void> _triggerDasherNotification(String orderId) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return;

      final orderData = orderDoc.data()!;

      // Create pickup notification for nearest dashers
      final pickupData = {
        'orderId': orderId,
        'pickupLocation': orderData['restaurantAddress'] ?? '',
        'customerAddress': orderData['customerAddress'] ?? '',
        'customerName': orderData['customerName'] ?? '',
        'customerPhone': orderData['customerPhone'] ?? '',
        'orderTotal': orderData['totalAmount'] ?? 0.0,
        'restaurantName': orderData['restaurantName'] ?? '',
        'estimatedFoodReadyTime': 'Now', // Could be calculated
        'kitchenMarkedReady': true,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Cloud function will handle the actual FCM notifications
      // This just creates the notification record
      await _firestore.collection('dasher_notifications').add(pickupData);
    } catch (e) {
      print("Error triggering dasher notification: $e");
    }
  }

  // Helper methods
  String? _getCurrentUserId() => _auth.currentUser?.uid;

  Stream<List<app.Order>> getOrdersByStatus(List<String> statuses) {
    return _firestore
        .collection('orders')
        .where('status', whereIn: statuses)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => app.Order.fromFirestore(doc)).toList());
  }

  // Kitchen-specific streams
  Stream<List<app.Order>> getKitchenOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: [
          app.OrderStatus.preparing.name,
          app.OrderStatus.readyForPickup.name
        ])
        .orderBy('orderTime')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => app.Order.fromFirestore(doc)).toList());
  }

  // Dasher-specific streams
  Stream<List<app.Order>> getDasherAvailableOrders(String dasherId) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: app.OrderStatus.readyForPickup.name)
        .where('dasherId', isNull: true)
        .orderBy('orderTime')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => app.Order.fromFirestore(doc)).toList());
  }

  Stream<List<app.Order>> getDasherActiveOrders(String dasherId) {
    return _firestore
        .collection('orders')
        .where('dasherId', isEqualTo: dasherId)
        .where('status', whereIn: [
          app.OrderStatus.outForDelivery.name,
          app.OrderStatus.delivered.name
        ])
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => app.Order.fromFirestore(doc)).toList());
  }
}
