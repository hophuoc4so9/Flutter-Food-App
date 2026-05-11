import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  final String baseUrl;
  final String? authToken;

  PaymentService({
    required this.baseUrl,
    this.authToken,
  });

  /// Create payment request with VNPAY
  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-payment'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'status': true,
            'orderId': data['success']['orderId'],
            'paymentUrl': data['success']['paymentUrl'],
            'amount': data['success']['amount'],
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Failed to create payment',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error creating payment: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/check-status/$orderId'),
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
            'payment': data['success'],
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Payment not found',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'Payment not found',
        };
      } else {
        return {
          'status': false,
          'message': 'Error checking payment status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user payment history
  Future<Map<String, dynamic>> getUserPayments({
    String? status,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'skip': skip.toString(),
        if (status != null) 'status': status,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/payments/user-payments').replace(
          queryParameters: queryParams,
        ),
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
            'total': data['success']['total'],
            'payments': data['success']['payments'],
          };
        } else {
          return {
            'status': false,
            'message': data['message'] ?? 'Failed to retrieve payments',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Error retrieving payments: ${response.statusCode}',
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
