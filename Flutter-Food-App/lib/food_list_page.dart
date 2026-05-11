import 'package:flutter/material.dart';
import 'food_detail_page.dart';
import 'food_data.dart'; // Nơi gọi file dữ liệu

class FoodListPage extends StatelessWidget {
  final String categoryName;
  final String imagePath;

  const FoodListPage({Key? key, required this.categoryName, required this.imagePath}) : super(key: key);

  List<Map<String, dynamic>> _getFoodItems() {
    // Gọi dữ liệu món ăn theo Chủ đề Category (nếu không có thì trả về mảng rỗng)
    return foodMenuData[categoryName] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> foodItems = _getFoodItems();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Menu: $categoryName",
          style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = foodItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailPage(foodItem: item),
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
                    child: Image.asset(
                      item["image"],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Thông tin chi tiết món
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["name"],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["description"],
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item["price"],
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  
                  // Nút Thêm vào giỏ
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm ${item["name"]} vào giỏ hàng!')),
                      );
                    },
                    icon: const Icon(Icons.add_circle, color: Color(0xFFD32F2F), size: 35),
                  )
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
