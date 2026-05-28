import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/models/menu_item.dart';

class MenuManagementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'menuItems';

  // Create a new menu item
  Future<String> createMenuItem(MenuItem menuItem) async {
    try {
      DocumentReference docRef;
      
      // If menuItem.id is empty or null, generate a new document ID
      if (menuItem.id.isEmpty) {
        docRef = _db.collection(_collectionName).doc();
      } else {
        docRef = _db.collection(_collectionName).doc(menuItem.id);
      }
      
      // Create a new MenuItem with the correct ID
      final menuItemWithId = MenuItem(
        id: docRef.id,
        name: menuItem.name,
        description: menuItem.description,
        price: menuItem.price,
        imageUrl: menuItem.imageUrl,
        category: menuItem.category,
        isSpicy: menuItem.isSpicy,
        isVegetarian: menuItem.isVegetarian,
        inStock: menuItem.inStock,
        isRecommended: menuItem.isRecommended,
        hasOffer: menuItem.hasOffer,
      );
      
      await docRef.set(menuItemWithId.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  // Get all menu items with filtering and sorting
  Stream<List<MenuItem>> getMenuItems({
    String? category,
    bool? isVegetarian,
    bool? isSpicy,
    String sortBy = 'name',
    bool descending = false,
  }) {
    Query query = _db.collection(_collectionName);

    // Apply filters
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (isVegetarian != null) {
      query = query.where('isVegetarian', isEqualTo: isVegetarian);
    }
    if (isSpicy != null) {
      query = query.where('isSpicy', isEqualTo: isSpicy);
    }

    // Apply sorting
    query = query.orderBy(sortBy, descending: descending);

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get menu items by category
  Stream<List<MenuItem>> getMenuItemsByCategory(String category) {
    return _db
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  // Get menu items for a specific price range
  Stream<List<MenuItem>> getMenuItemsByPriceRange(double minPrice, double maxPrice) {
    return _db
        .collection(_collectionName)
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .orderBy('price')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  // Update a menu item
  Future<void> updateMenuItem(MenuItem menuItem) async {
    try {
      // Use set with merge option to create document if it doesn't exist
      await _db.collection(_collectionName).doc(menuItem.id).set(
        menuItem.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String id) async {
    try {
      await _db.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  // Get a single menu item by ID
  Future<MenuItem?> getMenuItem(String id) async {
    try {
      final doc = await _db.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return MenuItem.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get menu item: $e');
    }
  }

  // Get menu item count by category
  Future<Map<String, int>> getMenuItemCountByCategory() async {
    try {
      final snapshot = await _db.collection(_collectionName).get();
      final Map<String, int> categoryCount = {};

      for (var doc in snapshot.docs) {
        final category = doc.data()['category'] as String;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return categoryCount;
    } catch (e) {
      throw Exception('Failed to get category counts: $e');
    }
  }

  // Search menu items
  Future<List<MenuItem>> searchMenuItems(String query) async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }

  // Batch operations for menu items
  Future<void> batchUpdate(List<MenuItem> items) async {
    final batch = _db.batch();
    
    for (final item in items) {
      final docRef = _db.collection(_collectionName).doc(item.id);
      batch.update(docRef, item.toJson());
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update menu items: $e');
    }
  }
}