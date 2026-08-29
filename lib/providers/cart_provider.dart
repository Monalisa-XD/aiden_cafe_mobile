import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  bool _showCart = false;

  bool get showCart => _showCart;

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
}
