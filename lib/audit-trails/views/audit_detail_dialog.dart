import 'dart:convert';

import 'package:flutter/material.dart';

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
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _colorizeJson(String jsonString) {
    // Add color codes to JSON using ANSI-like approach with TextSpan
    return jsonString;
  }

  Widget _buildChangesSection(Map<String, dynamic>? changes, ThemeData theme) {
    if (changes == null || changes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'noChanges'.tr,
          style: const TextStyle(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(changes);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText.rich(
        TextSpan(
          children: _buildColoredJson(jsonString),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildColoredJson(String json) {
    final List<TextSpan> spans = [];
    final RegExp keyPattern = RegExp(r'"([^"]+)":');
    final RegExp stringPattern = RegExp(r':\s*"([^"]*)"');
    final RegExp numberPattern = RegExp(r':\s*(\d+\.?\d*)');
    final RegExp boolPattern = RegExp(r':\s*(true|false|null)');

    int lastIndex = 0;

    // Process the JSON string character by character
    for (int i = 0; i < json.length; i++) {
      final char = json[i];

      // Check for keys (property names)
      if (char == '"' && i > 0 && json[i - 1] != '\\') {
        if (lastIndex < i) {
          spans.add(
            TextSpan(
              text: json.substring(lastIndex, i),
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final endQuote = json.indexOf('"', i + 1);
        if (endQuote != -1) {
          final key = json.substring(i, endQuote + 1);
          final nextChar = endQuote + 1 < json.length ? json[endQuote + 1] : '';

          if (nextChar == ':') {
            // This is a key
            spans.add(
              TextSpan(
                text: key,
                style: const TextStyle(color: Color(0xFF9CDCFE)), // Light blue
              ),
            );
            i = endQuote;
            lastIndex = endQuote + 1;
          } else {
            // This is a string value
            spans.add(
              TextSpan(
                text: key,
                style: const TextStyle(color: Color(0xFFCE9178)), // Orange
              ),
            );
            i = endQuote;
            lastIndex = endQuote + 1;
          }
        }
      }
    }

    // Add remaining text
    if (lastIndex < json.length) {
      final remaining = json.substring(lastIndex);
      // Color numbers, booleans, null
      final parts = remaining.split(RegExp(r'(\d+\.?\d*|true|false|null)'));
      for (var part in parts) {
        if (RegExp(r'^\d+\.?\d*$').hasMatch(part)) {
          spans.add(
            TextSpan(
              text: part,
              style: const TextStyle(color: Color(0xFFB5CEA8)), // Light green
            ),
          );
        } else if (part == 'true' || part == 'false' || part == 'null') {
          spans.add(
            TextSpan(
              text: part,
              style: const TextStyle(color: Color(0xFF569CD6)), // Blue
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: part,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }
      }
    }

    return spans;
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

              // 2-column layout for basic information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'user'.tr,
                          '$userName (ID: $userId)',
                          theme,
                        ),
                        _buildInfoRow('tenantId'.tr, tenantId, theme),
                        _buildInfoRow('entityType'.tr, entityType, theme),
                        _buildInfoRow('action'.tr, action, theme),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoRow('branchId'.tr, branchId, theme),
                        _buildInfoRow('entityId'.tr, entityId, theme),
                        _buildInfoRow('timestamp'.tr, createdAt, theme),
                      ],
                    ),
                  ),
                ],
              ),

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
    );
  }
}
