import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_code.dart';

class PromoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _promoCodesCollection = 'promo_codes';
  static const String _userPromoUsageCollection = 'user_promo_usage';

  // Get all available promo codes
  static Future<List<PromoCode>> getAvailablePromoCodes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_promoCodesCollection)
          .where('isActive', isEqualTo: true)
          .where('expiryDate', isGreaterThan: DateTime.now())
          .orderBy('expiryDate')
          .get();

      return querySnapshot.docs
          .map((doc) => PromoCode.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting available promo codes: $e');
      return [];
    }
  }

  // Get user's promo code usage history
  static Future<List<UserPromoCodeUsage>> getUserPromoUsage(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_userPromoUsageCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('usedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserPromoCodeUsage.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user promo usage: $e');
      return [];
    }
  }

  // Apply a promo code
  static Future<Map<String, dynamic>> applyPromoCode(String userId, String promoCode, double orderAmount) async {
    try {
      // Check if promo code exists and is valid
      final promoQuery = await _firestore
          .collection(_promoCodesCollection)
          .where('code', isEqualTo: promoCode)
          .where('isActive', isEqualTo: true)
          .where('expiryDate', isGreaterThan: DateTime.now())
          .get();

      if (promoQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid or expired promo code',
          'discount': 0.0
        };
      }

      final promoData = PromoCode.fromMap(promoQuery.docs.first.data());

      // Check minimum order amount
      if (promoData.minOrderAmount != null && orderAmount < promoData.minOrderAmount!) {
        return {
          'success': false,
          'message': 'Minimum order amount of A\$${promoData.minOrderAmount!} required',
          'discount': 0.0
        };
      }

      // Check if user has already used this promo code
      final usageQuery = await _firestore
          .collection(_userPromoUsageCollection)
          .where('userId', isEqualTo: userId)
          .where('promoCodeId', isEqualTo: promoData.id)
          .get();

      if (usageQuery.docs.isNotEmpty && promoData.isFirstOrderOnly) {
        return {
          'success': false,
          'message': 'Promo code already used',
          'discount': 0.0
        };
      }

      // Check usage limit
      if (promoData.usageLimit != null && promoData.usageLimit! > 0) {
        final totalUsageQuery = await _firestore
            .collection(_userPromoUsageCollection)
            .where('promoCodeId', isEqualTo: promoData.id)
            .get();

        if (totalUsageQuery.docs.length >= promoData.usageLimit!) {
          return {
            'success': false,
            'message': 'Promo code usage limit reached',
            'discount': 0.0
          };
        }
      }

      // Calculate discount
      double discount = 0.0;
      if (promoData.type == 'percentage') {
        discount = (orderAmount * promoData.value) / 100;
        if (promoData.maxDiscountAmount != null && promoData.maxDiscountAmount! > 0) {
          discount = discount > promoData.maxDiscountAmount! ? promoData.maxDiscountAmount! : discount;
        }
      } else {
        discount = promoData.value;
      }

      // Record usage
      final usage = UserPromoCodeUsage(
        id: '',
        userId: userId,
        promoCodeId: promoData.id,
        promoCode: promoCode,
        discountAmount: discount,
        orderAmount: orderAmount,
        usedAt: DateTime.now(),
        orderId: '', // Will be updated when order is created
      );

      await _firestore.collection(_userPromoUsageCollection).add(usage.toMap());

      return {
        'success': true,
        'message': 'Promo code applied successfully',
        'discount': discount,
        'promoData': promoData
      };
    } catch (e) {
      print('Error applying promo code: $e');
      return {
        'success': false,
        'message': 'Error applying promo code',
        'discount': 0.0
      };
    }
  }

  // Validate promo code without applying
  static Future<Map<String, dynamic>> validatePromoCode(String promoCode, double orderAmount) async {
    try {
      final promoQuery = await _firestore
          .collection(_promoCodesCollection)
          .where('code', isEqualTo: promoCode)
          .where('isActive', isEqualTo: true)
          .where('expiryDate', isGreaterThan: DateTime.now())
          .get();

      if (promoQuery.docs.isEmpty) {
        return {
          'valid': false,
          'message': 'Invalid or expired promo code'
        };
      }

      final promoData = PromoCode.fromMap(promoQuery.docs.first.data());

      if (promoData.minOrderAmount != null && orderAmount < promoData.minOrderAmount!) {
        return {
          'valid': false,
          'message': 'Minimum order amount of A\$${promoData.minOrderAmount!} required'
        };
      }

      // Calculate potential discount
      double discount = 0.0;
      if (promoData.type == 'percentage') {
        discount = (orderAmount * promoData.value) / 100;
        if (promoData.maxDiscountAmount != null && promoData.maxDiscountAmount! > 0) {
          discount = discount > promoData.maxDiscountAmount! ? promoData.maxDiscountAmount! : discount;
        }
      } else {
        discount = promoData.value;
      }

      return {
        'valid': true,
        'message': 'Valid promo code',
        'discount': discount,
        'promoData': promoData
      };
    } catch (e) {
      print('Error validating promo code: $e');
      return {
        'valid': false,
        'message': 'Error validating promo code'
      };
    }
  }

  // Stream available promo codes
  static Stream<List<PromoCode>> streamAvailablePromoCodes() {
    return _firestore
        .collection(_promoCodesCollection)
        .where('isActive', isEqualTo: true)
        .where('expiryDate', isGreaterThan: DateTime.now())
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromoCode.fromMap(doc.data()))
            .toList());
  }

  // Stream user promo usage
  static Stream<List<UserPromoCodeUsage>> streamUserPromoUsage(String userId) {
    return _firestore
        .collection(_userPromoUsageCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('usedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserPromoCodeUsage.fromMap(doc.data()))
            .toList());
  }

  // Admin functions
  static Future<void> createPromoCode(PromoCode promoCode) async {
    try {
      await _firestore.collection(_promoCodesCollection).add(promoCode.toMap());
    } catch (e) {
      print('Error creating promo code: $e');
      rethrow;
    }
  }

  static Future<void> updatePromoCode(String promoCodeId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_promoCodesCollection).doc(promoCodeId).update(updates);
    } catch (e) {
      print('Error updating promo code: $e');
      rethrow;
    }
  }

  static Future<void> deactivatePromoCode(String promoCodeId) async {
    try {
      await _firestore.collection(_promoCodesCollection).doc(promoCodeId).update({
        'isActive': false,
      });
    } catch (e) {
      print('Error deactivating promo code: $e');
      rethrow;
    }
  }

  // Get promo code statistics
  static Future<Map<String, dynamic>> getPromoCodeStats(String promoCodeId) async {
    try {
      final usageQuery = await _firestore
          .collection(_userPromoUsageCollection)
          .where('promoCodeId', isEqualTo: promoCodeId)
          .get();

      double totalDiscount = 0.0;
      double totalOrderValue = 0.0;
      
      for (var doc in usageQuery.docs) {
        final usage = UserPromoCodeUsage.fromMap(doc.data());
        totalDiscount += usage.discountAmount;
        totalOrderValue += usage.orderAmount;
      }

      return {
        'totalUsage': usageQuery.docs.length,
        'totalDiscount': totalDiscount,
        'totalOrderValue': totalOrderValue,
        'averageOrderValue': usageQuery.docs.isNotEmpty ? totalOrderValue / usageQuery.docs.length : 0.0,
      };
    } catch (e) {
      print('Error getting promo code stats: $e');
      return {
        'totalUsage': 0,
        'totalDiscount': 0.0,
        'totalOrderValue': 0.0,
        'averageOrderValue': 0.0,
      };
    }
  }
}