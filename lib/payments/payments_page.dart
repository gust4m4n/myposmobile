import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/scrollable_data_table.dart';
import '../translations/app_localizations.dart';
import '../translations/translation_extension.dart';
import 'payment_detail_dialog.dart';
import 'payments_service.dart';

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
    // Initialize translations with current language
    AppLocalizations.of(widget.languageCode);

    return Scaffold(
      appBar: AppBarX(
        title: 'payments'.tr,
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
                    label: Text('retry'.tr),
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
                    'noPayments'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ScrollableDataTable(
              maxHeight: double.infinity,
              columnSpacing: 20,
              columns: [
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Payment ID',
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'orderId'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Amount',
                  numeric: true,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'method'.tr,
                ),
                DataTableColumn.buildColumn(context: context, label: 'Status'),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Created At',
                ),
              ],
              rows: _payments.map((payment) {
                final paymentId = payment['id'] ?? 0;
                final orderId = payment['order_id'] ?? 0;
                final amount = payment['amount'] ?? 0;
                final paymentMethod = payment['payment_method'] ?? 'N/A';
                final status = payment['status'] ?? 'pending';
                final createdAt = payment['created_at'] ?? '';

                return DataRow(
                  onSelectChanged: (_) => _showPaymentDetail(payment),
                  cells: [
                    DataCell(
                      Text(
                        '#$paymentId',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text('#$orderId')),
                    DataCell(
                      Text(
                        CurrencyFormatter.format(amount.toDouble()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text(paymentMethod)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(createdAt, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                );
              }).toList(),
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
