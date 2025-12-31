import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../orders/services/orders_service.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../translations/translation_extension.dart';

class PaymentDetailDialog extends StatefulWidget {
  final Map<String, dynamic> payment;
  final String languageCode;
  final Map<String, dynamic>? orderData;
  final bool isSuccessMode;

  const PaymentDetailDialog({
    super.key,
    required this.payment,
    required this.languageCode,
    this.orderData,
    this.isSuccessMode = false,
  });

  @override
  State<PaymentDetailDialog> createState() => _PaymentDetailDialogState();
}

class _PaymentDetailDialogState extends State<PaymentDetailDialog> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderData != null) {
      _orderData = widget.orderData;
    } else {
      _loadOrderDetails();
    }
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    final orderId = widget.payment['order_id'];
    final response = await OrdersService.getOrderById(orderId);

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _orderData = response.data!;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndDownloadReceipt(BuildContext context) async {
    if (_orderData == null) return;

    try {
      final pdf = pw.Document();
      final items =
          (_orderData!['order_items'] as List?)?.cast<Map<String, dynamic>>() ??
          [];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'receiptTitle'.tr,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 5),

                // Order Info
                pw.Text(
                  '${'orderNumberLabel'.tr}: ${_orderData!['order_number']}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  '${'dateLabel'.tr}: ${_formatDateTime(_orderData!['created_at'])}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 5),

                // Items
                pw.Text(
                  'orderDetailsLabel'.tr,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),

                ...items.map((item) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            item['product_name'],
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          '${item['quantity']}x',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          CurrencyFormatter.format(item['subtotal']),
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 5),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'total'.tr.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(_orderData!['total_amount']),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'thankYou'.tr,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save directly to Downloads folder in user's home directory
      final home =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home == null) throw Exception('Cannot find home directory');

      final downloadsPath = '$home/Downloads';
      final fileName = 'struk_${_orderData!['order_number']}.pdf';
      final file = File('$downloadsPath/$fileName');

      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('receiptSaved'.tr.replaceAll('{fileName}', fileName)),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'openFolder'.tr,
              textColor: Colors.white,
              onPressed: () {
                // Open Downloads folder in Finder
                Process.run('open', [downloadsPath]);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'receiptFailed'.tr.replaceAll('{error}', e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(widget.languageCode);
    final payment = widget.payment;
    final amount = payment['amount'] ?? 0;
    final paymentMethod = payment['payment_method'] ?? 'N/A';
    final status = payment['status'] ?? 'pending';
    final notes = payment['notes'];
    final createdAt = payment['created_at'] ?? '';
    final orderId = payment['order_id'] ?? 0;

    return DialogX(
      title: widget.isSuccessMode
          ? 'transactionSuccess'.tr
          : '${'payments'.tr} #${payment['id'] ?? 'N/A'}',
      width: 500,
      onClose: () => Navigator.pop(context),
      content: SizedBox(
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isSuccessMode) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildInfoRow('status'.tr, status, theme),
            _buildInfoRow(
              'amount'.tr,
              CurrencyFormatter.format(amount.toDouble()),
              theme,
            ),
            _buildInfoRow('method'.tr, paymentMethod, theme),
            _buildInfoRow('orderId'.tr, '#$orderId', theme),
            if (notes != null && notes.toString().isNotEmpty)
              _buildInfoRow('notes'.tr, notes.toString(), theme),
            _buildInfoRow('created'.tr, createdAt, theme),
            const SizedBox(height: 16),
            Text(
              'orderItems'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_orderData != null)
              Expanded(
                child: DataTableX(
                  maxHeight: double.infinity,
                  columnSpacing: 16,
                  columns: [
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'product'.tr,
                    ),
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'price'.tr,
                      numeric: true,
                    ),
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'qty'.tr,
                      numeric: true,
                    ),
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'Subtotal',
                      numeric: true,
                    ),
                  ],
                  rows: (_orderData!['order_items'] as List? ?? []).map((item) {
                    final productName = item['product_name'] ?? 'Unknown';
                    final quantity = item['quantity'] ?? 0;
                    final price = item['price'] ?? 0;
                    final subtotal = item['subtotal'] ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(CurrencyFormatter.format(price.toDouble())),
                        ),
                        DataCell(
                          Text(
                            '$quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(subtotal.toDouble()),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ButtonX(
                onPressed: _orderData == null
                    ? null
                    : () => _generateAndDownloadReceipt(context),
                icon: Icons.print,
                label: 'printReceipt'.tr,
                backgroundColor: const Color(0xFFFF9500),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ButtonX(
                onPressed: () => Navigator.pop(context),
                icon: Icons.close,
                label: 'close'.tr,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
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
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
