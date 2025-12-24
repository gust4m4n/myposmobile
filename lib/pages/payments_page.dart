import 'package:flutter/material.dart';

import '../services/orders_service.dart';
import '../services/payments_service.dart';
import '../utils/app_localizations.dart';
import '../utils/currency_formatter.dart';

class PaymentsPage extends StatefulWidget {
  final String languageCode;

  const PaymentsPage({super.key, required this.languageCode});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PaymentsService.getPayments();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _payments = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load payments';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading payments: $e';
        _isLoading = false;
      });
    }
  }

  void _showPaymentDetail(Map<String, dynamic> payment) async {
    final paymentId = payment['id'];
    if (paymentId == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await PaymentsService.getPaymentById(paymentId);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess && response.data != null) {
        // Show payment detail dialog with fetched data
        showDialog(
          context: context,
          builder: (context) => PaymentDetailDialog(
            payment: response.data!,
            languageCode: widget.languageCode,
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to load payment details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading payment details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(widget.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.payments),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPayments),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadPayments,
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations.retry),
                  ),
                ],
              ),
            )
          : _payments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.payment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noPayments,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                final orderId = payment['order_id'] ?? 0;
                final amount = payment['amount'] ?? 0;
                final paymentMethod = payment['payment_method'] ?? 'N/A';
                final status = payment['status'] ?? 'pending';
                final createdAt = payment['created_at'] ?? '';
                final notes = payment['notes'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(status),
                      child: const Icon(Icons.payment, color: Colors.white),
                    ),
                    title: Text(
                      CurrencyFormatter.format(amount.toDouble()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${localizations.orderId}: #$orderId'),
                        Text('${localizations.method}: $paymentMethod'),
                        Text('Status: $status'),
                        if (notes != null && notes.toString().isNotEmpty)
                          Text(
                            'Notes: $notes',
                            style: const TextStyle(fontSize: 12),
                          ),
                        Text(
                          createdAt,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPaymentDetail(payment),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class PaymentDetailDialog extends StatefulWidget {
  final Map<String, dynamic> payment;
  final String languageCode;

  const PaymentDetailDialog({
    super.key,
    required this.payment,
    required this.languageCode,
  });

  @override
  State<PaymentDetailDialog> createState() => _PaymentDetailDialogState();
}

class _PaymentDetailDialogState extends State<PaymentDetailDialog> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderId = widget.payment['order_id'];
      final response = await OrdersService.getOrderById(orderId);

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _orderData = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load order details';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading order details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(widget.languageCode);
    final payment = widget.payment;
    final amount = payment['amount'] ?? 0;
    final paymentMethod = payment['payment_method'] ?? 'N/A';
    final status = payment['status'] ?? 'pending';
    final notes = payment['notes'];
    final createdAt = payment['created_at'] ?? '';
    final orderId = payment['order_id'] ?? 0;

    return AlertDialog(
      title: Text('${localizations.payments} #${payment['id'] ?? 'N/A'}'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Status', status, theme),
              _buildInfoRow(
                'Amount',
                CurrencyFormatter.format(amount.toDouble()),
                theme,
              ),
              _buildInfoRow(localizations.method, paymentMethod, theme),
              _buildInfoRow(localizations.orderId, '#$orderId', theme),
              if (notes != null && notes.toString().isNotEmpty)
                _buildInfoRow('Notes', notes.toString(), theme),
              _buildInfoRow('Created', createdAt, theme),
              const SizedBox(height: 16),
              Text(
                localizations.orderItems,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (_orderData != null)
                ...(_orderData!['order_items'] as List? ?? []).map((item) {
                  final productName = item['product_name'] ?? 'Unknown';
                  final quantity = item['quantity'] ?? 0;
                  final price = item['price'] ?? 0;
                  final subtotal = item['subtotal'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(productName),
                      subtitle: Text(
                        '${localizations.price}: ${CurrencyFormatter.format(price.toDouble())}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'x$quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(CurrencyFormatter.format(subtotal.toDouble())),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.close),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
