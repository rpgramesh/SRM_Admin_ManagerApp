import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String recipientId;
  final String? orderId;
  final String? deliveryRouteId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.recipientId,
    this.orderId,
    this.deliveryRouteId,
    this.data,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'recipientId': recipientId,
      'orderId': orderId,
      'deliveryRouteId': deliveryRouteId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      recipientId: json['recipientId'],
      orderId: json['orderId'],
      deliveryRouteId: json['deliveryRouteId'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? recipientId,
    String? orderId,
    String? deliveryRouteId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      recipientId: recipientId ?? this.recipientId,
      orderId: orderId ?? this.orderId,
      deliveryRouteId: deliveryRouteId ?? this.deliveryRouteId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  AppNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum NotificationType {
  general,
  orderPlaced,
  orderConfirmed,
  orderReady,
  orderPickedUp,
  orderDelivered,
  orderCancelled,
  deliveryAssigned,
  deliveryStarted,
  deliveryUpdated,
  paymentProcessed,
  promotionalOffer,
  systemAlert,
  staffAlert,
  managerAlert,
  adminAlert,
  customer,
  restaurant,
  dasher,
  deliveryPickedUp,
  deliveryDelivered,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.orderPlaced:
        return 'Order Placed';
      case NotificationType.orderConfirmed:
        return 'Order Confirmed';
      case NotificationType.orderReady:
        return 'Order Ready';
      case NotificationType.orderPickedUp:
        return 'Order Picked Up';
      case NotificationType.orderDelivered:
        return 'Order Delivered';
      case NotificationType.orderCancelled:
        return 'Order Cancelled';
      case NotificationType.deliveryAssigned:
        return 'Delivery Assigned';
      case NotificationType.deliveryStarted:
        return 'Delivery Started';
      case NotificationType.deliveryUpdated:
        return 'Delivery Updated';
      case NotificationType.paymentProcessed:
        return 'Payment Processed';
      case NotificationType.promotionalOffer:
        return 'Promotional Offer';
      case NotificationType.systemAlert:
        return 'System Alert';
      case NotificationType.staffAlert:
        return 'Staff Alert';
      case NotificationType.managerAlert:
        return 'Manager Alert';
      case NotificationType.adminAlert:
        return 'Admin Alert';
      case NotificationType.customer:
        return 'Customer';
      case NotificationType.restaurant:
        return 'Restaurant';
      case NotificationType.dasher:
        return 'Dasher';
      case NotificationType.deliveryPickedUp:
        return 'Delivery Picked Up';
      case NotificationType.deliveryDelivered:
        return 'Delivery Delivered';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.orderPlaced:
        return Icons.shopping_cart;
      case NotificationType.orderConfirmed:
        return Icons.check_circle;
      case NotificationType.orderReady:
        return Icons.restaurant_menu;
      case NotificationType.orderPickedUp:
        return Icons.delivery_dining;
      case NotificationType.orderDelivered:
        return Icons.assignment_turned_in;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.deliveryAssigned:
        return Icons.person_add;
      case NotificationType.deliveryStarted:
        return Icons.directions_car;
      case NotificationType.deliveryUpdated:
        return Icons.update;
      case NotificationType.paymentProcessed:
        return Icons.payment;
      case NotificationType.promotionalOffer:
        return Icons.local_offer;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.staffAlert:
        return Icons.people;
      case NotificationType.managerAlert:
        return Icons.admin_panel_settings;
      case NotificationType.adminAlert:
        return Icons.security;
      case NotificationType.customer:
        return Icons.person;
      case NotificationType.restaurant:
        return Icons.store;
      case NotificationType.dasher:
        return Icons.delivery_dining;
      case NotificationType.deliveryPickedUp:
        return Icons.archive;
      case NotificationType.deliveryDelivered:
        return Icons.check_circle_outline;
    }
  }
}