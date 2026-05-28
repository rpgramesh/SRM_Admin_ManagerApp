import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

enum TableOrderStatus {
  ordering,      // Still being ordered
  placed,        // Order has been placed
  preparing,     // Kitchen is preparing
  ready,         // Food is ready
  served,        // Food has been served
  paid,          // Individual has paid
  cancelled      // Order was cancelled
}

class IndividualOrder {
  final String id;
  final String tableNumber;
  final int seatNumber;
  final String customerName;
  final List<CartItem> items;
  final double totalAmount;
  final TableOrderStatus status;
  final DateTime orderTime;
  final DateTime? readyTime;
  final DateTime? servedTime;
  final String? specialInstructions;
  final bool isShared; // Whether this order is shared with others
  final List<int> sharedWithSeats; // Which seats are sharing this order

  IndividualOrder({
    required this.id,
    required this.tableNumber,
    required this.seatNumber,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.status = TableOrderStatus.ordering,
    required this.orderTime,
    this.readyTime,
    this.servedTime,
    this.specialInstructions,
    this.isShared = false,
    this.sharedWithSeats = const [],
  });

  factory IndividualOrder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return IndividualOrder(
      id: doc.id,
      tableNumber: data['tableNumber'] ?? '',
      seatNumber: data['seatNumber'] ?? 1,
      customerName: data['customerName'] ?? 'Guest',
      items: (data['items'] is List<dynamic>)
          ? (data['items'] as List<dynamic>)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: TableOrderStatus.values.firstWhere(
          (e) => e.toString() == 'TableOrderStatus.${data['status']}',
          orElse: () => TableOrderStatus.ordering),
      orderTime: (data['orderTime'] as Timestamp).toDate(),
      readyTime: (data['readyTime'] as Timestamp?)?.toDate(),
      servedTime: (data['servedTime'] as Timestamp?)?.toDate(),
      specialInstructions: data['specialInstructions'],
      isShared: data['isShared'] ?? false,
      sharedWithSeats: List<int>.from(data['sharedWithSeats'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tableNumber': tableNumber,
      'seatNumber': seatNumber,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'orderTime': Timestamp.fromDate(orderTime),
      'readyTime': readyTime != null ? Timestamp.fromDate(readyTime!) : null,
      'servedTime': servedTime != null ? Timestamp.fromDate(servedTime!) : null,
      'specialInstructions': specialInstructions,
      'isShared': isShared,
      'sharedWithSeats': sharedWithSeats,
    };
  }

  IndividualOrder copyWith({
    String? id,
    String? tableNumber,
    int? seatNumber,
    String? customerName,
    List<CartItem>? items,
    double? totalAmount,
    TableOrderStatus? status,
    DateTime? orderTime,
    DateTime? readyTime,
    DateTime? servedTime,
    String? specialInstructions,
    bool? isShared,
    List<int>? sharedWithSeats,
  }) {
    return IndividualOrder(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      readyTime: readyTime ?? this.readyTime,
      servedTime: servedTime ?? this.servedTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isShared: isShared ?? this.isShared,
      sharedWithSeats: sharedWithSeats ?? this.sharedWithSeats,
    );
  }
}

class TableSession {
  final String id;
  final String tableNumber;
  final int totalSeats;
  final Map<int, String> seatAssignments; // seatNumber -> customerName
  final DateTime sessionStartTime;
  final DateTime? sessionEndTime;
  final String? waiterName;
  final bool isActive;

  TableSession({
    required this.id,
    required this.tableNumber,
    required this.totalSeats,
    required this.seatAssignments,
    required this.sessionStartTime,
    this.sessionEndTime,
    this.waiterName,
    this.isActive = true,
  });

  factory TableSession.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TableSession(
      id: doc.id,
      tableNumber: data['tableNumber'] ?? '',
      totalSeats: data['totalSeats'] ?? 4,
      seatAssignments: Map<String, dynamic>.from(data['seatAssignments'] ?? {})
          .map((key, value) => MapEntry(int.parse(key), value.toString())),
      sessionStartTime: (data['sessionStartTime'] as Timestamp).toDate(),
      sessionEndTime: (data['sessionEndTime'] as Timestamp?)?.toDate(),
      waiterName: data['waiterName'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tableNumber': tableNumber,
      'totalSeats': totalSeats,
      'seatAssignments': seatAssignments.map((key, value) => MapEntry(key.toString(), value)),
      'sessionStartTime': Timestamp.fromDate(sessionStartTime),
      'sessionEndTime': sessionEndTime != null ? Timestamp.fromDate(sessionEndTime!) : null,
      'waiterName': waiterName,
      'isActive': isActive,
    };
  }
}