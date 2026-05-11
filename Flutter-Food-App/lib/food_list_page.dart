import 'package:flutter/material.dart';
import 'food_detail_page.dart';
import 'services/food_service.dart';
import 'models/food.dart';
import 'widgets/custom_appbar.dart';

class FoodListPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String imagePath;
  final String? authToken;
  final String baseUrl;

  const FoodListPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.imagePath,
    this.authToken,
    this.baseUrl = 'http://localhost:3000',
  }) : super(key: key);

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  late Future<List<Food>> foodFuture;
  late FoodService foodService;

  @override
  void initState() {
    super.initState();
    foodService = FoodService(
      baseUrl: widget.baseUrl,
      authToken: widget.authToken,
    );
    foodFuture = foodService.getFoodsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MenuAppBar(
        categoryName: widget.categoryName,
      ),
      body: FutureBuilder<List<Food>>(
        future: foodFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        foodFuture = foodService.getFoodsByCategory(widget.categoryId);
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final foodItems = snapshot.data ?? [];

          if (foodItems.isEmpty) {
            return const Center(
              child: Text('Chưa có món ăn nào trong danh mục này'),
            );
          }

          return ListView.builder(
            itemCount: foodItems.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = foodItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailPage(
                        foodItem: {
                          'id': item.id,
                          'name': item.name,
                          'image': item.imageUrl,
                          'description': item.description,
                          'price': '\$${item.price.toStringAsFixed(2)}',
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Ảnh món ăn
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Thông tin chi tiết món
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        // Nút Thêm vào giỏ
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Đã thêm ${item.name} vào giỏ hàng!')),
                            );
                          },
                          icon: const Icon(Icons.add_circle,
                              color: Color(0xFFD32F2F), size: 35),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
