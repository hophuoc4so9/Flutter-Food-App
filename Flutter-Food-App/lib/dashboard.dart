import 'package:flutter/material.dart';
import 'services/category_service.dart';

class Dashboard extends StatefulWidget {
  final token;
  const Dashboard({@required this.token, Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    var result = await CategoryService.fetchCategories();

    setState(() {
      categories = result['categories'] ?? [];
      errorMessage = result['message'] ?? '';
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Icon(Icons.menu, color: Colors.black),
        title: Text(
          "Restaurant App",
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                child: Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28),
              ),
              Positioned(
                top: 8,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "3",
                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 8),
        ],
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text('Error: $errorMessage'))
                    : categories.isEmpty
                        ? Center(child: Text('No categories found'))
                        : GridView.count(
                            crossAxisCount: 2,
                            padding: EdgeInsets.all(16),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: categories.map((category) {
                              return _buildCuisineCard(
                                category['name'] ?? 'Unknown',
                                category['image_url'] ?? 'assets/placeholder.jpg',
                              );
                            }).toList(),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineCard(String title, String imagePath) {
    return Container(
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
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
    );
  }
}
