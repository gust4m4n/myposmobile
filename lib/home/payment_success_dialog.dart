import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/button_x.dart';
import '../translations/translation_extension.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> items;

  const PaymentSuccessDialog({
    super.key,
    required this.orderData,
    required this.items,
  });

  Future<void> _generateAndDownloadReceipt(BuildContext context) async {
    try {
      final pdf = pw.Document();

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
                  '${'orderNumberLabel'.tr}: ${orderData['order_number']}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  '${'dateLabel'.tr}: ${_formatDateTime(orderData['created_at'])}',
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
                      CurrencyFormatter.format(orderData['total_amount']),
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
      final fileName = 'struk_${orderData['order_number']}.pdf';
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
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
            const SizedBox(height: 16),

            // Title
            Text(
              'transactionSuccess'.tr,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Order Number
            Text(
              '${'orderNumberLabel'.tr}: ${orderData['order_number']}',
              style: TextStyle(
                fontSize: 16.0,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),

            // Items List - Flexible to take available space
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: theme.dividerColor),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product_name'],
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['quantity']}x ${CurrencyFormatter.format(item['price'])}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item['subtotal']),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'total'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(orderData['total_amount']),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ButtonX(
                    onPressed: () => _generateAndDownloadReceipt(context),
                    icon: Icons.print,
                    label: 'printReceipt'.tr,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonX(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icons.check,
                    label: 'done'.tr,
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
