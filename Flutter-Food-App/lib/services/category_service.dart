import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart' as app_config;
import '../models/category.dart';
import '../models/food.dart';

class CategoryService {
  final String? authToken;

  CategoryService({this.authToken});

  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse(app_config.getCategories),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final dynamic categoryList = decoded is List
        ? decoded
        : decoded['success'] ?? decoded['data'] ?? [];

    if (categoryList is! List) {
      throw Exception('Invalid category response format');
    }

    return categoryList
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  Future<List<Food>> getFoods(String categoryId) async {
    final response = await http.get(
      Uri.parse('${app_config.url}categories/getFood/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load foods: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final dynamic foodList = decoded is List
        ? decoded
        : decoded['success'] ?? decoded['data'] ?? [];

    if (foodList is! List) {
      throw Exception('Invalid food response format');
    }

    return foodList
        .whereType<Map<String, dynamic>>()
        .map(Food.fromJson)
        .toList();
  }
}
