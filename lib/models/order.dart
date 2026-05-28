import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/models/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderTime;
  final DateTime? readyTime;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final String? tableNumber;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.orderTime,
    this.readyTime,
    this.pickupTime,
    this.deliveryTime,
    this.tableNumber,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      items: (data['items'] is List<dynamic>)
          ? (data['items'] as List<dynamic>)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
          (e) => e.toString() == 'OrderStatus.${data['status']}',
          orElse: () => OrderStatus.pending),
      orderTime: (data['orderTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readyTime: (data['readyTime'] as Timestamp?)?.toDate(),
      pickupTime: (data['pickupTime'] as Timestamp?)?.toDate(),
      deliveryTime: (data['deliveryTime'] as Timestamp?)?.toDate(),
      tableNumber: data['tableNumber']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'orderTime': Timestamp.fromDate(orderTime),
      'readyTime': readyTime != null ? Timestamp.fromDate(readyTime!) : null,
      'pickupTime': pickupTime != null ? Timestamp.fromDate(pickupTime!) : null,
      'deliveryTime':
          deliveryTime != null ? Timestamp.fromDate(deliveryTime!) : null,
      'tableNumber': tableNumber,
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    List<CartItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderTime,
    DateTime? readyTime,
    DateTime? pickupTime,
    DateTime? deliveryTime,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      readyTime: readyTime ?? this.readyTime,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }
}
