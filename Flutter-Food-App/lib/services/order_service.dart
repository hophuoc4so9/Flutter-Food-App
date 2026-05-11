import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final String baseUrl;
  final String? authToken;

  OrderService({
    required this.baseUrl,
    this.authToken,
  });

  /// Create order from cart items
  Future<Map<String, dynamic>> createOrder({
    required List<CartItem> items,
    required String description,
  }) async {
    try {
      final double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      
      final orderData = {
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'totalPrice': item.totalPrice,
        }).toList(),
        'totalAmount': totalAmount,
        'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users/addOrder'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'status': true,
            'orderId': data['success']['orderId'] ?? data['success']['_id'],
            'order': data['success'],
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Failed to create order',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error creating order: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get order by ID
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'status': true,
            'order': Order.fromJson(data['success']),
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Order not found',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error fetching order: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get all orders for the current user
  Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final orders = (data['success'] as List)
              .map((order) => Order.fromJson(order as Map<String, dynamic>))
              .toList();
          return {
            'status': true,
            'orders': orders,
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'No orders found',
            'orders': [],
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error fetching orders: ${response.statusCode}',
          'orders': [],
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
        'orders': [],
      };
    }
  }

  /// Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'status': true,
            'order': data['success'],
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Failed to update order status',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error updating order: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'status': true,
            'message': 'Order cancelled successfully',
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Failed to cancel order',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error cancelling order: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }
}
