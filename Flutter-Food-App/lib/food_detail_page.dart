import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/cart_item.dart';
import 'services/cart_service.dart';
import 'widgets/custom_appbar.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const FoodDetailPage({Key? key, required this.foodItem}) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int quantity = 1;
  late CartService _cartService;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _initializeCartService();
  }

  void _initializeCartService() async {
    final prefs = await SharedPreferences.getInstance();
    _cartService = CartService(prefs: prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: widget.foodItem["name"],
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
                      onPressed: _isAddingToCart ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isAddingToCart
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
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

  void _addToCart() async {
    setState(() => _isAddingToCart = true);
    
    try {
      final cartItem = CartItem(
        id: widget.foodItem["id"] ?? widget.foodItem["name"],
        name: widget.foodItem["name"],
        imageUrl: widget.foodItem["image"],
        price: _parsePrice(widget.foodItem["price"]),
        description: widget.foodItem["description"] ?? '',
        quantity: quantity,
      );

      await _cartService.addToCart(cartItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm $quantity ${widget.foodItem["name"]} vào giỏ đồ!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  double _parsePrice(dynamic price) {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.replaceAll('\$', '')) ?? 0.0;
    }
    return 0.0;
  }
}
