class Food {
  final String? id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;

  Food({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.description = '',
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['description']?.toString() ?? '',
    );
  }
}
