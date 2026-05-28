import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/delivery_route.dart';
import '../models/order.dart' as restaurant_app;
import '../config/app_config.dart';
import 'notification_service.dart';
import 'firestore_service.dart';
import 'package:uuid/uuid.dart';

class DasherAssignmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  // Singleton pattern
  static final DasherAssignmentService _instance =
      DasherAssignmentService._internal();
  factory DasherAssignmentService() => _instance;
  DasherAssignmentService._internal();

  // Sample dasher data for production simulation
  // REMOVE THIS ENTIRE LIST
  /*
  final List<Map<String, dynamic>> _availableDashers = [
    {
      'id': 'dasher_001',
      'name': 'John Smith',
      'phone': '+1234567890',
      'location': const LatLng(-37.7159, 144.5917), // Near restaurant
      'isAvailable': true,
      'rating': 4.8,
      'completedDeliveries': 156,
      'vehicleType': 'bike',
    },
    {
      'id': 'dasher_002',
      'name': 'Maria Garcia',
      'phone': '+1234567891',
      'location': const LatLng(-37.8142, 144.9632), // Melbourne CBD
      'isAvailable': true,
      'rating': 4.9,
      'completedDeliveries': 203,
      'vehicleType': 'car',
    },
    {
      'id': 'dasher_003',
      'name': 'David Chen',
      'phone': '+1234567892',
      'location': const LatLng(-37.7749, 144.9441), // Richmond
      'isAvailable': true,
      'rating': 4.7,
      'completedDeliveries': 89,
      'vehicleType': 'bike',
    },
    {
      'id': 'dasher_004',
      'name': 'Sarah Wilson',
      'phone': '+1234567893',
      'location': const LatLng(-37.8736, 145.0444), // Box Hill
      'isAvailable': true,
      'rating': 4.6,
      'completedDeliveries': 134,
      'vehicleType': 'car',
    },
    {
      'id': 'dasher_005',
      'name': 'Michael Brown',
      'phone': '+1234567894',
      'location': const LatLng(-37.7906, 144.9841), // South Yarra
      'isAvailable': true,
      'rating': 4.8,
      'completedDeliveries': 178,
      'vehicleType': 'scooter',
    },
  ];
  */

  // Initialize sample dashers in Firestore
  Future<void> initializeSampleDashers() async {
    final dashersCollection = _db.collection('dashers');

    // final sampleDashers = [
    //   {
    //     'id': 'dasher_001',
    //     'name': 'John Smith',
    //     'phone': '+1234567890',
    //     'location': const LatLng(-37.7159, 144.5917),
    //     'isAvailable': true,
    //     'rating': 4.8,
    //     'completedDeliveries': 156,
    //     'vehicleType': 'bike',
    //   },
    //   {
    //     'id': 'dasher_002',
    //     'name': 'Maria Garcia',
    //     'phone': '+1234567891',
    //     'location': const LatLng(-37.8142, 144.9632),
    //     'isAvailable': true,
    //     'rating': 4.9,
    //     'completedDeliveries': 203,
    //     'vehicleType': 'car',
    //   }
    // ];

    // for (var dasher in sampleDashers) {
    //   await dashersCollection.doc(dasher['id'].toString()).set({
    //     'name': dasher['name'],
    //     'phone': dasher['phone'],
    //     'currentLocation': GeoPoint(
    //       (dasher['location'] as LatLng).latitude,
    //       (dasher['location'] as LatLng).longitude,
    //     ),
    //     'isAvailable': dasher['isAvailable'],
    //     'rating': dasher['rating'],
    //     'completedDeliveries': dasher['completedDeliveries'],
    //     'vehicleType': dasher['vehicleType'],
    //     'isOnline': true,
    //     'lastActiveTime': FieldValue.serverTimestamp(),
    //     'createdAt': FieldValue.serverTimestamp(),
    //   });
    // }
  }

  // Assign the best available dasher to an order
  Future<String?> assignDasherToOrder(restaurant_app.Order order) async {
    try {
      // Get restaurant location
      final restaurantLocation = await _getRestaurantLocation();

      // Get customer location from address
      final customerLocation = await _geocodeAddress(order.customerAddress);

      // Find the best available dasher
      final bestDasher = await _findBestAvailableDasher(
        restaurantLocation,
        customerLocation,
      );

      if (bestDasher == null) {
        return null; // No available dasher
      }

      // Create delivery route
      final route = DeliveryRoute(
        id: _uuid.v4(),
        orderId: order.id,
        dasherId: bestDasher['id'],
        pickupLocation: restaurantLocation,
        deliveryLocation: customerLocation,
        status: DeliveryStatus.assigned,
        assignedTime: DateTime.now(),
        pickedUpTime: null,
        deliveredTime: null,
      );

      // Save delivery route
      await _firestoreService.addDeliveryRoute(route);

      // Mark dasher as unavailable
      await _updateDasherAvailability(bestDasher['id'], false);

      // Send notification to dasher
      await _notificationService.notifyDasherAssigned(route);

      return bestDasher['id'];
    } catch (e) {
      print('Error assigning dasher: $e');
      return null;
    }
  }

  // Find the best available dasher based on distance, rating, and availability
  Future<Map<String, dynamic>?> _findBestAvailableDasher(
    LatLng restaurantLocation,
    LatLng customerLocation,
  ) async {
    final querySnapshot = await _db
        .collection('dashers')
        .where('isAvailable', isEqualTo: true)
        .where('isOnline', isEqualTo: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    List<Map<String, dynamic>> candidates = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final dasherLocation = data['currentLocation'] as GeoPoint;
      final dasherLatLng =
          LatLng(dasherLocation.latitude, dasherLocation.longitude);

      // Calculate distance to restaurant
      final distanceToRestaurant = _calculateDistance(
        dasherLatLng,
        restaurantLocation,
      );

      // Only consider dashers within delivery radius
      if (distanceToRestaurant <= AppConfig.defaultDeliveryRadius) {
        candidates.add({
          'id': doc.id,
          'name': data['name'],
          'phone': data['phone'],
          'location': dasherLatLng,
          'rating': data['rating'] ?? 0.0,
          'completedDeliveries': data['completedDeliveries'] ?? 0,
          'vehicleType': data['vehicleType'],
          'distanceToRestaurant': distanceToRestaurant,
        });
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    // Sort by score (distance + rating + experience)
    candidates.sort((a, b) {
      final scoreA = _calculateDasherScore(a);
      final scoreB = _calculateDasherScore(b);
      return scoreB.compareTo(scoreA); // Higher score is better
    });

    return candidates.first;
  }

  // Calculate dasher score based on multiple factors
  double _calculateDasherScore(Map<String, dynamic> dasher) {
    final distanceScore =
        10.0 - dasher['distanceToRestaurant']; // Closer is better
    final ratingScore = dasher['rating'] * 2; // Rating out of 5, multiply by 2
    final experienceScore =
        (dasher['completedDeliveries'] / 10).clamp(0, 5); // Experience bonus

    return distanceScore + ratingScore + experienceScore;
  }

  // Calculate distance between two points in kilometers
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final lat1Rad = point1.latitude * pi / 180;
    final lat2Rad = point2.latitude * pi / 180;
    final deltaLatRad = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLngRad = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Get restaurant location (using hardcoded for demo)
  Future<LatLng> _getRestaurantLocation() async {
    // In a real app, you would fetch this from your restaurant data
    return const LatLng(-37.71112804668473, 144.5917238006204);
  }

  // Geocode address to coordinates (simplified for demo)
  Future<LatLng> _geocodeAddress(String address) async {
    // In a real app, you would use Google Geocoding API
    // For demo, we'll return different coordinates based on address keywords

    if (address.toLowerCase().contains('melbourne')) {
      return const LatLng(-37.8136, 144.9631);
    } else if (address.toLowerCase().contains('richmond')) {
      return const LatLng(-37.8142, 144.9987);
    } else if (address.toLowerCase().contains('fitzroy')) {
      return const LatLng(-37.7979, 144.9789);
    } else if (address.toLowerCase().contains('carlton')) {
      return const LatLng(-37.7999, 144.9647);
    } else {
      // Default customer location
      return const LatLng(-37.82200579563919, 145.1772987824447);
    }
  }

  // Update dasher availability
  Future<void> _updateDasherAvailability(
      String dasherId, bool isAvailable) async {
    await _db.collection('dashers').doc(dasherId).update({
      'isAvailable': isAvailable,
      'lastActiveTime': FieldValue.serverTimestamp(),
    });
  }

  // Complete delivery and mark dasher as available
  Future<void> completeDelivery(String dasherId, String deliveryRouteId) async {
    await _updateDasherAvailability(dasherId, true);

    // Update dasher statistics
    await _db.collection('dashers').doc(dasherId).update({
      'completedDeliveries': FieldValue.increment(1),
      'lastActiveTime': FieldValue.serverTimestamp(),
    });
  }

  // Get available dashers for admin/manager view
  Stream<List<Map<String, dynamic>>> getAvailableDashers() {
    return _db
        .collection('dashers')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Update dasher location (for real-time tracking)
  Future<void> updateDasherLocation(String dasherId, LatLng newLocation) async {
    await _db.collection('dashers').doc(dasherId).update({
      'currentLocation': GeoPoint(newLocation.latitude, newLocation.longitude),
      'lastActiveTime': FieldValue.serverTimestamp(),
    });
  }
}
