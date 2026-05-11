import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';
  static const String _paymentStatusKey = 'payment_status_history';
  
  final SharedPreferences _prefs;

  CartService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get all cart items from SharedPreferences
  Future<List<CartItem>> getCartItems() async {
    final cartData = _prefs.getString(_cartKey);
    print('[CartService] → getCartItems() called, data exists: ${cartData != null}');
    if (cartData == null || cartData.isEmpty) {
      print('[CartService] ✓ Cart is empty');
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(cartData);
      print('[CartService] ✓ Loaded ${jsonList.length} items from storage');
      return jsonList
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[CartService] ✗ Error loading cart items: $e');
      return [];
    }
  }

  /// Save cart items to SharedPreferences
  Future<void> saveCartItems(List<CartItem> items) async {
    try {
      final jsonString = jsonEncode(items.map((item) => item.toJson()).toList());
      print('[CartService] Saving ${items.length} items: $jsonString');
      await _prefs.setString(_cartKey, jsonString);
      print('[CartService] ✓ Cart saved successfully');
    } catch (e) {
      print('[CartService] ✗ Error saving cart items: $e');
    }
  }

  /// Add item to cart or increase quantity if exists
  Future<void> addToCart(CartItem item) async {
    print('[CartService] → Adding item: ${item.name} (ID: ${item.id}, qty: ${item.quantity})');
    final items = await getCartItems();
    print('[CartService] → Current cart: ${items.length} items');
    
    final existingIndex = items.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (existingIndex >= 0) {
      print('[CartService] → Item exists at index $existingIndex, increasing quantity');
      items[existingIndex].quantity += item.quantity;
    } else {
      print('[CartService] → New item, adding to cart');
      items.add(item);
    }
    print('[CartService] → Cart updated: ${items.length} items total');
    for (int i = 0; i < items.length; i++) {
      print('[CartService]   [$i] ${items[i].name} x${items[i].quantity}');
    }
    await saveCartItems(items);
  }

  /// Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.id == itemId);
    await saveCartItems(items);
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
      await saveCartItems(items);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }

  /// Get total price of cart
  Future<double> getTotalPrice() async {
    final items = await getCartItems();
    return items.fold<double>(0.0, (sum, item) => sum + double.parse(item.totalPrice.toString()));
  }

  /// Get total quantity of items
  Future<int> getTotalQuantity() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.length;
  }

  /// Check if item exists in cart
  Future<bool> isInCart(String itemId) async {
    final items = await getCartItems();
    return items.any((item) => item.id == itemId);
  }

  /// Get quantity of specific item in cart
  Future<int> getItemQuantity(String itemId) async {
    final items = await getCartItems();
    final item = items.firstWhere(
      (cartItem) => cartItem.id == itemId,
      orElse: () => CartItem(
        id: '',
        name: '',
        imageUrl: '',
        price: 0,
      ),
    );
    return item.quantity;
  }

  /// Save successful payment status
  Future<void> savePaymentStatus({
    required String orderId,
    required double amount,
    required String description,
    required DateTime timestamp,
  }) async {
    try {
      final history = await getPaymentHistory();
      
      history.add({
        'orderId': orderId,
        'amount': amount,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'status': 'SUCCESS',
      });
      
      final jsonString = jsonEncode(history);
      await _prefs.setString(_paymentStatusKey, jsonString);
      print('[CartService] ✓ Payment status saved for Order #$orderId');
    } catch (e) {
      print('[CartService] ✗ Error saving payment status: $e');
    }
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final data = _prefs.getString(_paymentStatusKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('[CartService] ✗ Error loading payment history: $e');
      return [];
    }
  }

  /// Get last payment status
  Future<Map<String, dynamic>?> getLastPaymentStatus() async {
    final history = await getPaymentHistory();
    return history.isNotEmpty ? history.last : null;
  }

  /// Clear payment history
  Future<void> clearPaymentHistory() async {
    await _prefs.remove(_paymentStatusKey);
    print('[CartService] ✓ Payment history cleared');
  }
}
