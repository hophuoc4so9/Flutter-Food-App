import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  /// Fetch all categories
  static Future<Map<String, dynamic>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/category/getCategory'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['status'] ?? false,
          'categories': data['success'] ?? [],
          'message': data['message'],
        };
      } else {
        return {
          'status': false,
          'categories': [],
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'categories': [],
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
