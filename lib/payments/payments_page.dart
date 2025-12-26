import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/data_table_x.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    final response = await PaymentsService.getPayments();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = (response.data as Map<String, dynamic>)['data'];
      if (data is List) {
        setState(() {
          _payments = data.cast<Map<String, dynamic>>();
        });
      }
    }

    if (mounted) {
      setState(() {
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

    final response = await PaymentsService.getPaymentById(paymentId);

    if (!mounted) return;

    // Close loading dialog
    Navigator.pop(context);

    if (response.statusCode == 200 && response.data != null) {
      // Show payment detail dialog with fetched data
      showDialog(
        context: context,
        builder: (context) => PaymentDetailDialog(
          payment: response.data!,
          languageCode: widget.languageCode,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize translations with current language
    TranslationService.setLanguage(widget.languageCode);

    return Scaffold(
      appBar: AppBarX(
        title: 'payments'.tr,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPayments),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    style: const TextStyle(color: Colors.grey, fontSize: 16.0),
                  ),
                ],
              ),
            )
          : DataTableX(
              maxHeight: double.infinity,
              columnSpacing: 20,
              columns: [
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'paymentId'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'orderId'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'amount'.tr,
                  numeric: true,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'method'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'status'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'createdAt'.tr,
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(createdAt, style: const TextStyle(fontSize: 16.0)),
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
