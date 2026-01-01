import 'dart:convert';

import 'package:flutter/material.dart';

import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../translations/translation_extension.dart';

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SelectableText(
        const JsonEncoder.withIndent('  ').convert(changes),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TranslationService.setLanguage(languageCode);
    final theme = Theme.of(context);

    final id = audit['id']?.toString() ?? 'N/A';
    final userName = audit['user_name'] ?? 'Unknown';
    final userId = audit['user_id']?.toString() ?? 'N/A';
    final tenantId = audit['tenant_id']?.toString() ?? 'N/A';
    final branchId = audit['branch_id']?.toString() ?? 'N/A';
    final entityType = audit['entity_type'] ?? 'N/A';
    final entityId = audit['entity_id']?.toString() ?? 'N/A';
    final action = audit['action'] ?? 'N/A';
    final createdAt = audit['created_at'] ?? 'N/A';

    // Parse changes from JSON string to Map
    Map<String, dynamic>? changes;
    if (audit['changes'] != null) {
      if (audit['changes'] is String) {
        try {
          changes = jsonDecode(audit['changes']) as Map<String, dynamic>?;
        } catch (e) {
          changes = null;
        }
      } else if (audit['changes'] is Map) {
        changes = audit['changes'] as Map<String, dynamic>?;
      }
    }

    return DialogX(
      title: '${'auditTrail'.tr} #$id',
      width: 700,
      onClose: () => Navigator.pop(context),
      content: SizedBox(
        height: 600,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
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
              _buildInfoRow('tenantId'.tr, tenantId, theme),
              _buildInfoRow('branchId'.tr, branchId, theme),
              _buildInfoRow('entityType'.tr, entityType, theme),
              _buildInfoRow('entityId'.tr, entityId, theme),
              _buildInfoRow('action'.tr, action, theme),
              _buildInfoRow('timestamp'.tr, createdAt, theme),

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
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ButtonX(
                onClicked: () => Navigator.pop(context),
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
