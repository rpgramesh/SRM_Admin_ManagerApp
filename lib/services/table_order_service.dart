import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_order.dart';
import '../models/cart_item.dart';

class TableOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _tableSessions =>
      _firestore.collection('tableSessions');
  CollectionReference get _individualOrders =>
      _firestore.collection('individualOrders');

  // Create a new table session
  Future<String> createTableSession({
    required String tableNumber,
    required int totalSeats,
    required String waiterName,
  }) async {
    try {
      final session = TableSession(
        id: '',
        tableNumber: tableNumber,
        totalSeats: totalSeats,
        seatAssignments: {},
        sessionStartTime: DateTime.now(),
        waiterName: waiterName,
      );

      final docRef = await _tableSessions.add(session.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create table session: $e');
    }
  }

  // Assign seats to customers
  Future<void> assignSeats({
    required String sessionId,
    required Map<int, String> seatAssignments,
  }) async {
    try {
      await _tableSessions.doc(sessionId).update({
        'seatAssignments': seatAssignments
            .map((key, value) => MapEntry(key.toString(), value)),
      });
    } catch (e) {
      throw Exception('Failed to assign seats: $e');
    }
  }

  // Get active table session for a table
  Stream<TableSession?> getActiveTableSession(String tableNumber) {
    return _tableSessions
        .where('tableNumber', isEqualTo: tableNumber)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return TableSession.fromFirestore(snapshot.docs.first);
    });
  }

  // Get all orders for a table session
  Stream<List<IndividualOrder>> getTableOrders(String tableNumber) {
    return _individualOrders
        .where('tableNumber', isEqualTo: tableNumber)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IndividualOrder.fromFirestore(doc))
            .toList());
  }

  // Get orders for a specific seat
  Stream<List<IndividualOrder>> getSeatOrders({
    required String tableNumber,
    required int seatNumber,
  }) {
    return _individualOrders
        .where('tableNumber', isEqualTo: tableNumber)
        .where('seatNumber', isEqualTo: seatNumber)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IndividualOrder.fromFirestore(doc))
            .toList());
  }

  // Add individual order for a seat
  Future<String> addIndividualOrder({
    required String tableNumber,
    required int seatNumber,
    required String customerName,
    required List<CartItem> items,
    String? specialInstructions,
    bool isShared = false,
    List<int> sharedWithSeats = const [],
  }) async {
    try {
      final totalAmount =
          items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      final order = IndividualOrder(
        id: '',
        tableNumber: tableNumber,
        seatNumber: seatNumber,
        customerName: customerName,
        items: items,
        totalAmount: totalAmount,
        specialInstructions: specialInstructions,
        isShared: isShared,
        sharedWithSeats: sharedWithSeats,
        orderTime: DateTime.now(),
      );

      final docRef = await _individualOrders.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add individual order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(
      String orderId, TableOrderStatus status) async {
    try {
      final updateData = {'status': status.toString().split('.').last};

      if (status == TableOrderStatus.ready) {
        updateData['readyTime'] = DateTime.now().toIso8601String();
      } else if (status == TableOrderStatus.served) {
        updateData['servedTime'] = DateTime.now().toIso8601String();
      }

      await _individualOrders.doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Add items to existing order
  Future<void> addItemsToOrder(String orderId, List<CartItem> newItems) async {
    try {
      final doc = await _individualOrders.doc(orderId).get();
      if (!doc.exists) throw Exception('Order not found');

      final data = doc.data() as Map<String, dynamic>;
      final existingItems = (data['items'] is List<dynamic>)
          ? (data['items'] as List<dynamic>)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : <CartItem>[];

      final updatedItems = [...existingItems, ...newItems];
      final newTotalAmount = updatedItems.fold(
          0.0, (sum, item) => sum + (item.price * item.quantity));

      await _individualOrders.doc(orderId).update({
        'items': updatedItems.map((item) => item.toJson()).toList(),
        'totalAmount': newTotalAmount,
      });
    } catch (e) {
      throw Exception('Failed to add items to order: $e');
    }
  }

  // Close table session
  Future<void> closeTableSession(String sessionId) async {
    try {
      await _tableSessions.doc(sessionId).update({
        'isActive': false,
        'sessionEndTime': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to close table session: $e');
    }
  }

  // Get table summary for billing
  Future<Map<String, dynamic>> getTableSummary(String tableNumber) async {
    try {
      final ordersSnapshot = await _individualOrders
          .where('tableNumber', isEqualTo: tableNumber)
          .where('status',
              whereIn: ['placed', 'preparing', 'ready', 'served']).get();

      final orders = ordersSnapshot.docs
          .map((doc) => IndividualOrder.fromFirestore(doc))
          .toList();

      final seatTotals = <int, double>{};
      final grandTotal =
          orders.fold(0.0, (sum, order) => sum + order.totalAmount);

      for (final order in orders) {
        if (order.isShared) {
          // Split shared order among all sharing seats
          final sharingSeats = order.sharedWithSeats.isNotEmpty
              ? order.sharedWithSeats
              : [order.seatNumber];
          final splitAmount = order.totalAmount / sharingSeats.length;

          for (final seat in sharingSeats) {
            seatTotals[seat] = (seatTotals[seat] ?? 0) + splitAmount;
          }
        } else {
          // Individual order
          seatTotals[order.seatNumber] =
              (seatTotals[order.seatNumber] ?? 0) + order.totalAmount;
        }
      }

      return {
        'orders': orders,
        'seatTotals': seatTotals,
        'grandTotal': grandTotal,
        'totalOrders': orders.length,
      };
    } catch (e) {
      throw Exception('Failed to get table summary: $e');
    }
  }
}
