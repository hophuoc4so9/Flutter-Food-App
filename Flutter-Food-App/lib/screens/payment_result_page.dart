import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment.dart';
import '../widgets/custom_appbar.dart';

class PaymentResultPage extends StatefulWidget {
  final String token;
  final String baseUrl;
  final String orderId;
  final String status;

  const PaymentResultPage({
    required this.token,
    required this.baseUrl,
    required this.orderId,
    required this.status,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  late PaymentService _paymentService;
  Payment? _payment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _fetchPaymentStatus();
  }

  void _initializeService() {
    _paymentService = PaymentService(
      baseUrl: widget.baseUrl,
      authToken: widget.token,
    );
  }

  void _fetchPaymentStatus() async {
    try {
      final result = await _paymentService.checkPaymentStatus(widget.orderId);
      if (result['status'] && result['payment'] != null) {
        setState(() {
          _payment = Payment.fromJson(result['payment']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching payment status: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(
        title: 'Payment Status',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _payment != null ? _buildPaymentStatus() : _buildUnknownStatus(),
              ),
            ),
    );
  }

  Widget _buildPaymentStatus() {
    final isSuccess = _payment!.isSuccess;
    final isFailed = _payment!.isFailed;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Status Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSuccess ? Colors.green[50] : Colors.red[50],
          ),
          child: Icon(
            isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 60,
            color: isSuccess ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        // Status Title
        Text(
          isSuccess ? 'Payment Successful!' : isFailed ? 'Payment Failed' : 'Payment Pending',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
        ),
        const SizedBox(height: 12),
        // Status Description
        Text(
          isSuccess
              ? 'Your payment has been processed successfully.'
              : isFailed
                  ? 'Your payment could not be processed. Please try again.'
                  : 'Your payment is being processed. Please wait.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Payment Details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Order ID', _payment!.orderId),
              const SizedBox(height: 12),
              _buildDetailRow('Amount', '\$${_payment!.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              _buildDetailRow('Status', _payment!.status),
              if (_payment!.transactionNo != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Transaction No', _payment!.transactionNo!),
              ],
              if (_payment!.bankCode != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Bank', _payment!.bankCode!),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(
                'Date',
                '${_payment!.createdAt.toLocal().toString().split('.')[0]}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Action Buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Back to Home',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (isFailed) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUnknownStatus() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.help_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Status Unknown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'We could not retrieve your payment status.\nOrder ID: ${widget.orderId}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              _fetchPaymentStatus();
              setState(() => _isLoading = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
