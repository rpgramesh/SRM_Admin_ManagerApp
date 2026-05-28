import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart' as restaurant_app;
import '../models/delivery_route.dart';
import '../models/notification.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../config/design_tokens.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerOrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String customerId;

  const CustomerOrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.customerId,
  });

  @override
  State<CustomerOrderTrackingScreen> createState() =>
      _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState
    extends State<CustomerOrderTrackingScreen> {
  late FirestoreService _firestoreService;
  late NotificationService _notificationService;
  GoogleMapController? _mapController;
  restaurant_app.Order? _order;
  DeliveryRoute? _deliveryRoute;
  final List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _notificationService =
        Provider.of<NotificationService>(context, listen: false);
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      final order = await _firestoreService.getOrderById(widget.orderId);
      if (order != null) {
        setState(() {
          _order = order;
        });

        // Load delivery route if order is ready for pickup or beyond
        if (order.status == restaurant_app.OrderStatus.readyForPickup ||
            order.status == restaurant_app.OrderStatus.outForDelivery ||
            order.status == restaurant_app.OrderStatus.delivered) {
          _loadDeliveryRoute();
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load order: $e');
    }
  }

  Future<void> _loadDeliveryRoute() async {
    try {
      final routes =
          await _firestoreService.getDeliveryRouteStream(widget.orderId).first;
      if (routes != null) {
        final route = routes.where(
          (route) => route.orderId == widget.orderId && route != null
        ).firstOrNull;

        if (route != null) {
          setState(() {
            _deliveryRoute = route;
          });
        }
      }
    } catch (e) {
      print('Error loading delivery route: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: Text('Track Order #${widget.orderId.substring(0, 8)}'),
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        foregroundColor: DesignTokens.neutralGrey900,
      ),
      body: _order == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadOrderData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatusCard(),
                    const SizedBox(height: DesignTokens.space16),
                    _buildOrderProgressTimeline(),
                    const SizedBox(height: DesignTokens.space16),
                    if (_deliveryRoute != null) ...[
                      _buildDeliveryMap(),
                      const SizedBox(height: DesignTokens.space16),
                      _buildDeliveryInfo(),
                      const SizedBox(height: DesignTokens.space16),
                    ],
                    _buildOrderDetails(),
                    const SizedBox(height: DesignTokens.space16),
                    _buildNotificationsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space12,
                  vertical: DesignTokens.space6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(_order!.status).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                child: Text(
                  _getStatusText(_order!.status),
                  style: TextStyle(
                    color: _getStatusColor(_order!.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _getStatusIcon(_order!.status),
                color: _getStatusColor(_order!.status),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            _getStatusMessage(_order!.status),
            style: const TextStyle(
              fontSize: 16,
              color: DesignTokens.neutralGrey700,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            'Estimated delivery: ${_getEstimatedDeliveryTime()}',
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.neutralGrey500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgressTimeline() {
    final steps = [
      {
        'status': restaurant_app.OrderStatus.pending,
        'title': 'Order Placed',
        'subtitle': 'Your order has been confirmed'
      },
      {
        'status': restaurant_app.OrderStatus.confirmed,
        'title': 'Order Confirmed',
        'subtitle': 'Restaurant is preparing your order'
      },
      {
        'status': restaurant_app.OrderStatus.preparing,
        'title': 'Preparing',
        'subtitle': 'Your delicious meal is being prepared'
      },
      {
        'status': restaurant_app.OrderStatus.readyForPickup,
        'title': 'Ready for Pickup',
        'subtitle': 'Looking for a nearby delivery partner'
      },
      {
        'status': restaurant_app.OrderStatus.outForDelivery,
        'title': 'Out for Delivery',
        'subtitle': 'Your order is on the way'
      },
      {
        'status': restaurant_app.OrderStatus.delivered,
        'title': 'Delivered',
        'subtitle': 'Enjoy your meal!'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final status = step['status'] as restaurant_app.OrderStatus;
            final isCompleted = _order!.status.index >= status.index;
            final isCurrent = _order!.status == status;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == steps.length - 1 ? 0 : DesignTokens.space16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? DesignTokens.primaryGreen500
                          : DesignTokens.neutralGrey300,
                      border: isCurrent
                          ? Border.all(
                              color: DesignTokens.primaryGreen500, width: 3)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: DesignTokens.neutralWhite,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? DesignTokens.neutralGrey900
                                : DesignTokens.neutralGrey500,
                          ),
                        ),
                        Text(
                          step['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isCompleted
                                ? DesignTokens.neutralGrey600
                                : DesignTokens.neutralGrey400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryMap() {
    if (_deliveryRoute == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _deliveryRoute!.pickupLocation,
            zoom: 13.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('pickup'),
              position: _deliveryRoute!.pickupLocation,
              infoWindow: const InfoWindow(title: 'Restaurant'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
            Marker(
              markerId: const MarkerId('delivery'),
              position: _deliveryRoute!.deliveryLocation,
              infoWindow: const InfoWindow(title: 'Delivery Address'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    if (_deliveryRoute == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          Row(
            children: [
              const Icon(Icons.local_shipping,
                  color: DesignTokens.neutralGrey600),
              const SizedBox(width: DesignTokens.space8),
              Text(
                'Dasher ID: ${_deliveryRoute!.dasherId}',
                style: const TextStyle(
                  fontSize: 16,
                  color: DesignTokens.neutralGrey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          Row(
            children: [
              const SizedBox(width: DesignTokens.space8),
              const SizedBox(width: DesignTokens.space8),
              Text(
                'Assigned: ${_formatTime(_deliveryRoute!.assignedTime)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: DesignTokens.neutralGrey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order ID:',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
              Text(
                '#${widget.orderId.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
              Text(
                'A\$${_order!.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.primaryGreen500,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Time:',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignTokens.neutralGrey600,
                ),
              ),
              Text(
                _formatTime(_order!.orderTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: DesignTokens.space24),
          const Text(
            'Items:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          ..._order!.items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.space4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} x${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: DesignTokens.neutralGrey700,
                            ),
                          ),
                        ),
                        Text(
                          'A\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ))
              ,
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return StreamBuilder<List<AppNotification>>(
      stream: _firestoreService.getNotificationStream(widget.orderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final orderNotifications =
            snapshot.data!.where((n) => n.orderId == widget.orderId).toList();

        if (orderNotifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(DesignTokens.space20),
          decoration: BoxDecoration(
            color: DesignTokens.neutralWhite,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DesignTokens.space12),
              ...orderNotifications
                  .map((notification) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: DesignTokens.space8),
                        child: Row(
                          children: [
                            Icon(
                              notification.type.icon,
                              size: 16,
                              color: DesignTokens.neutralGrey600,
                            ),
                            const SizedBox(width: DesignTokens.space8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    notification.message,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: DesignTokens.neutralGrey600,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: DesignTokens.neutralGrey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  ,
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(restaurant_app.OrderStatus status) {
    switch (status) {
      case restaurant_app.OrderStatus.pending:
        return Colors.orange;
      case restaurant_app.OrderStatus.confirmed:
        return Colors.blue;
      case restaurant_app.OrderStatus.preparing:
        return Colors.purple;
      case restaurant_app.OrderStatus.readyForPickup:
        return Colors.amber;
      case restaurant_app.OrderStatus.outForDelivery:
        return Colors.cyan;
      case restaurant_app.OrderStatus.delivered:
        return DesignTokens.primaryGreen500;
      case restaurant_app.OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(restaurant_app.OrderStatus status) {
    switch (status) {
      case restaurant_app.OrderStatus.pending:
        return Icons.schedule;
      case restaurant_app.OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case restaurant_app.OrderStatus.preparing:
        return Icons.restaurant;
      case restaurant_app.OrderStatus.readyForPickup:
        return Icons.inventory;
      case restaurant_app.OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case restaurant_app.OrderStatus.delivered:
        return Icons.done_all;
      case restaurant_app.OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(restaurant_app.OrderStatus status) {
    switch (status) {
      case restaurant_app.OrderStatus.pending:
        return 'Pending';
      case restaurant_app.OrderStatus.confirmed:
        return 'Confirmed';
      case restaurant_app.OrderStatus.preparing:
        return 'Preparing';
      case restaurant_app.OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case restaurant_app.OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case restaurant_app.OrderStatus.delivered:
        return 'Delivered';
      case restaurant_app.OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusMessage(restaurant_app.OrderStatus status) {
    switch (status) {
      case restaurant_app.OrderStatus.pending:
        return 'We have received your order and will confirm it shortly.';
      case restaurant_app.OrderStatus.confirmed:
        return 'Your order has been confirmed and is being prepared.';
      case restaurant_app.OrderStatus.preparing:
        return 'Your delicious meal is being prepared by our chefs.';
      case restaurant_app.OrderStatus.readyForPickup:
        return 'Your order is ready! Looking for a delivery partner.';
      case restaurant_app.OrderStatus.outForDelivery:
        return 'Your order is on the way to your location.';
      case restaurant_app.OrderStatus.delivered:
        return 'Your order has been delivered. Enjoy your meal!';
      case restaurant_app.OrderStatus.cancelled:
        return 'Your order has been cancelled.';
    }
  }

  String _getEstimatedDeliveryTime() {
    final now = DateTime.now();
    final estimatedTime = now.add(const Duration(minutes: 30));
    return '${estimatedTime.hour.toString().padLeft(2, '0')}:${estimatedTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
