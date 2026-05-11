import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment.dart';

class PaymentResultScreen extends StatefulWidget {
  final String orderId;
  final String status;
  final String baseUrl;
  final String authToken;

  const PaymentResultScreen({
    Key? key,
    required this.orderId,
    required this.status,
    required this.baseUrl,
    required this.authToken,
  }) : super(key: key);

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  late PaymentService _paymentService;
  late Future<Payment?> _paymentFuture;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      baseUrl: widget.baseUrl,
      authToken: widget.authToken,
    );
    _paymentFuture = _fetchPaymentDetails();
  }

  Future<Payment?> _fetchPaymentDetails() async {
    final result = await _paymentService.checkPaymentStatus(widget.orderId);
    if (result['status'] == true) {
      return Payment.fromJson(result['payment']);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả thanh toán'),
        elevation: 0,
      ),
      body: FutureBuilder<Payment?>(
        future: _paymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final payment = snapshot.data;
          final isSuccess = widget.status == 'SUCCESS' || payment?.isSuccess == true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Status icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess ? Colors.green[50] : Colors.red[50],
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.cancel,
                    size: 60,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),

                // Status text
                Text(
                  isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isSuccess
                      ? 'Giao dịch của bạn đã được hoàn tất'
                      : 'Giao dịch không thành công. Vui lòng thử lại',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Payment details
                if (payment != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Mã đơn hàng',
                          payment.orderId,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Số tiền',
                          '₫${payment.amount.toStringAsFixed(0)}',
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Trạng thái',
                          payment.status,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Mô tả',
                          payment.description,
                        ),
                        if (payment.transactionNo != null) ...[
                          const Divider(),
                          _buildDetailRow(
                            'Mã giao dịch',
                            payment.transactionNo!,
                          ),
                        ],
                        if (payment.bankCode != null) ...[
                          const Divider(),
                          _buildDetailRow(
                            'Ngân hàng',
                            payment.bankCode!,
                          ),
                        ],
                        if (payment.completedAt != null) ...[
                          const Divider(),
                          _buildDetailRow(
                            'Thời gian',
                            _formatDateTime(payment.completedAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 40),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Quay lại'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
