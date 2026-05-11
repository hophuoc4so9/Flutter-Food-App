class Payment {
  final String orderId;
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionNo;
  final String? bankCode;

  Payment({
    required this.orderId,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.completedAt,
    this.transactionNo,
    this.bankCode,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionNo: json['transactionNo'],
      bankCode: json['bankCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionNo': transactionNo,
      'bankCode': bankCode,
    };
  }

  bool get isSuccess => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
}
