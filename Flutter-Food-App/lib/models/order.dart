class Order {
  final String orderId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String status; // PENDING, SUCCESS, FAILED, CANCELLED
  final DateTime createdAt;
  final String? paymentId;
  final String? description;

  Order({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    this.status = 'PENDING',
    required this.createdAt,
    this.paymentId,
    this.description,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as String,
      items: List<Map<String, dynamic>>.from(json['items'] as List),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentId: json['paymentId'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paymentId': paymentId,
      'description': description,
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isSuccess => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED';
  bool get isCancelled => status == 'CANCELLED';
}
