import 'dart:convert';

import 'package:flutter/material.dart';

import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../translations/translation_extension.dart';

class AuditDetailDialog extends StatelessWidget {
  final Map<String, dynamic> audit;
  final String languageCode;

  const AuditDetailDialog({
    super.key,
    required this.audit,
    required this.languageCode,
  });

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangesSection(Map<String, dynamic>? changes, ThemeData theme) {
    if (changes == null || changes.isEmpty) {
      return Text(
        'noChanges'.tr,
        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changes.entries.map((entry) {
        final field = entry.key;
        final value = entry.value;

        if (value is Map) {
          final oldValue = value['old'];
          final newValue = value['new'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          oldValue?.toString() ?? 'null',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.green.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          newValue?.toString() ?? 'null',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value?.toString() ?? 'null',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    TranslationService.setLanguage(languageCode);
    final theme = Theme.of(context);

    final id = audit['id']?.toString() ?? 'N/A';
    final userName = audit['user_name'] ?? 'Unknown';
    final userId = audit['user_id']?.toString() ?? 'N/A';
    final entityType = audit['entity_type'] ?? 'N/A';
    final entityId = audit['entity_id']?.toString() ?? 'N/A';
    final action = audit['action'] ?? 'N/A';
    final ipAddress = audit['ip_address'] ?? 'N/A';
    final userAgent = audit['user_agent'] ?? 'N/A';
    final createdAt = audit['created_at'] ?? 'N/A';
    final changes = audit['changes'] as Map<String, dynamic>?;

    return DialogX(
      title: '${'auditTrail'.tr} #$id',
      width: 700,
      onClose: () => Navigator.pop(context),
      content: SizedBox(
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Section
              Text(
                'basicInformation'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              _buildInfoRow('user'.tr, '$userName (ID: $userId)', theme),
              _buildInfoRow('entityType'.tr, entityType, theme),
              _buildInfoRow('entityId'.tr, entityId, theme),
              _buildInfoRow('action'.tr, action, theme),
              _buildInfoRow('timestamp'.tr, createdAt, theme),

              const SizedBox(height: 24),

              // Technical Info Section
              Text(
                'technicalInformation'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              _buildInfoRow('ipAddress'.tr, ipAddress, theme),
              _buildInfoRow('userAgent'.tr, userAgent, theme),

              const SizedBox(height: 24),

              // Changes Section
              Text(
                'changes'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildChangesSection(changes, theme),

              const SizedBox(height: 24),

              // Raw JSON Section (Expandable)
              ExpansionTile(
                title: Text(
                  'rawJsonData'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(audit),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
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
}
