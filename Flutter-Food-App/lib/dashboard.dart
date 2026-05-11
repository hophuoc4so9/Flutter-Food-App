import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/category_service.dart';
import 'services/cart_service.dart';
import 'screens/cart_page.dart';
import 'food_list_page.dart';
import 'models/category.dart';
import 'widgets/custom_appbar.dart';

class Dashboard extends StatefulWidget {
  final token;
  const Dashboard({@required this.token, Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final CategoryService _categoryService;
  late CartService _cartService;
  late Future<List<Category>> _categoriesFuture;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _categoryService = CategoryService(authToken: widget.token);
    _categoriesFuture = _categoryService.getCategories();
    _initializeCartService();
  }

  void _initializeCartService() async {
    final prefs = await SharedPreferences.getInstance();
    _cartService = CartService(prefs: prefs);
    _updateCartCount();
  }

  void _updateCartCount() async {
    final count = await _cartService.getCartItemCount();
    setState(() => _cartItemCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DashboardAppBar(
        title: "Restaurant App",
        cartCount: _cartItemCount,
        onCartPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(
                token: widget.token,
                baseUrl: 'http://localhost:3000',
              ),
            ),
          );
          if (result != null) {
            _updateCartCount();
          }
        },
        onLogoutPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Cuisine",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 1),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Không tải được danh mục: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return const Center(child: Text('Chưa có danh mục nào'));
                }

                return GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: categories
                      .map(
                        (category) => _buildCuisineCard(
                          category.id,
                          category.name,
                          category.imageUrl,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineCard(String categoryId, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodListPage(
              categoryId: categoryId,
              categoryName: title,
              imagePath: imagePath,
              authToken: widget.token,
            ),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fastfood,
                          size: 56,
                          color: Colors.grey,
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fastfood,
                          size: 56,
                          color: Colors.grey,
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}
