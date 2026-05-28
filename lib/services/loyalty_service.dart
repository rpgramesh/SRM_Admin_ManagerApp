import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_point.dart';

class LoyaltyService {
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _loyaltyPointsCollection => 
      _firestore.collection('loyalty_points');
  CollectionReference get _userLoyaltyCollection => 
      _firestore.collection('user_loyalty_data');
  CollectionReference get _loyaltyRewardsCollection => 
      _firestore.collection('loyalty_rewards');

  // Get user's loyalty data
  Future<UserLoyaltyData?> getUserLoyaltyData(String userId) async {
    try {
      final doc = await _userLoyaltyCollection.doc(userId).get();
      if (doc.exists) {
        return UserLoyaltyData.fromMap(doc.data() as Map<String, dynamic>);
      }
      // Create initial loyalty data if doesn't exist
      final initialData = UserLoyaltyData(
        userId: userId,
        totalPoints: 0,
        usedPoints: 0,
        availablePoints: 0,
        lastUpdated: DateTime.now(),
        redeemedRewards: [],
      );
      await _userLoyaltyCollection.doc(userId).set(initialData.toMap());
      return initialData;
    } catch (e) {
      print('Error getting user loyalty data: $e');
      return null;
    }
  }

  // Get user's loyalty points history
  Future<List<LoyaltyPoint>> getUserLoyaltyHistory(String userId) async {
    try {
      final querySnapshot = await _loyaltyPointsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => LoyaltyPoint.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting loyalty history: $e');
      return [];
    }
  }

  // Add loyalty points
  Future<bool> addLoyaltyPoints({
    required String userId,
    required int points,
    required String source,
    String? orderId,
    String? description,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Create loyalty point record
      final loyaltyPointDoc = _loyaltyPointsCollection.doc();
      final loyaltyPoint = LoyaltyPoint(
        id: loyaltyPointDoc.id,
        userId: userId,
        points: points,
        source: source,
        createdAt: DateTime.now(),
        orderId: orderId,
        description: description,
      );
      batch.set(loyaltyPointDoc, loyaltyPoint.toMap());
      
      // Update user loyalty data
      final userLoyaltyDoc = _userLoyaltyCollection.doc(userId);
      batch.update(userLoyaltyDoc, {
        'totalPoints': FieldValue.increment(points),
        'availablePoints': FieldValue.increment(points),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding loyalty points: $e');
      return false;
    }
  }

  // Get available rewards
  Future<List<LoyaltyReward>> getAvailableRewards() async {
    try {
      final querySnapshot = await _loyaltyRewardsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('pointsCost')
          .get();
      
      return querySnapshot.docs
          .map((doc) => LoyaltyReward.fromMap(doc.data() as Map<String, dynamic>))
          .where((reward) => reward.expiryDate == null || reward.expiryDate!.isAfter(DateTime.now()))
          .toList();
    } catch (e) {
      print('Error getting available rewards: $e');
      return [];
    }
  }

  // Redeem reward
  Future<bool> redeemReward({
    required String userId,
    required String rewardId,
    required int pointsCost,
  }) async {
    try {
      final userLoyaltyData = await getUserLoyaltyData(userId);
      if (userLoyaltyData == null || userLoyaltyData.availablePoints < pointsCost) {
        return false; // Insufficient points
      }

      final batch = _firestore.batch();
      
      // Create negative loyalty point record for redemption
      final loyaltyPointDoc = _loyaltyPointsCollection.doc();
      final redemptionPoint = LoyaltyPoint(
        id: loyaltyPointDoc.id,
        userId: userId,
        points: -pointsCost,
        source: 'redemption',
        createdAt: DateTime.now(),
        description: 'Redeemed reward: $rewardId',
      );
      batch.set(loyaltyPointDoc, redemptionPoint.toMap());
      
      // Update user loyalty data
      final userLoyaltyDoc = _userLoyaltyCollection.doc(userId);
      batch.update(userLoyaltyDoc, {
        'usedPoints': FieldValue.increment(pointsCost),
        'availablePoints': FieldValue.increment(-pointsCost),
        'redeemedRewards': FieldValue.arrayUnion([rewardId]),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error redeeming reward: $e');
      return false;
    }
  }

  // Check if user can redeem reward
  Future<bool> canRedeemReward(String userId, int pointsCost) async {
    final userLoyaltyData = await getUserLoyaltyData(userId);
    return userLoyaltyData != null && userLoyaltyData.availablePoints >= pointsCost;
  }

  // Get user's redeemed rewards
  Future<List<String>> getUserRedeemedRewards(String userId) async {
    final userLoyaltyData = await getUserLoyaltyData(userId);
    return userLoyaltyData?.redeemedRewards ?? [];
  }

  // Stream user loyalty data for real-time updates
  Stream<UserLoyaltyData?> streamUserLoyaltyData(String userId) {
    return _userLoyaltyCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserLoyaltyData.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Stream available rewards for real-time updates
  Stream<List<LoyaltyReward>> streamAvailableRewards() {
    return _loyaltyRewardsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('pointsCost')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoyaltyReward.fromMap(doc.data() as Map<String, dynamic>))
            .where((reward) => reward.expiryDate == null || reward.expiryDate!.isAfter(DateTime.now()))
            .toList());
  }

  // Admin functions for managing rewards
  Future<bool> createReward(LoyaltyReward reward) async {
    try {
      await _loyaltyRewardsCollection.doc(reward.id).set(reward.toMap());
      return true;
    } catch (e) {
      print('Error creating reward: $e');
      return false;
    }
  }

  Future<bool> updateReward(String rewardId, Map<String, dynamic> updates) async {
    try {
      await _loyaltyRewardsCollection.doc(rewardId).update(updates);
      return true;
    } catch (e) {
      print('Error updating reward: $e');
      return false;
    }
  }

  Future<bool> deleteReward(String rewardId) async {
    try {
      await _loyaltyRewardsCollection.doc(rewardId).delete();
      return true;
    } catch (e) {
      print('Error deleting reward: $e');
      return false;
    }
  }
}