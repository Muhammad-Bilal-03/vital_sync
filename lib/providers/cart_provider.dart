import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_model.dart';

class CartProvider extends ChangeNotifier {
  final SharedPreferences _prefs; // Injected Dependency
  List<TestModel> _items = [];

  CartProvider(this._prefs) {
    _loadCart();
  }

  List<TestModel> get items => _items;

  double get totalAmount {
    return _items.fold(
        0, (sum, item) => sum + (item.discountedPrice ?? item.price));
  }

  void addTest(TestModel test) {
    if (!_items.any((item) => item.id == test.id)) {
      _items.add(test);
      _saveCart();
      notifyListeners();
    }
  }

  void removeTest(String testId) {
    _items.removeWhere((item) => item.id == testId);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // --- Persistence Logic ---
  static const String _cartKey = 'user_cart_v1';

  void _saveCart() {
    final List<String> jsonList =
        _items.map((item) => jsonEncode(item.toJson())).toList();
    _prefs.setStringList(_cartKey, jsonList);
  }

  void _loadCart() {
    final List<String>? jsonList = _prefs.getStringList(_cartKey);
    if (jsonList != null) {
      // Handle potential decoding errors gracefully
      try {
        _items = jsonList
            .map((itemJson) => TestModel.fromJson(jsonDecode(itemJson)))
            .toList();
      } catch (e) {
        print("Error loading cart: $e");
      }
      notifyListeners();
    }
  }
}
