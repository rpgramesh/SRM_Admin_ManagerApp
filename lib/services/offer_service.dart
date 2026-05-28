import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'menuItems';

  // Get items marked as offers
  Stream<List<MenuItem>> getOfferItems() {
    return _firestore
        .collection(_collectionName)
        .where('hasOffer', isEqualTo: true)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromFirestore(doc))
            .toList());
  }

  // Get recommended items
  Stream<List<MenuItem>> getRecommendedItems() {
    return _firestore
        .collection(_collectionName)
        .where('isRecommended', isEqualTo: true)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromFirestore(doc))
            .toList());
  }

  // Get promotional items (items that are both offers and recommended)
  Stream<List<MenuItem>> getPromotionalItems() {
    return _firestore
        .collection(_collectionName)
        .where('hasOffer', isEqualTo: true)
        .where('isRecommended', isEqualTo: true)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromFirestore(doc))
            .toList());
  }

  // Get items by category with offers
  Stream<List<MenuItem>> getOfferItemsByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('hasOffer', isEqualTo: true)
        .where('category', isEqualTo: category)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromFirestore(doc))
            .toList());
  }
}