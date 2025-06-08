import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addToCart(CartItem item) {
    final existingIndex = _items.indexWhere((cartItem) => cartItem.productId == item.productId);
    
    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      _items[existingIndex].quantity += 1;
    } else {
      // Add new item to cart
      _items.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.productId == productId);
  }
}