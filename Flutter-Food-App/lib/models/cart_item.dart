class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.description = '',
    this.quantity = 1,
  });

  // Convert CartItem to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'quantity': quantity,
    };
  }

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  // Calculate total price for this item
  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'CartItem(id: $id, name: $name, quantity: $quantity, totalPrice: $totalPrice)';
  }
}
