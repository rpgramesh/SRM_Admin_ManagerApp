import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/delivery_route.dart';
import 'package:restaurant_app/models/order.dart' as restaurant_app;
import 'package:restaurant_app/services/firestore_service.dart';
import 'package:restaurant_app/theme/design_tokens.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late FirestoreService _firestoreService;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        backgroundColor: DesignTokens.primaryOrange,
      ),
      body: StreamBuilder<List<restaurant_app.Order>>(
        stream: _firestoreService.getOrders(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderSnapshot.hasError) {
            return Center(child: Text('Error: ${orderSnapshot.error}'));
          }

          final orders = orderSnapshot.data ?? [];
          final order = orders.firstWhere(
            (o) => o.id == widget.orderId,
            orElse: () => restaurant_app.Order(
              id: '',
              customerId: '',
              customerName: '',
              customerAddress: '',
              customerPhone: '',
              items: [],
              totalAmount: 0,
              status: restaurant_app.OrderStatus.pending,
              orderTime: DateTime.now(),
              readyTime: null,
              pickupTime: null,
              deliveryTime: null,
            ),
          );

          if (order.id.isEmpty) {
            return const Center(child: Text('Order not found'));
          }

          return StreamBuilder<List<DeliveryRoute>>(
            stream: _firestoreService.getDeliveryRoutes(widget.orderId),
            builder: (context, routeSnapshot) {
              if (routeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (routeSnapshot.hasError) {
                return Center(child: Text('Error: ${routeSnapshot.error}'));
              }

              final routes = routeSnapshot.data ?? [];
              final route = routes.firstWhere(
                (r) => r.orderId == widget.orderId,
                orElse: () => DeliveryRoute(
                  id: '',
                  orderId: '',
                  dasherId: '',
                  pickupLocation: const LatLng(0, 0),
                  deliveryLocation: const LatLng(0, 0),
                  status: DeliveryStatus.assigned,
                  assignedTime: DateTime.now(),
                  pickedUpTime: null,
                  deliveredTime: null,
                ),
              );

              if (route.id.isEmpty) {
                return _buildOrderDetails(order, null);
              }

              // Update markers
              _updateMarkers(route);

              return _buildOrderDetails(order, route);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails(restaurant_app.Order order, DeliveryRoute? route) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Card(
              elevation: DesignTokens.elevationSmall,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.neutralGrey800,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    _buildStatusTimeline(order),
                    const SizedBox(height: DesignTokens.space16),
                    Text('Order placed: ${_formatDateTime(order.orderTime)}'),
                    if (order.readyTime != null)
                      Text('Ready for pickup: ${_formatDateTime(order.readyTime!)}'),
                    if (order.pickupTime != null)
                      Text('Picked up: ${_formatDateTime(order.pickupTime!)}'),
                    if (order.deliveryTime != null)
                      Text('Delivered: ${_formatDateTime(order.deliveryTime!)}'),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (route != null && route.id.isNotEmpty)
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  route.deliveryLocation.latitude,
                  route.deliveryLocation.longitude,
                ),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                _updateMarkers(route);
              },
            ),
          )
        else
          const Expanded(
            flex: 2,
            child: Center(
              child: Text('Delivery not yet assigned'),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusTimeline(restaurant_app.Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusDot(
          'Ordered',
          order.status.index >= restaurant_app.OrderStatus.pending.index,
        ),
        _buildStatusLine(
          order.status.index >= restaurant_app.OrderStatus.preparing.index,
        ),
        _buildStatusDot(
          'Preparing',
          order.status.index >= restaurant_app.OrderStatus.preparing.index,
        ),
        _buildStatusLine(
          order.status.index >= restaurant_app.OrderStatus.readyForPickup.index,
        ),
        _buildStatusDot(
          'Ready',
          order.status.index >= restaurant_app.OrderStatus.readyForPickup.index,
        ),
        _buildStatusLine(
          order.status.index >= restaurant_app.OrderStatus.outForDelivery.index,
        ),
        _buildStatusDot(
          'On Way',
          order.status.index >= restaurant_app.OrderStatus.outForDelivery.index,
        ),
        _buildStatusLine(
          order.status.index >= restaurant_app.OrderStatus.delivered.index,
        ),
        _buildStatusDot(
          'Delivered',
          order.status.index >= restaurant_app.OrderStatus.delivered.index,
        ),
      ],
    );
  }

  Widget _buildStatusDot(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isActive ? DesignTokens.primaryOrange : DesignTokens.neutralGrey300,
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? DesignTokens.primaryOrange : DesignTokens.neutralGrey500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      color: isActive ? DesignTokens.primaryOrange : DesignTokens.neutralGrey300,
    );
  }

  void _updateMarkers(DeliveryRoute route) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('restaurant'),
          position: LatLng(
            route.pickupLocation.latitude,
            route.pickupLocation.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Restaurant'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(
            route.deliveryLocation.latitude,
            route.deliveryLocation.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Delivery Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      };

      // In a real app, you would add a marker for the current dasher location
      // and update it in real-time using a location service
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}