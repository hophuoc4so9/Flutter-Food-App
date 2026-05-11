import 'package:flutter/material.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const FoodDetailPage({Key? key, required this.foodItem}) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.foodItem["name"]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh món ăn
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.foodItem["image"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Container chứa chi tiết
            Container(
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodItem["name"],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        widget.foodItem["price"],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Chỉnh số lượng
                  Row(
                    children: [
                      const Text(
                        "Số lượng:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, size: 30),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle, color: Color(0xFFD32F2F), size: 30),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    "Mô tả chi tiết",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.foodItem["description"] + " Đây là một món ăn tuyệt vời dành cho những ai đam mê ẩm thực. Những nguyên liệu được tuyển chọn kỹ càng sẽ mang đến cho bạn một trải nghiệm không thể nào quên.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  // Nút mua hàng
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm $quantity ${widget.foodItem["name"]} vào giỏ đồ!')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Thêm vào giỏ ($quantity)",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
