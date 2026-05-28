import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = <String>{};
  final Map<String, MenuItem> _favoriteItems = <String, MenuItem>{};
  
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  List<MenuItem> get favoriteItems => _favoriteItems.values.toList();
  
  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId);
  }
  
  Future<void> toggleFavorite(MenuItem item) async {
    if (_favoriteIds.contains(item.id)) {
      _favoriteIds.remove(item.id);
      _favoriteItems.remove(item.id);
    } else {
      _favoriteIds.add(item.id);
      _favoriteItems[item.id] = item;
    }
    
    notifyListeners();
    await _saveFavorites();
  }
  
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorite_items') ?? [];
      _favoriteIds.clear();
      _favoriteIds.addAll(favoritesList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }
  
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_items', _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
  
  void clearFavorites() {
    _favoriteIds.clear();
    _favoriteItems.clear();
    notifyListeners();
    _saveFavorites();
  }
  
  int get favoriteCount => _favoriteIds.length;
}