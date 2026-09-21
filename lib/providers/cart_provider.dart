import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _showCart = false;

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items);
  bool get showCart => _showCart;

  int get totalCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold<double>(0, (sum, item) => sum + item.subtotal);
  double get total => subtotal;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void toggleCart() {
    _showCart = !_showCart;
    notifyListeners();
  }

  void openCart() {
    if (!_showCart) {
      _showCart = true;
      notifyListeners();
    }
  }

  void closeCart() {
    if (_showCart) {
      _showCart = false;
      notifyListeners();
    }
  }

  /// Adds a [MenuItem] to the cart, increasing quantity if it already exists.
  void addItem(MenuItem item, {int quantity = 1}) {
    if (quantity <= 0) return;
    final index = _items.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          id: item.id,
          name: item.name,
          price: item.price,
          image: item.image,
          quantity: quantity,
          category: item.category,
        ),
      );
    }
    notifyListeners();
  }

  /// Adds a typed [CartItem] directly.
  void addCartItem(CartItem item) {
    if (item.quantity <= 0) return;
    final index = _items.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  /// Adds item from loose parameters (supporting dynamic callers).
  void addItemFromParams({
    required String id,
    required String name,
    required double price,
    required String image,
    int quantity = 1,
    String category = '',
  }) {
    if (quantity <= 0) return;
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          price: price,
          image: image,
          quantity: quantity,
          category: category,
        ),
      );
    }
    notifyListeners();
  }

  /// Increments quantity for item matching [id].
  void increaseQuantity(String id) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      notifyListeners();
    }
  }

  /// Decrements quantity for item matching [id]. If quantity reaches 0, removes the item.
  void decreaseQuantity(String id) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity - 1,
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Explicitly removes the item with [id] from the cart.
  void removeItem(String id) {
    final beforeLength = _items.length;
    _items.removeWhere((element) => element.id == id);
    if (_items.length != beforeLength) {
      notifyListeners();
    }
  }

  /// Clears all items in the cart.
  void clear() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }

  /// Returns the current quantity of an item by [id], or 0 if not present.
  int getQuantity(String id) {
    final index = _items.indexWhere((element) => element.id == id);
    return index >= 0 ? _items[index].quantity : 0;
  }

  /// Checks whether an item is present in the cart.
  bool containsItem(String id) {
    return _items.any((element) => element.id == id);
  }
}
