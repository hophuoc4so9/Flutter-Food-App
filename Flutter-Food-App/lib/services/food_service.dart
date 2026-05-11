import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/food.dart';

class FoodService {
  final String baseUrl;
  final String? authToken;

  FoodService({
    required this.baseUrl,
    this.authToken,
  });

  /// Get foods by category ID
  Future<List<Food>> getFoodsByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/getFood/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true && data['success'] != null) {
          final List<dynamic> foodList = data['success'];
          return foodList
              .map((item) => Food.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load foods');
        }
      } else {
        throw Exception('Failed to load foods: ${response.statusCode}');
      }
    } catch (e) {
      print('[FoodService] Error getting foods by category: $e');
      rethrow;
    }
  }

  /// Get all foods (optional - if backend supports it)
  Future<List<Food>> getAllFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true && data['success'] != null) {
          final List<dynamic> foodList = data['success'];
          return foodList
              .map((item) => Food.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load foods');
        }
      } else {
        throw Exception('Failed to load foods: ${response.statusCode}');
      }
    } catch (e) {
      print('[FoodService] Error getting all foods: $e');
      rethrow;
    }
  }

  /// Get food by ID
  Future<Food> getFoodById(String foodId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/$foodId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true && data['success'] != null) {
          return Food.fromJson(data['success'] as Map<String, dynamic>);
        } else {
          throw Exception(data['message'] ?? 'Food not found');
        }
      } else {
        throw Exception('Failed to load food: ${response.statusCode}');
      }
    } catch (e) {
      print('[FoodService] Error getting food by ID: $e');
      rethrow;
    }
  }

  /// Search foods
  Future<List<Food>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/search').replace(
          queryParameters: {'q': query},
        ),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true && data['success'] != null) {
          final List<dynamic> foodList = data['success'];
          return foodList
              .map((item) => Food.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('[FoodService] Error searching foods: $e');
      rethrow;
    }
  }
}
