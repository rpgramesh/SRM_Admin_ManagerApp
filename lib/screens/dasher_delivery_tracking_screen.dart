import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/design_tokens.dart';
import '../services/firestore_service.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../services/dasher_assignment_service.dart';
import '../models/delivery_route.dart';
import '../models/order.dart';
import '../models/dasher.dart';

class DasherDeliveryTrackingScreen extends StatefulWidget {
  final String deliveryRouteId;

  const DasherDeliveryTrackingScreen({
    super.key,
    required this.deliveryRouteId,
  });

  @override
  State<DasherDeliveryTrackingScreen> createState() =>
      _DasherDeliveryTrackingScreenState();
}

class _DasherDeliveryTrackingScreenState
    extends State<DasherDeliveryTrackingScreen> {
  late FirestoreService _firestoreService;
  late OrderService _orderService;
  late NotificationService _notificationService;
  late DasherAssignmentService _dasherAssignmentService;

  GoogleMapController? _mapController;
  DeliveryRoute? _currentRoute;
  Order? _currentOrder;
  Dasher? _currentDasher;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
    _orderService = Provider.of<OrderService>(context);
    _notificationService = Provider.of<NotificationService>(context);
    _dasherAssignmentService = Provider.of<DasherAssignmentService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: DesignTokens.dasherBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DeliveryRoute?>(
        stream:
            _firestoreService.getDeliveryRouteStream(widget.deliveryRouteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Delivery route not found'),
            );
          }

          _currentRoute = snapshot.data!;
          return _buildTrackingInterface();
        },
      ),
    );
  }

  Widget _buildTrackingInterface() {
    return Column(
      children: [
        _buildDeliveryStatus(),
        Expanded(
          flex: 3,
          child: _buildMapView(),
        ),
        Expanded(
          flex: 2,
          child: _buildDeliveryDetails(),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDeliveryStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_currentRoute!.status),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(
            _getStatusText(_currentRoute!.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(_currentRoute!.status),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentRoute!.pickupLocation,
            zoom: 14.0,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfo(),
          const SizedBox(height: 16),
          _buildCustomerInfo(),
          const SizedBox(height: 16),
          _buildDeliveryInstructions(),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return StreamBuilder<Order?>(
      stream: _firestoreService.getOrderStream(_currentRoute!.orderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        _currentOrder = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Order ID: #${_currentOrder!.id.substring(0, 8)}'),
                Text(
                    'Total: \$${_currentOrder!.totalAmount.toStringAsFixed(2)}'),
                Text('Items: ${_currentOrder!.items.length}'),
                const SizedBox(height: 8),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                ..._currentOrder!.items.map((item) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfo() {
    if (_currentOrder == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_currentOrder!.customerName),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_currentOrder!.customerPhone),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_currentOrder!.customerAddress),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Instructions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No special instructions available',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_currentRoute!.status == DeliveryStatus.assigned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickupOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Pick Up Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_currentRoute!.status == DeliveryStatus.pickedUp)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.dasherBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Complete Delivery',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callCustomer,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Customer'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openNavigation,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    _markers.clear();

    // Restaurant marker
    _markers.add(
      Marker(
        markerId: const MarkerId('restaurant'),
        position: _currentRoute!.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Restaurant',
          snippet: 'Pick up location',
        ),
      ),
    );

    // Delivery location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: _currentRoute!.deliveryLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Delivery Location',
          snippet: 'Customer address',
        ),
      ),
    );

    setState(() {});
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return Colors.orange;
      case DeliveryStatus.pickedUp:
        return DesignTokens.dasherBlue;
      case DeliveryStatus.delivered:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return 'Order Ready for Pickup';
      case DeliveryStatus.pickedUp:
        return 'On the Way to Customer';
      case DeliveryStatus.delivered:
        return 'Delivery Completed';
      case DeliveryStatus.cancelled:
        return 'Delivery Cancelled';
      default:
        return 'Unknown Status';
    }
  }

  String _getStatusMessage(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return 'Navigate to the restaurant and pick up the order';
      case DeliveryStatus.pickedUp:
        return 'Deliver the order to the customer address';
      case DeliveryStatus.delivered:
        return 'Thank you for completing this delivery!';
      case DeliveryStatus.cancelled:
        return 'Delivery has been cancelled due to issues';
      default:
        return 'Status unknown';
    }
  }

  Future<void> _pickupOrder() async {
    try {
      await _orderService.updateDeliveryRouteStatus(
        widget.deliveryRouteId,
        DeliveryStatus.pickedUp.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order picked up successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick up order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeDelivery() async {
    try {
      await _orderService.updateDeliveryRouteStatus(
        widget.deliveryRouteId,
        DeliveryStatus.delivered.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery completed successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to dasher dashboard
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _callCustomer() async {
    if (_currentOrder?.customerPhone != null) {
      // In a real app, you would use url_launcher to open the phone app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${_currentOrder!.customerPhone}'),
          backgroundColor: DesignTokens.dasherBlue,
        ),
      );
    }
  }

  Future<void> _openNavigation() async {
    final target = _currentRoute!.status == DeliveryStatus.assigned
        ? _currentRoute!.pickupLocation
        : _currentRoute!.deliveryLocation;

    // In a real app, you would use url_launcher to open Google Maps or Apple Maps
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening navigation app'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
