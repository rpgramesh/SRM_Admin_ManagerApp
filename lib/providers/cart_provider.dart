import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;
  
  int get totalItems {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items.update(
        menuItem.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        menuItem.id,
        () => CartItem(
          id: DateTime.now().toString(),
          name: menuItem.name,
          price: menuItem.price,
          quantity: 1,
          imageUrl: menuItem.imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.remove(menuItemId);
    notifyListeners();
  }

  void decreaseQuantity(String menuItemId) {
    if (!_items.containsKey(menuItemId)) return;

    if (_items[menuItemId]!.quantity > 1) {
      _items.update(
        menuItemId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.remove(menuItemId);
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    
    if (_items.containsKey(itemId)) {
      _items.update(
        itemId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: quantity,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}